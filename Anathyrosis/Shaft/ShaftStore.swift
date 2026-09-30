import Foundation
import Observation

/// Role: Shaft. Observable fold owner. Memory is the source of truth. UserDefaults is the projection. Views call scatterPiece, stackDrum, missDrum, and peelNewestMark.
@MainActor
@Observable
final class ShaftStore {
    static let seekDebounceNanoseconds: UInt64 = 500_000_000

    private(set) var shaft: Shaft
    private(set) var warning: ShaftWarning?
    private(set) var lastWriteError: String?

    private let vault: ShaftVault
    private let client: CatalogClient
    private let picker: any InscriptionPicking
    private let shuffle: any DrumShuffling
    private let shelf: CrateShelf
    private let writeDelayNanoseconds: UInt64
    private let seekDelayNanoseconds: UInt64
    private var persistTask: Task<Void, Never>?
    private var seekTask: Task<[CatalogRow], Error>?

    init(
        directory: URL,
        suiteName: String? = nil,
        client: CatalogClient = CatalogClient(),
        picker: any InscriptionPicking = AlternatingInscriptionPicker(),
        shuffle: any DrumShuffling = SaltDrumShuffle(salt: 1_709),
        shelf: CrateShelf = .bundled,
        writeDelayNanoseconds: UInt64 = 280_000_000,
        seekDelayNanoseconds: UInt64 = ShaftStore.seekDebounceNanoseconds
    ) {
        self.vault = ShaftVault(directory: directory, suiteName: suiteName)
        self.client = client
        self.picker = picker
        self.shuffle = shuffle
        self.shelf = shelf
        self.writeDelayNanoseconds = writeDelayNanoseconds
        self.seekDelayNanoseconds = seekDelayNanoseconds
        self.shaft = .empty
        self.warning = nil
        self.lastWriteError = nil
    }

    convenience init() {
        let directory: URL
        do {
            directory = try ShaftVault.applicationSupportDirectory()
        } catch {
            directory = FileManager.default.temporaryDirectory.appendingPathComponent("Spindak", isDirectory: true)
        }
        self.init(directory: directory)
    }

    func load() async {
        let loaded = await vault.load()
        var next = loaded.shaft
        next.applyShelfImages(shelf.rows)
        shaft = next
        warning = loaded.warning
        lastWriteError = nil
        if next != loaded.shaft {
            await persistNow()
        }
    }

    func scatterPiece() async throws {
        var next = shaft
        try next.scatterPiece(picker: picker, shuffle: shuffle)
        shaft = next
        await persistNow()
    }

    func stackDrum(_ drumID: UUID, now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = shaft
        _ = try next.stackDrum(drumID, now: now, calendar: calendar)
        shaft = next
        await persistNow()
    }

    func missDrum(_ drumID: UUID, now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = shaft
        _ = try next.missDrum(drumID, now: now, calendar: calendar)
        shaft = next
        await persistNow()
    }

    func tapDrum(_ drumID: UUID, now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = shaft
        _ = try next.tapDrum(drumID, now: now, calendar: calendar)
        shaft = next
        await persistNow()
    }

    func peelNewestMark() async throws {
        var next = shaft
        try next.peelNewestMark()
        shaft = next
        await persistNow()
    }

    @discardableResult
    func cratePiece(_ row: CatalogRow, now: Date = Date(), calendar: Calendar = .current) async throws -> WriteFocus {
        var next = shaft
        let focus = try next.cratePiece(row, now: now, calendar: calendar)
        shaft = next
        await persistNow()
        return focus
    }

    func seek(_ query: String) async throws -> [CatalogRow] {
        seekTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return shaft.fallbackRows(shelf: shelf.rows)
        }
        let client = self.client
        let delay = seekDelayNanoseconds
        let task = Task { () throws -> [CatalogRow] in
            if delay > 0 {
                try await Task.sleep(nanoseconds: delay)
            }
            try Task.checkCancellation()
            return try await client.search(query: trimmed)
        }
        seekTask = task
        do {
            let rows = try await task.value
            if Task.isCancelled { throw CatalogFault.cancelled }
            if rows.isEmpty {
                return shaft.fallbackRows(shelf: shelf.rows)
            }
            var next = shaft
            next.remember(rows)
            shaft = next
            await persistNow()
            return rows
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch let fault as CatalogFault where fault == .cancelled {
            throw fault
        } catch {
            return shaft.fallbackRows(shelf: shelf.rows)
        }
    }

    func setOnboardingComplete(_ flag: Bool) async {
        var next = shaft
        next.setOnboardingComplete(flag)
        shaft = next
        schedulePersist()
    }

    func flush() async {
        persistTask?.cancel()
        persistTask = nil
        await persistNow()
    }

    func resetAllData() async {
        persistTask?.cancel()
        persistTask = nil
        shaft = .empty
        warning = nil
        lastWriteError = nil
        do {
            try await vault.wipe()
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    func seedDemoIfNeeded(now: Date = Date(), calendar: Calendar = .current) async {
        #if targetEnvironment(simulator)
        if await vault.demoPlanted() { return }
        shaft = ShaftSeed.shaft(now: now, calendar: calendar, picker: picker, shuffle: shuffle, shelf: shelf.rows)
        shaft.applyShelfImages(shelf.rows)
        await vault.markDemoPlanted()
        await persistNow()
        #else
        _ = now
        _ = calendar
        #endif
    }

    private func persistNow() async {
        do {
            try await vault.save(shaft)
            lastWriteError = nil
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    private func schedulePersist() {
        persistTask?.cancel()
        let delay = writeDelayNanoseconds
        persistTask = Task { [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.persistNow()
        }
    }
}

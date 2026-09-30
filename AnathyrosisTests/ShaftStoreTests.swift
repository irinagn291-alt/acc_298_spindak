import XCTest
@testable import Anathyrosis

final class ShaftStoreTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var calendar: Calendar { AnathyrosisGMT.calendar }
    private var now: Date { AnathyrosisGMT.instant(2026, 9, 19) }

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        suiteName = "ahy.test.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        if let directory {
            try? FileManager.default.removeItem(at: directory)
        }
        if let suiteName {
            defaults?.removePersistentDomain(forName: suiteName)
        }
        directory = nil
        defaults = nil
        suiteName = nil
    }

    @MainActor
    func test_roundTrip_reloadPreservesHangingMarksAndDrums() async throws {
        let store = makeStore()
        await store.load()
        try await store.cratePiece(CrateShelf.bundled.rows[0], now: now, calendar: calendar)
        try await store.scatterPiece()
        let miss = try XCTUnwrap(store.shaft.spoil?.heap.first { $0.readingIndex != 0 })
        try await store.missDrum(miss.id, now: now, calendar: calendar)
        try await stackUntilRebuilt(store)
        await store.flush()

        let relaunched = makeStore()
        await relaunched.load()
        XCTAssertNil(relaunched.warning)
        XCTAssertEqual(relaunched.shaft.pieces.count, 1)
        XCTAssertEqual(relaunched.shaft.hangingPiece?.anastylosis, .rebuilt)
        XCTAssertEqual(relaunched.shaft.clampMarks.count, InscriptionField.words(in: CrateShelf.bundled.rows[0].title).count)
        XCTAssertEqual(relaunched.shaft.spallMarks.count, 1)
        XCTAssertEqual(relaunched.shaft.sign, .rebuilt)
        XCTAssertNotNil(defaults.data(forKey: ShaftKey.snapshot))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("shaft.json").path))
    }

    @MainActor
    func test_corruptSnapshotFallsBackToBackup() async throws {
        let store = makeStore()
        await store.load()
        try await store.cratePiece(CrateShelf.bundled.rows[0], now: now, calendar: calendar)
        await store.flush()
        if let good = defaults.data(forKey: ShaftKey.snapshot) {
            defaults.set(good, forKey: ShaftKey.backup)
        }
        let file = directory.appendingPathComponent("shaft.json")
        let backup = directory.appendingPathComponent("shaft.json.backup")
        if FileManager.default.fileExists(atPath: file.path) {
            try? FileManager.default.removeItem(at: backup)
            try FileManager.default.copyItem(at: file, to: backup)
        }
        defaults.set(Data("{not-json".utf8), forKey: ShaftKey.snapshot)
        try Data("{not-json".utf8).write(to: file)

        let loaded = makeStore()
        await loaded.load()
        XCTAssertEqual(loaded.warning, .recoveredFromBackup)
        XCTAssertEqual(loaded.shaft.pieces.count, 1)
    }

    @MainActor
    func test_corruptSnapshotWithoutBackupStartsEmpty() async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defaults.set(Data("nope".utf8), forKey: ShaftKey.snapshot)
        try Data("nope".utf8).write(to: directory.appendingPathComponent("shaft.json"))
        let store = makeStore()
        await store.load()
        XCTAssertEqual(store.warning, .startedEmpty)
        XCTAssertTrue(store.shaft.pieces.isEmpty)
        XCTAssertFalse(store.shaft.onboardingComplete)
    }

    func test_codecSwitchesOnSchemaVersion() throws {
        let shaft = ShaftSeed.shaft(now: now, calendar: calendar)
        let data = try ShaftDocument.encode(shaft)
        let decoded = try ShaftDocument.decode(data)
        XCTAssertEqual(decoded.schemaVersion, 1)
        XCTAssertEqual(decoded.pieces.count, shaft.pieces.count)
        XCTAssertEqual(decoded.spoil?.pieceID, shaft.spoil?.pieceID)
        XCTAssertEqual(decoded.spallMarks.count, shaft.spallMarks.count)
        XCTAssertTrue(decoded.pieces.contains { $0.anastylosis == .rebuilt })
        XCTAssertTrue(decoded.pieces.contains { $0.anastylosis == .laid })

        XCTAssertThrowsError(try ShaftDocument.decode(Data("{\"schemaVersion\":99}".utf8))) { error in
            XCTAssertEqual(error as? ShaftCodecError, .unsupportedSchema(99))
        }
        XCTAssertThrowsError(try ShaftDocument.decode(Data("[]".utf8))) { error in
            XCTAssertEqual(error as? ShaftCodecError, .corrupt)
        }
    }

    @MainActor
    func test_resetAllDataClearsSnapshotAndFiles() async throws {
        let store = makeStore()
        await store.load()
        try await store.cratePiece(CrateShelf.bundled.rows[0], now: now, calendar: calendar)
        await store.flush()
        await store.resetAllData()
        await store.load()
        XCTAssertTrue(store.shaft.pieces.isEmpty)
        XCTAssertFalse(store.shaft.onboardingComplete)
        XCTAssertNil(defaults.data(forKey: ShaftKey.snapshot))
        XCTAssertNil(defaults.data(forKey: ShaftKey.backup))
        let leftovers = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        XCTAssertTrue(leftovers.filter { $0.pathExtension == "json" }.isEmpty)
    }

    @MainActor
    func test_onboardingFlagDebouncesUntilFlush() async throws {
        let store = makeStore()
        await store.load()
        await store.setOnboardingComplete(true)
        await store.flush()
        let loaded = makeStore()
        await loaded.load()
        XCTAssertTrue(loaded.shaft.onboardingComplete)
    }

    #if targetEnvironment(simulator)
    @MainActor
    func test_simulatorSeedWritesOnceAndEnablesStack() async throws {
        let store = makeStore()
        await store.seedDemoIfNeeded(now: now, calendar: calendar)
        let firstPieces = store.shaft.pieces.count
        await store.seedDemoIfNeeded(now: now, calendar: calendar)
        XCTAssertEqual(store.shaft.pieces.count, firstPieces)
        XCTAssertTrue(store.shaft.onboardingComplete)
        XCTAssertTrue(store.shaft.canStack)
        XCTAssertEqual(store.shaft.hangingPiece?.anastylosis, .laid)
        XCTAssertNotEqual(store.shaft.sign, .waste)
        XCTAssertGreaterThanOrEqual(store.shaft.pieces.count, 6)
        XCTAssertTrue(defaults.bool(forKey: ShaftKey.demo))
        XCTAssertNotNil(defaults.data(forKey: ShaftKey.snapshot))
    }
    #endif

    @MainActor
    func test_seekFallsBackToLocalShelf() async throws {
        let store = makeStore(client: CatalogClient(carrier: FailingCarrier()))
        await store.load()
        let rows = try await store.seek("constable")
        XCTAssertEqual(rows.first?.title, CrateShelf.bundled.rows[0].title)
        XCTAssertGreaterThanOrEqual(rows.count, 8)
    }

    @MainActor
    func test_emptyQueryDoesNotHitNetwork() async throws {
        let log = RequestLog()
        let store = makeStore(client: CatalogClient(carrier: LoggingCarrier(log: log)))
        let rows = try await store.seek("   ")
        XCTAssertFalse(rows.isEmpty)
        let count = await log.count
        XCTAssertEqual(count, 0)
    }

    @MainActor
    private func makeStore(client: CatalogClient = CatalogClient(carrier: FailingCarrier())) -> ShaftStore {
        ShaftStore(
            directory: directory,
            suiteName: suiteName,
            client: client,
            picker: FixedInscriptionPicker(field: .title),
            shuffle: ReverseDrumShuffle(),
            shelf: .bundled,
            writeDelayNanoseconds: 0,
            seekDelayNanoseconds: 0
        )
    }

    @MainActor
    private func stackUntilRebuilt(_ store: ShaftStore) async throws {
        var steps = 0
        while store.shaft.canStack {
            steps += 1
            XCTAssertLessThan(steps, 12)
            let drum = try XCTUnwrap(store.shaft.spoil?.nextDrum)
            try await store.stackDrum(drum.id, now: now, calendar: calendar)
        }
    }
}

actor RequestLog {
    private var urls: [URL?] = []

    @discardableResult
    func append(_ url: URL?) -> Int {
        urls.append(url)
        return urls.count
    }

    var count: Int { urls.count }
}

struct FailingCarrier: CatalogCarrying {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.timedOut)
    }
}

struct LoggingCarrier: CatalogCarrying {
    let log: RequestLog

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        await log.append(request.url)
        throw URLError(.cannotConnectToHost)
    }
}

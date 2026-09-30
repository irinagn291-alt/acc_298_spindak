import Foundation
import Observation
import SwiftUI

/// Role: Shaft. Presentation fold over ShaftStore. Views call scatterPiece, stackDrum, missDrum, and peelNewestMark and never keep a second Anastylosis enum.
@MainActor
@Observable
final class ShaftChrome {
    let store: ShaftStore
    var isBooting: Bool
    var showsOnboarding: Bool
    var cover: ShaftCover?
    var recoveredNotice: Bool
    var isScattering: Bool
    var scatterBusy: Bool
    var isPeeling: Bool
    var peelBusy: Bool
    var stackBusy: UUID?
    var isSeeking: Bool
    var query: String
    var seekHits: [CatalogRow]
    var seekFault: String?
    var shaftFault: String?
    var crateNote: String?
    var stockingObjectID: String?
    var clampPulse: Int
    var showSuccess: Bool
    var dayStamp: Int
    private var cueConsumed: Bool
    private var seekTask: Task<Void, Never>?
    private var successTask: Task<Void, Never>?

    init(store: ShaftStore, isBooting: Bool = true) {
        self.store = store
        self.isBooting = isBooting
        self.showsOnboarding = false
        self.cover = nil
        self.recoveredNotice = false
        self.isScattering = false
        self.scatterBusy = false
        self.isPeeling = false
        self.peelBusy = false
        self.stackBusy = nil
        self.isSeeking = false
        self.query = ""
        self.seekHits = []
        self.seekFault = nil
        self.shaftFault = nil
        self.crateNote = nil
        self.stockingObjectID = nil
        self.clampPulse = 0
        self.showSuccess = false
        self.dayStamp = Daykey.stamp(Date(), calendar: .current)
        self.cueConsumed = false
    }

    static func live() -> ShaftChrome {
        ShaftChrome(store: ShaftStore())
    }

    var shaft: Shaft { store.shaft }
    var sign: ShaftSign { store.shaft.sign }
    var spoil: Spoil? { store.shaft.spoil }
    var hangingPiece: Piece? { store.shaft.hangingPiece }
    var rebuiltPieces: [Piece] { store.shaft.rebuiltPieces }
    var reviewableClamps: [ClampMark] { store.shaft.reviewableClamps }
    var reviewableSpalls: [SpallMark] { store.shaft.reviewableSpalls }

    var displayedPiece: Piece? {
        if let hanging = store.shaft.hangingPiece {
            return hanging
        }
        if let focused = store.shaft.focusedPieceID {
            return store.shaft.pieces.first { $0.id == focused }
        }
        return store.shaft.scatterPool.first ?? store.shaft.pieces.first
    }

    var canScatter: Bool {
        store.shaft.canScatter && !isScattering && !store.shaft.scatterPool.isEmpty
    }

    var canStack: Bool {
        store.shaft.canStack && stackBusy == nil
    }

    var canPeel: Bool {
        !store.shaft.peelLog.isEmpty && !isPeeling
    }

    var quizIsEmpty: Bool {
        store.shaft.sign == .waste
    }

    var savedIsEmpty: Bool {
        store.shaft.rebuiltPieces.isEmpty
            && store.shaft.reviewableClamps.isEmpty
            && store.shaft.reviewableSpalls.isEmpty
    }

    var exploreIsEmpty: Bool {
        seekHits.isEmpty && !isSeeking
    }

    var settingsIsEmpty: Bool {
        store.shaft.pieces.isEmpty
            && store.shaft.clampMarks.isEmpty
            && store.shaft.spallMarks.isEmpty
    }

    func boot() async {
        guard isBooting else { return }
        await store.load()
        await store.seedDemoIfNeeded()
        recoveredNotice = store.warning != nil
        showsOnboarding = !store.shaft.onboardingComplete
        isBooting = false
        if query.isEmpty {
            seekHits = store.shaft.fallbackRows(shelf: CrateShelf.bundled.rows)
        }
        if !showsOnboarding {
            consumeCue()
        }
    }

    func flush() async {
        await store.flush()
    }

    func refreshDay() {
        dayStamp = Daykey.stamp(Date(), calendar: .current)
    }

    func handle(phase: ScenePhase) async {
        switch phase {
        case .inactive, .background:
            await flush()
        case .active:
            refreshDay()
        @unknown default:
            break
        }
    }

    func finishOnboarding() async {
        await store.setOnboardingComplete(true)
        await store.flush()
        showsOnboarding = false
        consumeCue()
    }

    func replayOnboarding() {
        cover = nil
        showsOnboarding = true
        Task {
            await store.setOnboardingComplete(false)
            await store.flush()
        }
    }

    func present(_ cover: ShaftCover) {
        self.cover = cover
    }

    func handle(_ job: ShaftJob) {
        switch job {
        case .quiz:
            cover = nil
        case .stack:
            cover = nil
            Task { await stackFromIntent() }
        case .explore, .saved, .settings, .scatterStack:
            cover = job.cover
        }
    }

    func handle(url: URL) {
        guard let job = ShaftJob.parse(url) else { return }
        handle(job)
    }

    func scatterPiece() async {
        guard !isScattering else { return }
        isScattering = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { scatterBusy = true }
        }
        do {
            try await store.scatterPiece()
            shaftFault = nil
            showSuccess = false
        } catch {
            shaftFault = ShaftCopy.fault(error)
        }
        pulse.cancel()
        scatterBusy = false
        isScattering = false
    }

    func stackDrum(_ drumID: UUID) async {
        guard stackBusy == nil else { return }
        stackBusy = drumID
        do {
            try await store.stackDrum(drumID)
            clampPulse += 1
            flashSuccess()
            shaftFault = nil
        } catch ShaftFault.notNextWord {
            await missDrum(drumID)
        } catch {
            shaftFault = ShaftCopy.fault(error)
        }
        stackBusy = nil
    }

    func missDrum(_ drumID: UUID) async {
        do {
            try await store.missDrum(drumID)
            shaftFault = ShaftCopy.missStays
        } catch {
            shaftFault = ShaftCopy.fault(error)
        }
    }

    func tapDrum(_ drumID: UUID) async {
        guard stackBusy == nil else { return }
        stackBusy = drumID
        do {
            try await store.tapDrum(drumID)
            if case .laid(let spoil) = store.shaft.hanging, spoil.seated.contains(where: { $0.id == drumID }) {
                clampPulse += 1
                flashSuccess()
                shaftFault = nil
            } else if case .rebuilt(let spoil) = store.shaft.hanging, spoil.seated.contains(where: { $0.id == drumID }) {
                clampPulse += 1
                flashSuccess()
                shaftFault = nil
            } else {
                shaftFault = ShaftCopy.missStays
            }
        } catch {
            shaftFault = ShaftCopy.fault(error)
        }
        stackBusy = nil
    }

    func peelNewestMark() async {
        guard !isPeeling else { return }
        isPeeling = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { peelBusy = true }
        }
        do {
            try await store.peelNewestMark()
            shaftFault = nil
            showSuccess = false
        } catch {
            shaftFault = ShaftCopy.fault(error)
        }
        pulse.cancel()
        peelBusy = false
        isPeeling = false
    }

    func cratePiece(_ row: CatalogRow) async {
        guard stockingObjectID == nil else { return }
        stockingObjectID = row.objectID
        do {
            let focus = try await store.cratePiece(row)
            switch focus {
            case .inserted:
                crateNote = ShaftCopy.savedLoose
            case .focused:
                crateNote = ShaftCopy.alreadyCrate
            }
            shaftFault = nil
        } catch {
            crateNote = ShaftCopy.fault(error)
        }
        stockingObjectID = nil
    }

    func scheduleSeek() {
        seekTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        seekTask = Task { await seek(trimmed) }
    }

    func resetAllData() async {
        seekTask?.cancel()
        successTask?.cancel()
        await store.resetAllData()
        cover = nil
        query = ""
        seekHits = store.shaft.fallbackRows(shelf: CrateShelf.bundled.rows)
        seekFault = nil
        shaftFault = nil
        crateNote = nil
        recoveredNotice = false
        showSuccess = false
        showsOnboarding = true
        cueConsumed = true
    }

    func piece(for id: UUID?) -> Piece? {
        guard let id else { return nil }
        return store.shaft.pieces.first { $0.id == id }
    }

    func stackNextDrum() async {
        guard let next = store.shaft.spoil?.nextDrum else {
            shaftFault = ShaftCopy.stackNeedsScatter
            return
        }
        await stackDrum(next.id)
    }

    private func stackFromIntent() async {
        await stackNextDrum()
    }

    private func seek(_ trimmed: String) async {
        if trimmed.isEmpty {
            isSeeking = false
            seekFault = nil
            seekHits = store.shaft.fallbackRows(shelf: CrateShelf.bundled.rows)
            return
        }
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { isSeeking = true }
        }
        do {
            let rows = try await store.seek(trimmed)
            pulse.cancel()
            if Task.isCancelled { return }
            isSeeking = false
            seekHits = rows
            seekFault = rows.isEmpty ? ShaftCopy.searchMiss : nil
        } catch is CancellationError {
            pulse.cancel()
        } catch let fault as CatalogFault where fault == .cancelled {
            pulse.cancel()
        } catch {
            pulse.cancel()
            if Task.isCancelled { return }
            isSeeking = false
            seekHits = store.shaft.fallbackRows(shelf: CrateShelf.bundled.rows)
            seekFault = seekHits.isEmpty ? ShaftCopy.searchFail : ShaftCopy.fault(error)
        }
    }

    private func flashSuccess() {
        successTask?.cancel()
        showSuccess = true
        successTask = Task {
            try? await Task.sleep(for: .milliseconds(1200))
            if !Task.isCancelled {
                showSuccess = false
            }
        }
    }

    private func consumeCue() {
        if let hook = ShaftLinks.consume(
            arguments: ProcessInfo.processInfo.arguments,
            onboardingComplete: store.shaft.onboardingComplete,
            consumed: &cueConsumed
        ) {
            switch hook.sheet {
            case .quiz:
                cover = nil
            case .explore:
                cover = .explore
            case .saved:
                cover = .saved
            case .settings:
                cover = .settings
            }
        }
    }
}

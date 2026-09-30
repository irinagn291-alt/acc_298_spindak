import Foundation

/// Role: Shaft. In-memory fold over Pieces. Views call scatterPiece, stackDrum, missDrum, and peelNewestMark. Never a second Anastylosis enum.
struct Shaft: Equatable, Sendable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var pieces: [Piece]
    var hanging: ShaftHang
    var clampMarks: [ClampMark]
    var spallMarks: [SpallMark]
    var peelLog: [PeelRef]
    var cachedRows: [CatalogRow]
    var focusedPieceID: UUID?

    static let currentSchema = 1

    static let empty = Shaft(
        schemaVersion: currentSchema,
        onboardingComplete: false,
        pieces: [],
        hanging: .waste,
        clampMarks: [],
        spallMarks: [],
        peelLog: [],
        cachedRows: [],
        focusedPieceID: nil
    )

    var scatterPool: [Piece] {
        pieces.filter { !$0.anastylosis.isRebuilt }
    }

    var rebuiltPieces: [Piece] {
        pieces.filter(\.anastylosis.isRebuilt)
    }

    var reviewableSpalls: [SpallMark] {
        spallMarks
    }

    var reviewableClamps: [ClampMark] {
        clampMarks
    }

    var hangingPiece: Piece? {
        guard let spoil else { return nil }
        return pieces.first { $0.id == spoil.pieceID }
    }

    var spoil: Spoil? {
        switch hanging {
        case .waste, .spoil:
            return nil
        case .laid(let spoil), .rebuilt(let spoil):
            return spoil
        }
    }

    var sign: ShaftSign {
        switch hanging {
        case .waste:
            return .waste
        case .spoil:
            return .spoil
        case .laid:
            return .laid
        case .rebuilt:
            return .rebuilt
        }
    }

    var canScatter: Bool {
        if case .laid = hanging { return false }
        return true
    }

    var canStack: Bool {
        guard case .laid(let spoil) = hanging else { return false }
        return spoil.nextDrum != nil
    }

    mutating func scatterPiece(
        picker: any InscriptionPicking,
        shuffle: any DrumShuffling,
        drumIDs: [UUID]? = nil
    ) throws {
        if case .laid = hanging {
            throw ShaftFault.alreadyLaid
        }
        let pool = scatterPool.sorted { lhs, rhs in
            if lhs.daykey != rhs.daykey { return lhs.daykey < rhs.daykey }
            return lhs.objectID < rhs.objectID
        }
        for chosen in pool {
            let field = picker.field(for: chosen)
            let preferred = field.text(of: chosen)
            let resolved: InscriptionField
            if InscriptionField.qualifies(preferred) {
                resolved = field
            } else if InscriptionField.qualifies(field.toggled.text(of: chosen)) {
                resolved = field.toggled
            } else {
                continue
            }
            try applyScatter(chosen, field: resolved, shuffle: shuffle, drumIDs: drumIDs)
            return
        }
        hanging = .waste
    }

    @discardableResult
    mutating func stackDrum(
        _ drumID: UUID,
        markID: UUID = UUID(),
        now: Date,
        calendar: Calendar
    ) throws -> DrumStrike {
        switch hanging {
        case .waste, .spoil, .rebuilt:
            throw ShaftFault.stackOnSpoil
        case .laid(let spoil):
            guard spoil.isOnHeap(drumID) else {
                if spoil.seated.contains(where: { $0.id == drumID }) {
                    throw ShaftFault.alreadySeated
                }
                throw ShaftFault.unknownDrum
            }
            guard spoil.isNext(drumID) else {
                throw ShaftFault.notNextWord
            }
            return try fileClamp(drumID: drumID, spoil: spoil, markID: markID, now: now, calendar: calendar)
        }
    }

    @discardableResult
    mutating func missDrum(
        _ drumID: UUID,
        markID: UUID = UUID(),
        now: Date,
        calendar: Calendar
    ) throws -> DrumStrike {
        switch hanging {
        case .waste, .spoil, .rebuilt:
            throw ShaftFault.stackOnSpoil
        case .laid(let spoil):
            guard spoil.isOnHeap(drumID) else {
                if spoil.seated.contains(where: { $0.id == drumID }) {
                    throw ShaftFault.alreadySeated
                }
                throw ShaftFault.unknownDrum
            }
            if spoil.isNext(drumID) {
                throw ShaftFault.isNextWord
            }
            return try fileSpall(drumID: drumID, spoil: spoil, markID: markID, now: now, calendar: calendar)
        }
    }

    @discardableResult
    mutating func tapDrum(
        _ drumID: UUID,
        markID: UUID = UUID(),
        now: Date,
        calendar: Calendar
    ) throws -> DrumStrike {
        guard case .laid(let spoil) = hanging else {
            throw ShaftFault.stackOnSpoil
        }
        if spoil.isNext(drumID) {
            return try stackDrum(drumID, markID: markID, now: now, calendar: calendar)
        }
        return try missDrum(drumID, markID: markID, now: now, calendar: calendar)
    }

    mutating func peelNewestMark() throws {
        guard let last = peelLog.popLast() else {
            throw ShaftFault.nothingToPeel
        }
        switch last.kind {
        case .clamp:
            peelClamp(markID: last.markID, drumID: last.drumID)
        case .spall:
            peelSpall(markID: last.markID, drumID: last.drumID)
        }
    }

    @discardableResult
    mutating func cratePiece(
        _ row: CatalogRow,
        now: Date,
        calendar: Calendar,
        id: UUID = UUID()
    ) throws -> WriteFocus {
        let objectID = row.objectID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !objectID.isEmpty else { throw ShaftFault.emptyObjectID }
        if let existing = pieces.first(where: { $0.objectID == objectID }) {
            focusedPieceID = existing.id
            return .focused(existing.id)
        }
        var incoming = row
        incoming.objectID = objectID
        let piece = Piece.spoil(from: incoming, id: id, daykey: Daykey.stamp(now, calendar: calendar))
        pieces.append(piece)
        remember(incoming)
        focusedPieceID = piece.id
        if case .waste = hanging {
            hanging = .spoil
        }
        return .inserted(piece.id)
    }

    mutating func remember(_ rows: [CatalogRow]) {
        for row in rows {
            remember(row)
        }
    }

    mutating func remember(_ row: CatalogRow) {
        let objectID = row.objectID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !objectID.isEmpty else { return }
        var stored = row
        stored.objectID = objectID
        if let index = cachedRows.firstIndex(where: { $0.objectID == objectID }) {
            cachedRows[index] = stored
        } else {
            cachedRows.append(stored)
        }
    }

    mutating func setOnboardingComplete(_ flag: Bool) {
        onboardingComplete = flag
    }

    mutating func resetAllData() {
        self = .empty
    }

    func fallbackRows(shelf: [CatalogRow]) -> [CatalogRow] {
        var seen = Set<String>()
        var merged: [CatalogRow] = []
        let shelfByID = Dictionary(uniqueKeysWithValues: shelf.map { ($0.objectID, $0) })
        for row in cachedRows + shelf {
            var next = row
            if let fresh = shelfByID[row.objectID], let image = fresh.imageURLString, !image.isEmpty {
                next.imageURLString = image
            }
            if seen.insert(next.objectID).inserted {
                merged.append(next)
            }
        }
        return merged
    }

    mutating func applyShelfImages(_ shelf: [CatalogRow]) {
        let shelfByID = Dictionary(uniqueKeysWithValues: shelf.map { ($0.objectID, $0) })
        for index in pieces.indices {
            if let row = shelfByID[pieces[index].objectID], let image = row.imageURLString, !image.isEmpty {
                pieces[index].imageURLString = image
            }
        }
        for index in cachedRows.indices {
            if let row = shelfByID[cachedRows[index].objectID], let image = row.imageURLString, !image.isEmpty {
                cachedRows[index].imageURLString = image
            }
        }
    }

    private mutating func applyScatter(
        _ chosen: Piece,
        field: InscriptionField,
        shuffle: any DrumShuffling,
        drumIDs: [UUID]?
    ) throws {
        for index in pieces.indices where pieces[index].anastylosis == .laid && pieces[index].id != chosen.id {
            pieces[index].anastylosis = .spoil
        }
        guard let pieceIndex = pieces.firstIndex(where: { $0.id == chosen.id }) else {
            throw ShaftFault.unknownPiece
        }
        let spoil = try ScatterPress.make(
            piece: pieces[pieceIndex],
            field: field,
            shuffle: shuffle,
            drumIDs: drumIDs
        )
        pieces[pieceIndex].anastylosis = .laid
        hanging = .laid(spoil)
        focusedPieceID = chosen.id
    }

    private mutating func fileClamp(
        drumID: UUID,
        spoil: Spoil,
        markID: UUID,
        now: Date,
        calendar: Calendar
    ) throws -> DrumStrike {
        var next = spoil
        guard let drum = next.seat(drumID) else {
            throw ShaftFault.unknownDrum
        }
        guard let pieceIndex = pieces.firstIndex(where: { $0.id == next.pieceID }) else {
            throw ShaftFault.unknownPiece
        }
        let mark = ClampMark(
            id: markID,
            pieceID: next.pieceID,
            field: next.field,
            drumID: drum.id,
            word: drum.word,
            readingIndex: drum.readingIndex,
            daykey: Daykey.stamp(now, calendar: calendar)
        )
        clampMarks.append(mark)
        peelLog.append(PeelRef(kind: .clamp, drumID: drum.id, markID: markID))
        focusedPieceID = next.pieceID
        if next.isFullySeated {
            pieces[pieceIndex].anastylosis = .rebuilt
            hanging = .rebuilt(next)
        } else {
            pieces[pieceIndex].anastylosis = .laid
            hanging = .laid(next)
        }
        return .clamp(mark)
    }

    private mutating func fileSpall(
        drumID: UUID,
        spoil: Spoil,
        markID: UUID,
        now: Date,
        calendar: Calendar
    ) throws -> DrumStrike {
        guard let drum = spoil.drum(id: drumID) else {
            throw ShaftFault.unknownDrum
        }
        let mark = SpallMark(
            id: markID,
            pieceID: spoil.pieceID,
            field: spoil.field,
            drumID: drum.id,
            word: drum.word,
            readingIndex: drum.readingIndex,
            daykey: Daykey.stamp(now, calendar: calendar)
        )
        spallMarks.append(mark)
        peelLog.append(PeelRef(kind: .spall, drumID: drum.id, markID: markID))
        hanging = .laid(spoil)
        focusedPieceID = spoil.pieceID
        return .spall(mark)
    }

    private mutating func peelClamp(markID: UUID?, drumID: UUID?) {
        let mark: ClampMark?
        if let markID, let index = clampMarks.firstIndex(where: { $0.id == markID }) {
            mark = clampMarks.remove(at: index)
        } else if let drumID, let index = clampMarks.lastIndex(where: { $0.drumID == drumID }) {
            mark = clampMarks.remove(at: index)
        } else {
            mark = nil
        }
        let pieceID = mark?.pieceID ?? spoil?.pieceID
        if let pieceID, let pieceIndex = pieces.firstIndex(where: { $0.id == pieceID }) {
            if pieces[pieceIndex].anastylosis == .rebuilt {
                pieces[pieceIndex].anastylosis = .laid
            }
        }
        switch hanging {
        case .laid(var spoil) where pieceID == nil || spoil.pieceID == pieceID:
            _ = spoil.unseatNewest()
            hanging = .laid(spoil)
        case .rebuilt(var spoil) where pieceID == nil || spoil.pieceID == pieceID:
            _ = spoil.unseatNewest()
            hanging = .laid(spoil)
        default:
            break
        }
    }

    private mutating func peelSpall(markID: UUID?, drumID: UUID?) {
        if let markID, let index = spallMarks.firstIndex(where: { $0.id == markID }) {
            spallMarks.remove(at: index)
        } else if let drumID, let index = spallMarks.lastIndex(where: { $0.drumID == drumID }) {
            spallMarks.remove(at: index)
        }
    }
}

import XCTest
@testable import Anathyrosis

/// Family invariant: Quiz draws from saved works. Misses are reviewable. Collecting without a test is the crate clone.
final class FamilyInvariantTests: XCTestCase {
    private var calendar: Calendar { AnathyrosisGMT.calendar }
    private var now: Date { AnathyrosisGMT.instant(2026, 9, 19) }
    private var picker: FixedInscriptionPicker { FixedInscriptionPicker(field: .title) }
    private var shuffle: ReverseDrumShuffle { ReverseDrumShuffle() }
    private var shelf: [CatalogRow] { CrateShelf.bundled.rows }

    func test_quizDrawsFromSavedWorks_missesStayReviewable_stockingIsNotFiling() throws {
        var shaft = Shaft.empty
        XCTAssertFalse(shaft.canStack)
        XCTAssertEqual(shaft.sign, .waste)

        let row = shelf[0]
        let stocked = try shaft.cratePiece(row, now: now, calendar: calendar)
        guard case .inserted(let pieceID) = stocked else {
            return XCTFail("expected insert")
        }
        XCTAssertEqual(shaft.pieces.count, 1)
        XCTAssertEqual(shaft.pieces[0].anastylosis, .spoil)
        XCTAssertFalse(shaft.rebuiltPieces.contains { $0.id == pieceID })
        XCTAssertTrue(shaft.scatterPool.contains { $0.id == pieceID })
        XCTAssertFalse(shaft.canStack)
        XCTAssertEqual(shaft.sign, .spoil)

        try shaft.scatterPiece(picker: picker, shuffle: shuffle)
        XCTAssertEqual(shaft.hangingPiece?.id, pieceID)
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .laid)
        XCTAssertTrue(shaft.scatterPool.contains { $0.id == pieceID })
        XCTAssertTrue(shaft.canStack)
        XCTAssertEqual(shaft.spoil?.field, .title)
        XCTAssertEqual(shaft.spoil?.reading, InscriptionField.words(in: row.title))
        XCTAssertEqual(shaft.spoil?.heap.count, InscriptionField.words(in: row.title).count)
        XCTAssertEqual(Set(shaft.spoil?.heap.map(\.word) ?? []), Set(InscriptionField.words(in: row.title)))

        let miss = try XCTUnwrap(shaft.spoil?.heap.first { $0.readingIndex != 0 })
        let strike = try shaft.missDrum(miss.id, now: now, calendar: calendar)
        guard case .spall = strike else {
            return XCTFail("expected spall")
        }
        XCTAssertEqual(shaft.hangingPiece?.id, pieceID)
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .laid)
        XCTAssertEqual(shaft.reviewableSpalls.count, 1)
        XCTAssertEqual(shaft.reviewableSpalls.first?.pieceID, pieceID)
        XCTAssertEqual(shaft.sign, .laid)
        XCTAssertEqual(shaft.rebuiltPieces.count, 0)
        XCTAssertTrue(shaft.scatterPool.contains { $0.id == pieceID })
        XCTAssertTrue(shaft.spoil?.isOnHeap(miss.id) ?? false)
        XCTAssertEqual(shaft.spoil?.seated.count, 0)
    }

    func test_rebuiltPiecesLeaveTheScatterPool() throws {
        var shaft = try stockedAndScattered()
        let hangingID = try XCTUnwrap(shaft.hangingPiece?.id)
        try stackUntilRebuilt(&shaft)
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .rebuilt)
        XCTAssertEqual(shaft.rebuiltPieces.count, 1)
        XCTAssertFalse(shaft.scatterPool.contains { $0.id == hangingID })
        XCTAssertFalse(shaft.canStack)
        XCTAssertEqual(shaft.sign, .rebuilt)

        _ = try shaft.cratePiece(shelf[1], now: now, calendar: calendar)
        try shaft.scatterPiece(picker: picker, shuffle: shuffle)
        XCTAssertNotEqual(shaft.hangingPiece?.id, hangingID)
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .laid)
        XCTAssertTrue(shaft.scatterPool.contains { $0.id == shaft.hangingPiece?.id })
        XCTAssertFalse(shaft.scatterPool.contains { $0.id == hangingID })
    }

    private func stockedAndScattered() throws -> Shaft {
        var shaft = Shaft.empty
        _ = try shaft.cratePiece(shelf[0], now: now, calendar: calendar)
        try shaft.scatterPiece(picker: picker, shuffle: shuffle)
        return shaft
    }

    private func stackUntilRebuilt(_ shaft: inout Shaft) throws {
        var steps = 0
        while shaft.canStack {
            steps += 1
            XCTAssertLessThan(steps, 12)
            let drum = try XCTUnwrap(shaft.spoil?.nextDrum)
            _ = try shaft.stackDrum(drum.id, now: now, calendar: calendar)
        }
    }
}

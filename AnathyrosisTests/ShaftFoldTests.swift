import XCTest
@testable import Anathyrosis

final class ShaftFoldTests: XCTestCase {
    private var calendar: Calendar { AnathyrosisGMT.calendar }
    private var now: Date { AnathyrosisGMT.instant(2026, 9, 19) }
    private var titlePicker: FixedInscriptionPicker { FixedInscriptionPicker(field: .title) }
    private var makerPicker: FixedInscriptionPicker { FixedInscriptionPicker(field: .maker) }
    private var shuffle: ReverseDrumShuffle { ReverseDrumShuffle() }
    private var shelf: [CatalogRow] { CrateShelf.bundled.rows }

    func test_architecture_sampling_refuse_missKeep_lastStackFold_waste_duplicateFocus() throws {
        var idle = Shaft.empty
        XCTAssertThrowsError(try idle.stackDrum(UUID(), now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? ShaftFault, .stackOnSpoil)
        }
        try idle.scatterPiece(picker: titlePicker, shuffle: shuffle)
        XCTAssertEqual(foldLabel(idle.hanging), "waste")
        XCTAssertEqual(idle.sign, .waste)

        var shaft = try stockedAndScattered(picker: titlePicker)
        XCTAssertEqual(shaft.sign, .laid)
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .laid)
        let spoil = try XCTUnwrap(shaft.spoil)
        XCTAssertEqual(spoil.field, .title)
        XCTAssertEqual(spoil.reading, InscriptionField.words(in: shelf[0].title))
        XCTAssertEqual(spoil.heap.map(\.word), spoil.reading.reversed())
        XCTAssertEqual(Set(spoil.heap.map(\.word)).count, spoil.reading.count)

        XCTAssertThrowsError(try shaft.scatterPiece(picker: titlePicker, shuffle: shuffle)) { error in
            XCTAssertEqual(error as? ShaftFault, .alreadyLaid)
        }
        let hangingID = try XCTUnwrap(shaft.hangingPiece?.id)

        let miss = try XCTUnwrap(shaft.spoil?.heap.first { $0.readingIndex != 0 })
        _ = try shaft.missDrum(miss.id, now: now, calendar: calendar)
        XCTAssertEqual(shaft.hangingPiece?.id, hangingID)
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .laid)
        XCTAssertEqual(shaft.sign, .laid)
        XCTAssertTrue(shaft.spoil?.isOnHeap(miss.id) ?? false)
        XCTAssertEqual(shaft.reviewableSpalls.count, 1)
        XCTAssertEqual(shaft.rebuiltPieces.count, 0)

        try stackUntilRebuilt(&shaft)
        XCTAssertEqual(foldLabel(shaft.hanging), "rebuilt")
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .rebuilt)
        XCTAssertFalse(shaft.scatterPool.contains { $0.id == hangingID })
        XCTAssertEqual(shaft.sign, .rebuilt)
        XCTAssertEqual(shaft.reviewableClamps.count, spoil.reading.count)
        XCTAssertEqual(shaft.spoil?.seated.map(\.word), spoil.reading)

        try shaft.peelNewestMark()
        XCTAssertEqual(foldLabel(shaft.hanging), "laid")
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .laid)
        XCTAssertEqual(shaft.rebuiltPieces.count, 0)
        XCTAssertTrue(shaft.scatterPool.contains { $0.id == hangingID })
        XCTAssertTrue(shaft.canStack)
    }

    func test_primaryVerb_emptyPopulatedInvalid() throws {
        var empty = Shaft.empty
        try empty.scatterPiece(picker: titlePicker, shuffle: shuffle)
        XCTAssertEqual(empty.sign, .waste)
        XCTAssertFalse(empty.canStack)
        XCTAssertThrowsError(try empty.stackDrum(UUID(), now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? ShaftFault, .stackOnSpoil)
        }

        var shaft = try stockedAndScattered(picker: titlePicker)
        XCTAssertTrue(shaft.canStack)
        XCTAssertEqual(shaft.sign, .laid)
        XCTAssertFalse(shaft.spoil?.heap.isEmpty ?? true)

        XCTAssertThrowsError(try shaft.stackDrum(UUID(), now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? ShaftFault, .unknownDrum)
        }
        let miss = try XCTUnwrap(shaft.spoil?.heap.first { $0.readingIndex != 0 })
        XCTAssertThrowsError(try shaft.stackDrum(miss.id, now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? ShaftFault, .notNextWord)
        }
        let hit = try XCTUnwrap(shaft.spoil?.nextDrum)
        _ = try shaft.stackDrum(hit.id, now: now, calendar: calendar)
        XCTAssertThrowsError(try shaft.stackDrum(hit.id, now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? ShaftFault, .alreadySeated)
        }
        XCTAssertThrowsError(try empty.peelNewestMark()) { error in
            XCTAssertEqual(error as? ShaftFault, .nothingToPeel)
        }
    }

    func test_twist_scatterThenStack_xorField_duplicateObjectIDFocuses_thinFieldSkipped() throws {
        var titleShaft = try stockedAndScattered(picker: titlePicker)
        XCTAssertEqual(titleShaft.spoil?.field, .title)
        XCTAssertEqual(titleShaft.spoil?.reading.joined(separator: " ").contains(" "), true)

        let makerShaft = try stockedAndScattered(picker: makerPicker, row: shelf[1])
        XCTAssertEqual(makerShaft.spoil?.field, .maker)
        XCTAssertEqual(makerShaft.hangingPiece?.maker, shelf[1].maker)
        XCTAssertEqual(makerShaft.spoil?.reading, InscriptionField.words(in: shelf[1].maker))

        try stackUntilRebuilt(&titleShaft)
        XCTAssertEqual(titleShaft.hangingPiece?.anastylosis, .rebuilt)

        let again = try titleShaft.cratePiece(shelf[0], now: now, calendar: calendar)
        guard case .focused(let id) = again else {
            return XCTFail("expected focus")
        }
        XCTAssertEqual(id, titleShaft.pieces[0].id)
        XCTAssertEqual(titleShaft.pieces.count, 1)
        XCTAssertEqual(titleShaft.pieces[0].anastylosis, .rebuilt)
        XCTAssertEqual(titleShaft.focusedPieceID, id)
        XCTAssertEqual(foldLabel(titleShaft.hanging), "rebuilt")

        _ = try titleShaft.cratePiece(shelf[1], now: now, calendar: calendar)
        XCTAssertEqual(titleShaft.pieces.count, 2)
        try titleShaft.scatterPiece(picker: titlePicker, shuffle: shuffle)
        XCTAssertNotEqual(titleShaft.hangingPiece?.anastylosis, .rebuilt)
        XCTAssertEqual(titleShaft.hangingPiece?.anastylosis, .laid)
        XCTAssertNotEqual(titleShaft.hangingPiece?.objectID, shelf[0].objectID)

        XCTAssertThrowsError(
            try ScatterPress.make(
                piece: Piece.spoil(
                    from: CatalogRow(
                        objectID: "O00001",
                        maker: "Turner",
                        title: "Venice",
                        imageURLString: CatalogClient.iiifThumb(imageID: "2006AG0000"),
                        dated: "1840"
                    ),
                    daykey: 20260919
                ),
                field: .title,
                shuffle: shuffle
            )
        ) { error in
            XCTAssertEqual(error as? ShaftFault, .thinField)
        }

        var thin = Shaft.empty
        _ = try thin.cratePiece(
            CatalogRow(
                objectID: "O00001",
                maker: "Turner",
                title: "Venice",
                imageURLString: CatalogClient.iiifThumb(imageID: "2006AG0000"),
                dated: "1840"
            ),
            now: now,
            calendar: calendar
        )
        try thin.scatterPiece(picker: titlePicker, shuffle: shuffle)
        XCTAssertEqual(thin.sign, .waste)
        XCTAssertFalse(thin.canStack)
    }

    func test_seedPaintsLiveHeapAndEnablesStack() {
        let shaft = ShaftSeed.shaft(now: now, calendar: calendar, picker: titlePicker, shuffle: shuffle, shelf: shelf)
        XCTAssertTrue(shaft.onboardingComplete)
        XCTAssertTrue(shaft.canStack)
        XCTAssertEqual(shaft.hangingPiece?.anastylosis, .laid)
        XCTAssertEqual(foldLabel(shaft.hanging), "laid")
        XCTAssertGreaterThanOrEqual(shaft.pieces.count, 6)
        XCTAssertGreaterThanOrEqual(shaft.rebuiltPieces.count, 2)
        XCTAssertGreaterThanOrEqual(shaft.reviewableSpalls.count, 3)
        XCTAssertGreaterThanOrEqual(shaft.scatterPool.count, 3)
        XCTAssertNotEqual(shaft.sign, .waste)
        XCTAssertFalse(shaft.spoil?.heap.isEmpty ?? true)
        XCTAssertEqual(shaft.spoil?.seated.isEmpty, true)
        XCTAssertNotEqual(shaft.spoil?.heap.map(\.word), shaft.spoil?.reading)
    }

    func test_daykeyIsYYYYMMDDFromStartOfDay() {
        let late = AnathyrosisGMT.instant(2026, 9, 19, hour: 23)
        let next = AnathyrosisGMT.instant(2026, 9, 20, hour: 1)
        XCTAssertEqual(Daykey.stamp(late, calendar: calendar), 20260919)
        XCTAssertEqual(Daykey.stamp(next, calendar: calendar), 20260920)
        XCTAssertEqual(Daykey.shifting(20260919, by: -1, calendar: calendar), 20260918)
    }

    func test_samplesOnlyNotRebuiltPieces() throws {
        var shaft = try stockedAndScattered(picker: titlePicker)
        let firstID = try XCTUnwrap(shaft.hangingPiece?.id)
        try stackUntilRebuilt(&shaft)
        _ = try shaft.cratePiece(shelf[1], now: now, calendar: calendar)
        try shaft.scatterPiece(picker: titlePicker, shuffle: shuffle)
        XCTAssertNotEqual(shaft.hangingPiece?.id, firstID)
        XCTAssertNotEqual(shaft.hangingPiece?.anastylosis, .rebuilt)
        XCTAssertFalse(shaft.rebuiltPieces.contains { $0.id == shaft.hangingPiece?.id })
    }

    func test_spallThenUndoKeepsTheDrumOnTheHeap() throws {
        var shaft = try stockedAndScattered(picker: titlePicker)
        let miss = try XCTUnwrap(shaft.spoil?.heap.first { $0.readingIndex != 0 })
        _ = try shaft.missDrum(miss.id, now: now, calendar: calendar)
        XCTAssertEqual(shaft.reviewableSpalls.count, 1)
        try shaft.peelNewestMark()
        XCTAssertEqual(shaft.reviewableSpalls.count, 0)
        XCTAssertTrue(shaft.spoil?.isOnHeap(miss.id) ?? false)
        XCTAssertEqual(shaft.sign, .laid)
    }

    func test_drumsAreMakerXORTitleWithNoDecoys() throws {
        XCTAssertTrue(InscriptionField.qualifies("Salisbury Cathedral from the Close"))
        XCTAssertFalse(InscriptionField.qualifies("Venice"))
        XCTAssertFalse(InscriptionField.qualifies("Turner"))
        let words = InscriptionField.words(in: "Salisbury Cathedral from the Close")
        XCTAssertEqual(words, ["Salisbury", "Cathedral", "from", "the", "Close"])
        let spoil = try ScatterPress.make(
            piece: Piece.spoil(from: shelf[0], daykey: 20260919),
            field: .title,
            shuffle: shuffle
        )
        XCTAssertEqual(Set(spoil.heap.map(\.word)), Set(words))
        XCTAssertEqual(spoil.heap.count, words.count)
        XCTAssertEqual(spoil.heap.map(\.word), words.reversed())
    }

    func test_missOnNextWordIsRefusedAndTapRoutes() throws {
        var shaft = try stockedAndScattered(picker: titlePicker)
        let next = try XCTUnwrap(shaft.spoil?.nextDrum)
        XCTAssertThrowsError(try shaft.missDrum(next.id, now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? ShaftFault, .isNextWord)
        }
        let strike = try shaft.tapDrum(next.id, now: now, calendar: calendar)
        guard case .clamp = strike else {
            return XCTFail("expected clamp")
        }
        XCTAssertEqual(shaft.spoil?.seated.last?.id, next.id)
    }

    private func stockedAndScattered(
        picker: FixedInscriptionPicker,
        row: CatalogRow? = nil
    ) throws -> Shaft {
        var shaft = Shaft.empty
        _ = try shaft.cratePiece(row ?? shelf[0], now: now, calendar: calendar)
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

    private func foldLabel(_ hang: ShaftHang) -> String {
        switch hang {
        case .waste:
            return "waste"
        case .spoil:
            return "spoil"
        case .laid:
            return "laid"
        case .rebuilt:
            return "rebuilt"
        }
    }
}

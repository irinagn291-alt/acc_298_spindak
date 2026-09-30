import Foundation

/// Role: Shaft. Simulator demo crate. Device never writes this. Key: ahy.demo.v1. Lays one jumbled inscription so the first Drum can stack. Never Waste.
enum ShaftSeed {
    private static func fixed(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }

    static func shaft(
        now: Date = Date(),
        calendar: Calendar = .current,
        picker: any InscriptionPicking = FixedInscriptionPicker(field: .title),
        shuffle: any DrumShuffling = ReverseDrumShuffle(),
        shelf: [CatalogRow] = CrateShelf.bundled.rows
    ) -> Shaft {
        let today = Daykey.stamp(now, calendar: calendar)
        let rows = shelf
        func piece(_ row: CatalogRow, id: UUID, fold: Anastylosis, dayOffset: Int) -> Piece {
            var item = Piece.spoil(from: row, id: id, daykey: Daykey.shifting(today, by: dayOffset, calendar: calendar))
            item.anastylosis = fold
            return item
        }

        let salisbury = piece(rows[0], id: fixed("AAAAAAAA-0001-4000-8000-000000000001"), fold: .laid, dayOffset: 0)
        let venice = piece(rows[1], id: fixed("AAAAAAAA-0001-4000-8000-000000000002"), fold: .rebuilt, dayOffset: -1)
        let dayDream = piece(rows[2], id: fixed("AAAAAAAA-0001-4000-8000-000000000003"), fold: .rebuilt, dayOffset: -2)
        let pizarro = piece(rows[3], id: fixed("AAAAAAAA-0001-4000-8000-000000000004"), fold: .spoil, dayOffset: -3)
        let branch = piece(rows[4], id: fixed("AAAAAAAA-0001-4000-8000-000000000005"), fold: .spoil, dayOffset: -4)
        let cowes = piece(rows[5], id: fixed("AAAAAAAA-0001-4000-8000-000000000006"), fold: .rebuilt, dayOffset: -5)
        let mill = piece(rows[6], id: fixed("AAAAAAAA-0001-4000-8000-000000000007"), fold: .spoil, dayOffset: -6)
        let fishing = piece(rows[7], id: fixed("AAAAAAAA-0001-4000-8000-000000000008"), fold: .spoil, dayOffset: -7)

        let pieces = [salisbury, venice, dayDream, pizarro, branch, cowes, mill, fishing]
        let liveIDs = [
            fixed("EEEEEEEE-0001-4000-8000-000000000001"),
            fixed("EEEEEEEE-0001-4000-8000-000000000002"),
            fixed("EEEEEEEE-0001-4000-8000-000000000003"),
            fixed("EEEEEEEE-0001-4000-8000-000000000004"),
            fixed("EEEEEEEE-0001-4000-8000-000000000005"),
        ]
        let live = (try? ScatterPress.make(
            piece: salisbury,
            field: picker.field(for: salisbury),
            shuffle: shuffle,
            drumIDs: liveIDs
        )) ?? Spoil(
            pieceID: salisbury.id,
            field: .title,
            reading: InscriptionField.words(in: salisbury.title),
            heap: [],
            seated: []
        )

        let veniceSpoil = (try? ScatterPress.make(
            piece: venice,
            field: .title,
            shuffle: IdentityDrumShuffle()
        )) ?? live
        let dayDreamSpoil = (try? ScatterPress.make(
            piece: dayDream,
            field: .title,
            shuffle: IdentityDrumShuffle()
        )) ?? live
        let cowesSpoil = (try? ScatterPress.make(
            piece: cowes,
            field: .title,
            shuffle: IdentityDrumShuffle()
        )) ?? live

        let clampMarks = [
            ClampMark(
                id: fixed("BBBBBBBB-0001-4000-8000-000000000001"),
                pieceID: venice.id,
                field: .title,
                drumID: veniceSpoil.heap.first?.id ?? fixed("EEEEEEEE-0001-4000-8000-000000000011"),
                word: veniceSpoil.reading.first ?? "Venice",
                readingIndex: 0,
                daykey: venice.daykey
            ),
            ClampMark(
                id: fixed("BBBBBBBB-0001-4000-8000-000000000002"),
                pieceID: venice.id,
                field: .title,
                drumID: veniceSpoil.heap.dropFirst().first?.id ?? fixed("EEEEEEEE-0001-4000-8000-000000000012"),
                word: veniceSpoil.reading.dropFirst().first ?? "from",
                readingIndex: 1,
                daykey: venice.daykey
            ),
            ClampMark(
                id: fixed("BBBBBBBB-0001-4000-8000-000000000003"),
                pieceID: dayDream.id,
                field: .title,
                drumID: dayDreamSpoil.heap.first?.id ?? fixed("EEEEEEEE-0001-4000-8000-000000000013"),
                word: dayDreamSpoil.reading.first ?? "The",
                readingIndex: 0,
                daykey: dayDream.daykey
            ),
            ClampMark(
                id: fixed("BBBBBBBB-0001-4000-8000-000000000004"),
                pieceID: cowes.id,
                field: .title,
                drumID: cowesSpoil.heap.first?.id ?? fixed("EEEEEEEE-0001-4000-8000-000000000014"),
                word: cowesSpoil.reading.first ?? "East",
                readingIndex: 0,
                daykey: cowes.daykey
            ),
        ]
        let spallMarks = [
            SpallMark(
                id: fixed("DDDDDDDD-0001-4000-8000-000000000001"),
                pieceID: venice.id,
                field: .title,
                drumID: fixed("FFFFFFFF-0001-4000-8000-000000000001"),
                word: "Giudecca",
                readingIndex: 3,
                daykey: venice.daykey
            ),
            SpallMark(
                id: fixed("DDDDDDDD-0001-4000-8000-000000000002"),
                pieceID: dayDream.id,
                field: .title,
                drumID: fixed("FFFFFFFF-0001-4000-8000-000000000002"),
                word: "Dream",
                readingIndex: 2,
                daykey: dayDream.daykey
            ),
            SpallMark(
                id: fixed("DDDDDDDD-0001-4000-8000-000000000003"),
                pieceID: cowes.id,
                field: .title,
                drumID: fixed("FFFFFFFF-0001-4000-8000-000000000003"),
                word: "Castle",
                readingIndex: 2,
                daykey: cowes.daykey
            ),
            SpallMark(
                id: fixed("DDDDDDDD-0001-4000-8000-000000000004"),
                pieceID: pizarro.id,
                field: .title,
                drumID: fixed("FFFFFFFF-0001-4000-8000-000000000004"),
                word: "Inca",
                readingIndex: 3,
                daykey: pizarro.daykey
            ),
        ]
        return Shaft(
            schemaVersion: Shaft.currentSchema,
            onboardingComplete: true,
            pieces: pieces,
            hanging: .laid(live),
            clampMarks: clampMarks,
            spallMarks: spallMarks,
            peelLog: [],
            cachedRows: Array(rows.prefix(8)),
            focusedPieceID: salisbury.id
        )
    }
}

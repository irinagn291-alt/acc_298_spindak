import Foundation

/// Role: Drum. QuizCard. One inscription word from maker XOR title. No decoys. The heap is only these stones.
struct Drum: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var word: String
    var readingIndex: Int
}

/// Role: Drum. Maker XOR title. Never both fields on one Scatter.
enum InscriptionField: String, Equatable, Sendable, Codable {
    case maker
    case title

    var toggled: InscriptionField {
        self == .maker ? .title : .maker
    }

    func text(of piece: Piece) -> String {
        switch self {
        case .maker:
            return piece.maker
        case .title:
            return piece.title
        }
    }

    static func words(in text: String) -> [String] {
        text.split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    static func qualifies(_ text: String) -> Bool {
        words(in: text).count >= 2
    }
}

/// Role: Drum. Picks maker XOR title for this Scatter.
protocol InscriptionPicking: Sendable {
    func field(for piece: Piece) -> InscriptionField
}

struct AlternatingInscriptionPicker: InscriptionPicking {
    func field(for piece: Piece) -> InscriptionField {
        let preferred: InscriptionField = piece.id.uuid.0.isMultiple(of: 2) ? .maker : .title
        if InscriptionField.qualifies(preferred.text(of: piece)) {
            return preferred
        }
        return preferred.toggled
    }
}

struct FixedInscriptionPicker: InscriptionPicking {
    var field: InscriptionField

    func field(for piece: Piece) -> InscriptionField {
        _ = piece
        return field
    }
}

/// Role: Drum. Jumbles the spoil heap. Tests pin order through this seam.
protocol DrumShuffling: Sendable {
    func shuffle(_ drums: [Drum]) -> [Drum]
}

struct ReverseDrumShuffle: DrumShuffling {
    func shuffle(_ drums: [Drum]) -> [Drum] {
        Array(drums.reversed())
    }
}

struct IdentityDrumShuffle: DrumShuffling {
    func shuffle(_ drums: [Drum]) -> [Drum] {
        drums
    }
}

struct SaltDrumShuffle: DrumShuffling {
    var salt: Int

    func shuffle(_ drums: [Drum]) -> [Drum] {
        var items = drums
        guard items.count > 1 else { return items }
        var state = UInt64(bitPattern: Int64(salt))
        if state == 0 { state = 1 }
        for index in stride(from: items.count - 1, through: 1, by: -1) {
            state = state &* 6_364_136_223_846_793_005 &+ 1
            let other = Int(state % UInt64(index + 1))
            items.swapAt(index, other)
        }
        return items
    }
}

/// Role: Drum. Builds a live spoil heap from a Piece field. Tests pin heap order through DrumShuffling.
enum ScatterPress {
    static func make(
        piece: Piece,
        field: InscriptionField,
        shuffle: any DrumShuffling,
        drumIDs: [UUID]? = nil
    ) throws -> Spoil {
        let words = InscriptionField.words(in: field.text(of: piece))
        guard words.count >= 2 else {
            throw ShaftFault.thinField
        }
        let drums: [Drum] = words.enumerated().map { offset, word in
            let id: UUID
            if let drumIDs, offset < drumIDs.count {
                id = drumIDs[offset]
            } else {
                id = UUID()
            }
            return Drum(id: id, word: word, readingIndex: offset)
        }
        return Spoil(
            pieceID: piece.id,
            field: field,
            reading: words,
            heap: shuffle.shuffle(drums),
            seated: []
        )
    }
}

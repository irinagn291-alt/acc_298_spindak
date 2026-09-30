import Foundation

/// Role: Anastylosis. Closed algebraic fold Spoil, Laid, or Rebuilt. A fourth case is a defect. Stored on Piece; rebuilt-ness is not a parallel bool.
enum Anastylosis: String, Equatable, Sendable, Codable {
    case spoil
    case laid
    case rebuilt

    var isRebuilt: Bool { self == .rebuilt }
}

/// Role: Shaft. Status chrome. Waste is a shaft write, never a fourth Anastylosis case.
enum ShaftSign: String, Codable, Sendable, Equatable {
    case waste
    case spoil
    case laid
    case rebuilt
}

/// Role: Shaft. Hanging of the fold over Pieces. Waste is a shaft write, never a fourth Anastylosis case.
enum ShaftHang: Equatable, Sendable {
    case waste
    case spoil
    case laid(Spoil)
    case rebuilt(Spoil)
}

extension ShaftHang: Codable {
    enum Kind: String, Codable, Sendable {
        case waste
        case spoil
        case laid
        case rebuilt
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case spoil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .waste:
            try container.encode(Kind.waste, forKey: .kind)
        case .spoil:
            try container.encode(Kind.spoil, forKey: .kind)
        case .laid(let spoil):
            try container.encode(Kind.laid, forKey: .kind)
            try container.encode(spoil, forKey: .spoil)
        case .rebuilt(let spoil):
            try container.encode(Kind.rebuilt, forKey: .kind)
            try container.encode(spoil, forKey: .spoil)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .waste:
            self = .waste
        case .spoil:
            self = .spoil
        case .laid:
            self = .laid(try container.decode(Spoil.self, forKey: .spoil))
        case .rebuilt:
            self = .rebuilt(try container.decode(Spoil.self, forKey: .spoil))
        }
    }
}

/// Role: Shaft. Typed refusals of Scatter, Stack, Miss, and Undo. Views map these.
enum ShaftFault: Error, Equatable, Sendable {
    case stackOnSpoil
    case alreadyLaid
    case thinField
    case unknownDrum
    case notNextWord
    case isNextWord
    case alreadySeated
    case nothingToPeel
    case emptyObjectID
    case unknownPiece
}

/// Role: Shaft. Ordered undo stack. Undo peels the newest ClampMark or SpallMark.
enum PeelKind: String, Codable, Sendable {
    case clamp
    case spall
}

struct PeelRef: Equatable, Sendable, Codable {
    var kind: PeelKind
    var drumID: UUID?
    var markID: UUID?
}

/// Role: Shaft. Explore save outcome. Duplicate object id focuses and does not reset Anastylosis.
enum WriteFocus: Equatable, Sendable {
    case inserted(UUID)
    case focused(UUID)
}

/// Role: Shaft. Recoverable load outcome. Never crash on a corrupt snapshot.
enum ShaftWarning: Equatable, Sendable {
    case recoveredFromBackup
    case startedEmpty
}

/// Role: Shaft. Strike of one Drum. Clamp seats the next word. Spall keeps the Shaft.
enum DrumStrike: Equatable, Sendable {
    case clamp(ClampMark)
    case spall(SpallMark)
}

import Foundation

/// Role: ClampMark. True Stack on the next Drum in reading order. Seats that stone on the Shaft. The last true Stack folds Laid to Rebuilt.
struct ClampMark: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var pieceID: UUID
    var field: InscriptionField
    var drumID: UUID
    var word: String
    var readingIndex: Int
    var daykey: Int
}

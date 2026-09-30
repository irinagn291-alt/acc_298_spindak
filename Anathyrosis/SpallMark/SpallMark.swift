import Foundation

/// Role: SpallMark. Miss on a Drum out of reading order. Keeps the Shaft and leaves that Drum on the heap. Reviewable on Saved.
struct SpallMark: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var pieceID: UUID
    var field: InscriptionField
    var drumID: UUID
    var word: String
    var readingIndex: Int
    var daykey: Int
}

import Foundation

/// Role: Spoil. Live inscription: maker XOR title split on whitespace, jumbled on the heap, seated in reading order on the Shaft.
struct Spoil: Equatable, Sendable, Codable {
    var pieceID: UUID
    var field: InscriptionField
    var reading: [String]
    var heap: [Drum]
    var seated: [Drum]

    var nextIndex: Int { seated.count }

    var nextWord: String? {
        guard reading.indices.contains(nextIndex) else { return nil }
        return reading[nextIndex]
    }

    var nextDrum: Drum? {
        heap.first { $0.readingIndex == nextIndex }
    }

    var isFullySeated: Bool {
        seated.count == reading.count && !reading.isEmpty
    }

    func drum(id: UUID) -> Drum? {
        heap.first { $0.id == id } ?? seated.first { $0.id == id }
    }

    func isOnHeap(_ id: UUID) -> Bool {
        heap.contains { $0.id == id }
    }

    func isNext(_ id: UUID) -> Bool {
        heap.contains { $0.id == id && $0.readingIndex == nextIndex }
    }

    mutating func seat(_ id: UUID) -> Drum? {
        guard let index = heap.firstIndex(where: { $0.id == id }) else { return nil }
        let drum = heap.remove(at: index)
        seated.append(drum)
        return drum
    }

    mutating func unseatNewest() -> Drum? {
        guard let drum = seated.popLast() else { return nil }
        heap.append(drum)
        return drum
    }
}

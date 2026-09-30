import SwiftUI

/// Role: Piece. Saved sheet. Rebuilt paintings plus ClampMarks and SpallMarks.
struct SavedView: View {
    @Bindable var chrome: ShaftChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var pick: SavedPick?

    var body: some View {
        ShaftSheetHost {
            NavigationStack {
                Group {
                    if chrome.savedIsEmpty {
                        emptyPage
                    } else if sizeClass == .regular {
                        wideLog
                    } else {
                        compactLog
                    }
                }
                .background(ShaftInk.background.ignoresSafeArea())
                .navigationTitle("Saved paintings")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(item: $pick) { destination in
                    SavedEntryView(chrome: chrome, pick: destination)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(ShaftType.font(.headline, size: typeSize))
                                .foregroundStyle(ShaftInk.ink)
                                .frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(ShaftIconStyle())
                        .accessibilityLabel("Close")
                    }
                }
            }
        }
    }

    private var emptyPage: some View {
        WastePage(
            art: ShaftArt.emptyList,
            headline: ShaftCopy.savedEmptyHeadline,
            line: ShaftCopy.savedEmptyLine,
            actionTitle: "Back to the shaft"
        ) {
            dismiss()
        }
    }

    private var compactLog: some View {
        List {
            rebuiltSection
            clampsSection
            spallsSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, ShaftSpace.outer)
    }

    private var wideLog: some View {
        HStack(alignment: .top, spacing: 0) {
            List {
                rebuiltSection
                clampsSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            List {
                spallsSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .contentMargins(.bottom, ShaftSpace.outer)
    }

    @ViewBuilder
    private var rebuiltSection: some View {
        if chrome.rebuiltPieces.isEmpty == false {
            Section {
                ForEach(chrome.rebuiltPieces) { piece in
                    Button {
                        pick = .rebuilt(piece.id)
                    } label: {
                        HStack(alignment: .center, spacing: ShaftSpace.card) {
                            PiecePlate(
                                title: piece.title,
                                maker: piece.maker,
                                url: piece.imageURL,
                                prominence: .row
                            )
                            .frame(width: ShaftSpace.step(8), height: ShaftSpace.step(8))
                            .clipped()
                            VStack(alignment: .leading, spacing: ShaftSpace.inner) {
                                Text(piece.title)
                                    .font(ShaftType.font(.headline, size: typeSize))
                                    .foregroundStyle(ShaftInk.ink)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Text(piece.maker)
                                    .font(ShaftType.font(.body, size: typeSize))
                                    .foregroundStyle(ShaftInk.muted)
                                    .lineLimit(1)
                                Text(ShaftFigures.daykey(piece.daykey))
                                    .font(ShaftType.font(.caption, size: typeSize))
                                    .foregroundStyle(ShaftInk.muted)
                                    .monospacedDigit()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, ShaftSpace.inner)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(piece.title), \(piece.maker), rebuilt \(ShaftFigures.daykey(piece.daykey))")
                    .listRowBackground(ShaftInk.surface)
                }
            } header: {
                Text("Rebuilt")
            }
        }
    }

    @ViewBuilder
    private var clampsSection: some View {
        let groups = SavedMarkGroup.named(from: chrome.reviewableClamps, chrome: chrome)
        if groups.isEmpty == false {
            Section {
                ForEach(groups) { group in
                    Button {
                        pick = .clamp(group.firstID)
                    } label: {
                        markLabel(
                            headline: ShaftCopy.namedSummary(painting: group.painting, count: group.count),
                            line: group.count == 1
                                ? "One correct word on this painting."
                                : "\(ShaftFigures.whole(group.count)) correct words on this painting.",
                            stamp: ShaftFigures.daykey(group.daykey)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(ShaftCopy.namedSummary(painting: group.painting, count: group.count))
                    .listRowBackground(ShaftInk.surface)
                }
            } header: {
                Text("Named")
            }
        }
    }

    @ViewBuilder
    private var spallsSection: some View {
        let groups = SavedMarkGroup.missed(from: chrome.reviewableSpalls, chrome: chrome)
        if groups.isEmpty == false {
            Section {
                ForEach(groups) { group in
                    Button {
                        pick = .spall(group.firstID)
                    } label: {
                        markLabel(
                            headline: ShaftCopy.missedSummary(painting: group.painting, count: group.count),
                            line: group.count == 1
                                ? "One missed word on this painting."
                                : "\(ShaftFigures.whole(group.count)) missed words on this painting.",
                            stamp: ShaftFigures.daykey(group.daykey)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(ShaftCopy.missedSummary(painting: group.painting, count: group.count))
                    .listRowBackground(ShaftInk.surface)
                }
            } header: {
                Text("Missed")
            }
        }
    }

    private func markLabel(headline: String, line: String, stamp: String) -> some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            Text(headline)
                .font(ShaftType.font(.headline, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text(stamp)
                .font(ShaftType.font(.caption, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .monospacedDigit()
        }
        .padding(.vertical, ShaftSpace.inner)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

@MainActor
private struct SavedMarkGroup: Identifiable {
    let id: UUID
    let firstID: UUID
    let painting: String
    let count: Int
    let daykey: Int

    static func named(from marks: [ClampMark], chrome: ShaftChrome) -> [SavedMarkGroup] {
        collapse(marks.map { ($0.pieceID, $0.id, $0.daykey) }, chrome: chrome)
    }

    static func missed(from marks: [SpallMark], chrome: ShaftChrome) -> [SavedMarkGroup] {
        collapse(marks.map { ($0.pieceID, $0.id, $0.daykey) }, chrome: chrome)
    }

    private static func collapse(
        _ rows: [(UUID, UUID, Int)],
        chrome: ShaftChrome
    ) -> [SavedMarkGroup] {
        var order: [UUID] = []
        var bag: [UUID: (firstID: UUID, count: Int, daykey: Int)] = [:]
        for row in rows {
            if var seen = bag[row.0] {
                seen.count += 1
                seen.daykey = max(seen.daykey, row.2)
                bag[row.0] = seen
            } else {
                order.append(row.0)
                bag[row.0] = (row.1, 1, row.2)
            }
        }
        return order.compactMap { pieceID in
            guard let seen = bag[pieceID] else { return nil }
            return SavedMarkGroup(
                id: pieceID,
                firstID: seen.firstID,
                painting: chrome.piece(for: pieceID)?.title ?? "",
                count: seen.count,
                daykey: seen.daykey
            )
        }
    }
}

enum SavedPick: Hashable, Identifiable {
    case rebuilt(UUID)
    case clamp(UUID)
    case spall(UUID)

    var id: String {
        switch self {
        case .rebuilt(let id):
            return "rebuilt-\(id.uuidString)"
        case .clamp(let id):
            return "clamp-\(id.uuidString)"
        case .spall(let id):
            return "spall-\(id.uuidString)"
        }
    }
}

/// Role: Piece. One rebuilt painting or one saved mark.
struct SavedEntryView: View {
    @Bindable var chrome: ShaftChrome
    let pick: SavedPick
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ShaftSpace.card) {
                if let piece {
                    PiecePlate(
                        title: piece.title,
                        maker: piece.maker,
                        url: piece.imageURL,
                        prominence: .row
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: ShaftSpace.step(22))
                    .clipped()
                }
                Text(headline)
                    .font(ShaftType.font(.title, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(line)
                    .font(ShaftType.font(.body, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(stamp)
                    .font(ShaftType.font(.caption, size: typeSize))
                    .foregroundStyle(ShaftInk.muted)
                    .monospacedDigit()
            }
            .padding(ShaftSpace.outer)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ShaftInk.background.ignoresSafeArea())
        .navigationTitle(kindTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var piece: Piece? {
        switch pick {
        case .rebuilt(let id):
            return chrome.piece(for: id)
        case .clamp(let id):
            return chrome.piece(for: chrome.reviewableClamps.first { $0.id == id }?.pieceID)
        case .spall(let id):
            return chrome.piece(for: chrome.reviewableSpalls.first { $0.id == id }?.pieceID)
        }
    }

    private var headline: String {
        switch pick {
        case .rebuilt:
            return piece?.title ?? "Painting"
        case .clamp(let id):
            let mark = chrome.reviewableClamps.first { $0.id == id }
            return ShaftCopy.clampHeadline(painting: piece?.title ?? "", word: mark?.word ?? "")
        case .spall(let id):
            let mark = chrome.reviewableSpalls.first { $0.id == id }
            return ShaftCopy.spallHeadline(painting: piece?.title ?? "", word: mark?.word ?? "")
        }
    }

    private var line: String {
        switch pick {
        case .rebuilt:
            return piece?.maker ?? ""
        case .clamp(let id):
            guard let mark = chrome.reviewableClamps.first(where: { $0.id == id }) else { return "" }
            return ShaftCopy.clampLine(word: mark.word, field: mark.field)
        case .spall(let id):
            guard let mark = chrome.reviewableSpalls.first(where: { $0.id == id }) else { return "" }
            return ShaftCopy.spallLine(word: mark.word, field: mark.field)
        }
    }

    private var stamp: String {
        switch pick {
        case .rebuilt:
            return piece.map { ShaftFigures.daykey($0.daykey) } ?? ""
        case .clamp(let id):
            guard let mark = chrome.reviewableClamps.first(where: { $0.id == id }) else { return "" }
            return "Clamp \(ShaftFigures.daykey(mark.daykey))"
        case .spall(let id):
            guard let mark = chrome.reviewableSpalls.first(where: { $0.id == id }) else { return "" }
            return "Spall \(ShaftFigures.daykey(mark.daykey))"
        }
    }

    private var kindTitle: String {
        switch pick {
        case .rebuilt: return "Rebuilt"
        case .clamp: return "Clamp"
        case .spall: return "Spall"
        }
    }
}

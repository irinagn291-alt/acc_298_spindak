import SwiftUI

/// Role: Drum. Spoil-heap rail. Every word is already visible. Stack is a tap on a stone.
struct DrumHeap: View {
    let drums: [Drum]
    let busyID: UUID?
    let enabled: Bool
    var onTap: (UUID) -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            Text("Words")
                .font(ShaftType.font(.caption, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
            ShaftWrap(spacing: ShaftSpace.inner, rowSpacing: ShaftSpace.inner) {
                ForEach(drums) { drum in
                    Button {
                        onTap(drum.id)
                    } label: {
                        Text(drum.word)
                            .font(ShaftType.font(.body, size: typeSize))
                            .foregroundStyle(ShaftInk.ink)
                            .lineLimit(1)
                    }
                    .buttonStyle(ShaftDrumStyle(isLoading: busyID == drum.id))
                    .disabled(!enabled || busyID != nil)
                    .accessibilityLabel("Drum \(drum.word)")
                    .accessibilityHint("Stack this stone if it is next")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ShaftSpace.card)
        .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
    }
}

/// Role: Drum. Wraps stones across the remaining width. Not a three-card row.
struct ShaftWrap: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let rows = arrange(width: width, subviews: subviews)
        let height = rows.reduce(CGFloat.zero) { $0 + $1.height } + rowSpacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: max(height, ShaftSpace.hit))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(width: bounds.width, subviews: subviews)
        var y = bounds.minY
        var index = 0
        for row in rows {
            var x = bounds.minX
            for size in row.sizes {
                let sub = subviews[index]
                sub.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )
                x += size.width + spacing
                index += 1
            }
            y += row.height + rowSpacing
        }
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        var used: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            let next = used == 0 ? size.width : used + spacing + size.width
            if used > 0, next > width {
                rows.append(current)
                current = Row()
                used = 0
            }
            current.sizes.append(size)
            current.height = max(current.height, size.height)
            used = used == 0 ? size.width : used + spacing + size.width
        }
        if !current.sizes.isEmpty {
            rows.append(current)
        }
        return rows
    }

    private struct Row {
        var sizes: [CGSize] = []
        var height: CGFloat = 0
    }
}

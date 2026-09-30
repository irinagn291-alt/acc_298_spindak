import SwiftUI

/// Role: ClampMark. One secondary Quiz figure. Uneven against the word rail. Not a second equal card.
struct ClampStat: View {
    let named: Int
    let missed: Int
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            Text("\(ShaftFigures.whole(named)) named")
                .font(ShaftType.font(.title, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("\(ShaftFigures.whole(missed)) missed")
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .monospacedDigit()
        }
        .padding(ShaftSpace.card)
        .frame(maxWidth: .infinity, minHeight: ShaftSpace.step(10), alignment: .leading)
        .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(ShaftFigures.whole(named)) named, \(ShaftFigures.whole(missed)) missed"
        )
    }
}

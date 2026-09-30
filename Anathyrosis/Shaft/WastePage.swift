import SwiftUI

/// Role: Shaft. Full-page empty or error invite. Generated cutout, one headline, one line, bottom pill.
struct WastePage: View {
    let art: String
    let headline: String
    let line: String
    let actionTitle: String
    var action: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title) private var artHeight: CGFloat = 168

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: ShaftSpace.card)
            Image(art)
                .shaftCutout(maxHeight: artHeight)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, ShaftSpace.outer)
            Text(headline)
                .font(ShaftType.font(.display, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, ShaftSpace.outer)
                .padding(.top, ShaftSpace.card)
            Text(line)
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, ShaftSpace.outer)
                .padding(.top, ShaftSpace.inner)
            Spacer(minLength: ShaftSpace.card)
            Button(actionTitle, action: action)
                .buttonStyle(ShaftPillStyle(tone: .stack, isLoading: false))
                .padding(.horizontal, ShaftSpace.outer)
                .padding(.bottom, ShaftSpace.outer)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ShaftInk.background)
    }
}

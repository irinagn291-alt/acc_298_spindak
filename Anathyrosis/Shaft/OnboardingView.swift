import SwiftUI

/// Role: Shaft. One-shot cover of three pages. Continue is bottom, full width. Skip writes defaults. Re-runnable from Settings.
struct OnboardingView: View {
    var onSkip: () -> Void
    var onFinish: () -> Void
    @State private var page = 0
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                if page < 2 {
                    Button("Skip", action: onSkip)
                        .font(ShaftType.font(.caption, size: typeSize))
                        .foregroundStyle(ShaftInk.ink)
                        .shaftHit()
                        .buttonStyle(ShaftIconStyle())
                        .accessibilityLabel("Skip onboarding")
                }
            }
            .padding(.horizontal, ShaftSpace.outer)

            ViewThatFits(in: .vertical) {
                pageSwitch(showsSpacer: true)
                ScrollView {
                    pageSwitch(showsSpacer: false)
                }
                .scrollIndicators(.hidden)
            }
            .id(page)
            .animation(ShaftMotion.snap(reduceMotion), value: page)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            HStack(spacing: ShaftSpace.gap) {
                ForEach(0 ..< 3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: ShaftRadius.chip, style: .continuous)
                        .fill(index == page ? ShaftInk.accent : ShaftInk.surface)
                        .frame(
                            width: index == page ? ShaftSpace.step(3) : ShaftSpace.inner,
                            height: ShaftSpace.inner
                        )
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, ShaftSpace.outer)
            .padding(.bottom, ShaftSpace.inner)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "Page \(ShaftFigures.whole(page + 1)) of \(ShaftFigures.whole(3))"
            )

            Button(page < 2 ? "Next" : "Continue") {
                if page < 2 {
                    page += 1
                } else {
                    onFinish()
                }
            }
            .buttonStyle(ShaftPillStyle(tone: .stack, isLoading: false))
            .padding(.horizontal, ShaftSpace.outer)
            .padding(.bottom, ShaftSpace.outer)
        }
        .background(ShaftInk.background.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private func pageSwitch(showsSpacer: Bool) -> some View {
        switch page {
        case 0:
            pageBody(
                art: ShaftArt.onboarding1,
                headline: "Save a painting.",
                line: "Keep Victoria and Albert Museum files on this device. Home is the ruined column, not a museum walk.",
                showsSpacer: showsSpacer
            )
        case 1:
            pageBody(
                art: ShaftArt.onboarding2,
                headline: "Scatter the drums.",
                line: "Scatter splits maker or title into stones. Only the order is wrong. Extras stay out.",
                showsSpacer: showsSpacer
            )
        default:
            pageBody(
                art: ShaftArt.onboarding3,
                headline: "Stack in order.",
                line: "The next true drum seats. A miss stays on the heap. Undo peels the newest mark.",
                showsSpacer: showsSpacer
            )
        }
    }

    private func pageBody(art: String, headline: String, line: String, showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: ShaftSpace.card) {
            Image(art)
                .shaftCutout(maxHeight: ShaftSpace.step(28))
                .frame(maxWidth: .infinity)
            Text(headline)
                .font(ShaftType.font(.display, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .fixedSize(horizontal: false, vertical: true)
            if showsSpacer {
                Spacer(minLength: ShaftSpace.card)
            }
        }
        .padding(.horizontal, ShaftSpace.outer)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

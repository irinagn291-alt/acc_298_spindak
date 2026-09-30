import SwiftUI

/// Role: Spoil. Twist screen for scatter-then-stack. Home already holds the heap. This sheet names the fold.
struct ScatterStackView: View {
    @Bindable var chrome: ShaftChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title) private var artHeight: CGFloat = 180

    var body: some View {
        ShaftSheetHost {
            NavigationStack {
                ViewThatFits(in: .vertical) {
                    page(showsSpacer: true)
                    ScrollView {
                        page(showsSpacer: false)
                    }
                    .scrollIndicators(.hidden)
                }
                .background(ShaftInk.background.ignoresSafeArea())
                .navigationTitle("Scatter then stack")
                .navigationBarTitleDisplayMode(.inline)
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

    private func page(showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: ShaftSpace.card) {
            Image(ShaftArt.twistHero)
                .shaftCutout(maxHeight: artHeight)
                .frame(maxWidth: .infinity)
            Text("Scatter then stack")
                .font(ShaftType.font(.display, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Scatter pulls one loose painting and jumbles maker or title into drums. Stack the next true drum. A miss stays on the heap.")
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .fixedSize(horizontal: false, vertical: true)
            statusPlate
            if let spoil = chrome.spoil, chrome.sign == .laid {
                DrumHeap(
                    drums: spoil.heap,
                    busyID: chrome.stackBusy,
                    enabled: chrome.canStack
                ) { drumID in
                    Task { await chrome.stackDrum(drumID) }
                }
            }
            if showsSpacer {
                Spacer(minLength: ShaftSpace.card)
            }
            Button(chrome.sign == .laid ? "Back to the shaft" : "Scatter") {
                if chrome.sign == .laid {
                    dismiss()
                } else {
                    Task {
                        await chrome.scatterPiece()
                        dismiss()
                    }
                }
            }
            .buttonStyle(ShaftPillStyle(tone: .stack, isLoading: chrome.scatterBusy))
            .disabled(chrome.sign != .laid && !chrome.canScatter)
        }
        .padding(.horizontal, ShaftSpace.outer)
        .padding(.bottom, ShaftSpace.outer)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var statusPlate: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            Text(ShaftCopy.signLabel(chrome.sign))
                .font(ShaftType.font(.headline, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
            Text(ShaftCopy.nextTap(sign: chrome.sign, field: chrome.spoil?.field))
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(ShaftSpace.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
    }
}

import SwiftUI

/// Role: Shaft. Primary Stack control. Default, pressed, disabled, and loading. resetAllData uses wipe.
struct ShaftPillStyle: ButtonStyle {
    enum Tone {
        case stack
        case quiet
        case wipe
    }

    var tone: Tone = .stack
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ShaftPillBody(configuration: configuration, tone: tone, isLoading: isLoading)
    }
}

private struct ShaftPillBody: View {
    let configuration: ButtonStyle.Configuration
    let tone: ShaftPillStyle.Tone
    let isLoading: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        HStack(spacing: ShaftSpace.inner) {
            if isLoading {
                ProgressView()
                    .tint(labelInk)
            }
            configuration.label
        }
        .font(ShaftType.font(.headline, size: typeSize))
        .foregroundStyle(labelInk)
        .frame(maxWidth: .infinity)
        .frame(minHeight: ShaftSpace.hit)
        .padding(.horizontal, ShaftSpace.card)
        .background(fill, in: RoundedRectangle(cornerRadius: ShaftRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ShaftRadius.card, style: .continuous)
                .stroke(ShaftInk.ink, lineWidth: isFocused ? 2 : 0)
        )
        .contentShape(RoundedRectangle(cornerRadius: ShaftRadius.card, style: .continuous))
        .scaleEffect(pressed && isEnabled && !reduceMotion ? ShaftSnap.pressScale : 1)
        .opacity(visualOpacity(pressed: pressed))
        .animation(ShaftMotion.snap(reduceMotion), value: pressed)
        .animation(ShaftMotion.snap(reduceMotion), value: isEnabled)
        .animation(ShaftMotion.snap(reduceMotion), value: isLoading)
        .animation(ShaftMotion.snap(reduceMotion), value: isFocused)
    }

    private var fill: Color {
        switch tone {
        case .stack:
            return isEnabled ? ShaftInk.accent : ShaftInk.muted.opacity(0.35)
        case .quiet:
            return ShaftInk.surface
        case .wipe:
            return ShaftInk.ink
        }
    }

    private var labelInk: Color {
        switch tone {
        case .stack, .wipe:
            return ShaftInk.surface
        case .quiet:
            return ShaftInk.ink
        }
    }

    private func visualOpacity(pressed: Bool) -> Double {
        if !isEnabled { return 0.48 }
        if isLoading { return 0.7 }
        if pressed { return 0.88 }
        return 1
    }
}

/// Role: Shaft. Icon-only sheet chrome. Hit the whole 44pt tile.
struct ShaftIconStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ShaftIconBody(configuration: configuration)
    }
}

private struct ShaftIconBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
            .background(ShaftInk.surface, in: RoundedRectangle(cornerRadius: ShaftRadius.chip, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ShaftRadius.chip, style: .continuous)
                    .stroke(ShaftInk.ink, lineWidth: isFocused ? 2 : 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: ShaftRadius.chip, style: .continuous))
            .scaleEffect(pressed && isEnabled && !reduceMotion ? ShaftSnap.pressScale : 1)
            .opacity(!isEnabled ? 0.42 : (pressed ? 0.88 : 1))
            .animation(ShaftMotion.snap(reduceMotion), value: pressed)
            .animation(ShaftMotion.snap(reduceMotion), value: isEnabled)
            .animation(ShaftMotion.snap(reduceMotion), value: isFocused)
    }
}

/// Role: Shaft. Pressed Explore or Form row. Flat fill, no second shadow.
struct ShaftRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ShaftRowBody(configuration: configuration)
    }
}

private struct ShaftRowBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: ShaftRadius.card, style: .continuous)
                    .stroke(ShaftInk.ink, lineWidth: isFocused ? 2 : 0)
            )
            .scaleEffect(pressed && isEnabled && !reduceMotion ? ShaftSnap.pressScale : 1)
            .opacity(!isEnabled ? 0.55 : (pressed ? 0.88 : 1))
            .animation(ShaftMotion.snap(reduceMotion), value: pressed)
            .animation(ShaftMotion.snap(reduceMotion), value: isEnabled)
    }
}

/// Role: Drum. Stone on the spoil heap. Default, pressed, disabled. A miss stays on the heap.
struct ShaftDrumStyle: ButtonStyle {
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ShaftDrumBody(configuration: configuration, isLoading: isLoading)
    }
}

private struct ShaftDrumBody: View {
    let configuration: ButtonStyle.Configuration
    let isLoading: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .font(ShaftType.font(.body))
            .foregroundStyle(ShaftInk.ink)
            .padding(.horizontal, ShaftSpace.card)
            .frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
            .background(ShaftInk.surface, in: RoundedRectangle(cornerRadius: ShaftRadius.chip, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ShaftRadius.chip, style: .continuous)
                    .stroke(ShaftInk.ink.opacity(isFocused ? 1 : 0.16), lineWidth: isFocused ? 2 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: ShaftRadius.chip, style: .continuous))
            .scaleEffect(pressed && isEnabled && !reduceMotion ? ShaftSnap.pressScale : 1)
            .opacity(!isEnabled ? 0.5 : (isLoading ? 0.7 : (pressed ? 0.88 : 1)))
            .animation(ShaftMotion.snap(reduceMotion), value: pressed)
            .animation(ShaftMotion.snap(reduceMotion), value: isEnabled)
    }
}

/// Role: Shaft. Sheets scale 0.96 to 1 plus fade. Reduce Motion is opacity only.
struct ShaftSheetHost<Content: View>: View {
    @ViewBuilder var content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(ShaftInk.background.ignoresSafeArea())
            .preferredColorScheme(.light)
            .tint(ShaftInk.accent)
            .scaleEffect(reduceMotion ? 1 : (appeared ? 1 : ShaftSnap.sheetScale))
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(ShaftMotion.snap(reduceMotion)) {
                    appeared = true
                }
            }
    }
}

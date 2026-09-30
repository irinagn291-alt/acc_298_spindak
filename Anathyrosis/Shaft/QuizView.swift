import SwiftUI

/// Role: Shaft. Locked Quiz. Scatter writes drums. Word taps seat the next stone. Explore, Saved, and Settings arrive as sheets.
struct QuizView: View {
    @Bindable var chrome: ShaftChrome
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        Group {
            if chrome.quizIsEmpty {
                wastePage
            } else {
                populated
            }
        }
        .background(ShaftInk.background.ignoresSafeArea())
        .sensoryFeedback(.impact(weight: .medium), trigger: chrome.clampPulse)
        .animation(ShaftMotion.snap(reduceMotion), value: chrome.sign)
        .animation(ShaftMotion.snap(reduceMotion), value: chrome.spoil?.pieceID)
        .sheet(item: compactCover) { cover in
            coverView(cover)
        }
        .fullScreenCover(item: regularCover) { cover in
            coverView(cover)
        }
    }

    private var isWide: Bool {
        sizeClass == .regular
    }

    private var compactCover: Binding<ShaftCover?> {
        Binding(
            get: { isWide ? nil : chrome.cover },
            set: { chrome.cover = $0 }
        )
    }

    private var regularCover: Binding<ShaftCover?> {
        Binding(
            get: { isWide ? chrome.cover : nil },
            set: { chrome.cover = $0 }
        )
    }

    @ViewBuilder
    private func coverView(_ cover: ShaftCover) -> some View {
        switch cover {
        case .explore:
            ExploreView(chrome: chrome)
        case .saved:
            SavedView(chrome: chrome)
        case .settings:
            SettingsView(chrome: chrome)
        case .scatterStack:
            ScatterStackView(chrome: chrome)
        }
    }

    private var wastePage: some View {
        VStack(alignment: .leading, spacing: 0) {
            chromeBar
                .padding(.horizontal, ShaftSpace.outer)
            WastePage(
                art: ShaftArt.emptyHome,
                headline: chrome.recoveredNotice ? "Progress did not load." : ShaftCopy.wasteHeadline,
                line: chrome.recoveredNotice ? ShaftCopy.recoverLine : ShaftCopy.wasteLine,
                actionTitle: "Explore"
            ) {
                chrome.present(.explore)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populated: some View {
        Group {
            if isWide, !typeSize.isAccessibilitySize {
                wideBoard
                    .padding(.horizontal, ShaftSpace.outer)
                    .padding(.bottom, ShaftSpace.inner)
            } else {
                ScrollView {
                    compactBoard
                        .padding(.horizontal, ShaftSpace.outer)
                        .padding(.bottom, ShaftSpace.inner)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var compactBoard: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.gap) {
            chromeBar
            preface
            workCell(height: ShaftSpace.step(28))
            heapBlock
            recentRail
            ClampStat(
                named: chrome.reviewableClamps.count,
                missed: chrome.reviewableSpalls.count
            )
            fusedVerbs
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var wideBoard: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: ShaftSpace.gap) {
                chromeBar
                HStack(alignment: .top, spacing: ShaftSpace.card) {
                    workColumn
                        .frame(width: max(geo.size.width * 0.56, ShaftSpace.step(28)))
                        .frame(maxHeight: .infinity)
                    VStack(alignment: .leading, spacing: ShaftSpace.gap) {
                        preface
                        heapBlock
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        recentRail
                        ClampStat(
                            named: chrome.reviewableClamps.count,
                            missed: chrome.reviewableSpalls.count
                        )
                        fusedVerbs
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
    }

    private var chromeBar: some View {
        HStack(spacing: ShaftSpace.inner) {
            Button {
                chrome.present(.explore)
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(ShaftType.font(.headline, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ShaftIconStyle())
            .accessibilityLabel("Explore")

            Button {
                chrome.present(.saved)
            } label: {
                Image(systemName: "bookmark")
                    .font(ShaftType.font(.headline, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ShaftIconStyle())
            .accessibilityLabel("Saved")

            Spacer(minLength: ShaftSpace.inner)

            Button {
                chrome.present(.scatterStack)
            } label: {
                Image(systemName: "square.stack.3d.up")
                    .font(ShaftType.font(.headline, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ShaftIconStyle())
            .accessibilityLabel("Open another painting")

            Button {
                chrome.present(.settings)
            } label: {
                Image(systemName: "gearshape")
                    .font(ShaftType.font(.headline, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ShaftIconStyle())
            .accessibilityLabel("Settings")
        }
        .padding(.top, ShaftSpace.inner)
    }

    private var preface: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            Text(ShaftCopy.jobTitle(sign: chrome.sign, field: chrome.spoil?.field))
                .font(ShaftType.font(.display, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .accessibilityAddTraits(.isHeader)
            Text(ShaftCopy.nextTap(sign: chrome.sign, field: chrome.spoil?.field))
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var workColumn: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            QuizHero(
                piece: chrome.displayedPiece,
                rebuilt: chrome.sign == .rebuilt || chrome.showSuccess
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            heroCaption
                .padding(ShaftSpace.card)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func workCell(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            QuizHero(
                piece: chrome.displayedPiece,
                rebuilt: chrome.sign == .rebuilt || chrome.showSuccess
            )
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            heroCaption
                .padding(ShaftSpace.card)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroCaption: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            if showsPaintingTitle {
                Text(captionTitle)
                    .font(ShaftType.font(.headline, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if showsPainter {
                Text(chrome.displayedPiece?.maker ?? "")
                    .font(ShaftType.font(.body, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var captionTitle: String {
        chrome.displayedPiece?.title ?? "Painting"
    }

    private var showsPaintingTitle: Bool {
        chrome.spoil?.field != .title || chrome.sign == .rebuilt || chrome.showSuccess
    }

    private var showsPainter: Bool {
        chrome.sign == .rebuilt || chrome.showSuccess
    }

    @ViewBuilder
    private var heapBlock: some View {
        if let spoil = chrome.spoil, chrome.sign == .laid {
            DrumHeap(
                drums: spoil.heap,
                busyID: chrome.stackBusy,
                enabled: chrome.canStack
            ) { drumID in
                Task { await chrome.stackDrum(drumID) }
            }
        } else if chrome.sign == .spoil {
            Text("Open a painting. The words wait here.")
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .padding(ShaftSpace.card)
                .frame(maxWidth: .infinity, minHeight: ShaftSpace.hit, alignment: .leading)
                .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
        } else if chrome.sign == .rebuilt {
            Text("You named this work. Open another painting when you want.")
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .padding(ShaftSpace.card)
                .frame(maxWidth: .infinity, minHeight: ShaftSpace.hit, alignment: .leading)
                .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
        }
        if let fault = chrome.shaftFault {
            Text(fault)
                .font(ShaftType.font(.caption, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        if chrome.recoveredNotice {
            Text(ShaftCopy.recoverLine)
                .font(ShaftType.font(.caption, size: typeSize))
                .foregroundStyle(ShaftInk.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var recentRail: some View {
        let recent = Array(chrome.rebuiltPieces.prefix(6))
        if recent.isEmpty == false {
            VStack(alignment: .leading, spacing: ShaftSpace.inner) {
                Text("Named paintings")
                    .font(ShaftType.font(.caption, size: typeSize))
                    .foregroundStyle(ShaftInk.muted)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ShaftSpace.inner) {
                        ForEach(recent) { piece in
                            Button {
                                chrome.present(.saved)
                            } label: {
                                PiecePlate(
                                    title: piece.title,
                                    maker: piece.maker,
                                    url: piece.imageURL,
                                    prominence: .row
                                )
                                .frame(width: ShaftSpace.step(11), height: ShaftSpace.step(9))
                                .clipped()
                            }
                            .buttonStyle(.plain)
                            .contentShape(RoundedRectangle(cornerRadius: ShaftRadius.card, style: .continuous))
                            .accessibilityLabel(piece.title)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var fusedVerbs: some View {
        if chrome.sign == .laid {
            if chrome.canPeel {
                undoButton
            }
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: ShaftSpace.inner) {
                    commitButton
                    undoButton
                        .frame(maxWidth: ShaftSpace.step(16))
                }
                VStack(spacing: ShaftSpace.inner) {
                    commitButton
                    undoButton
                }
            }
        }
    }

    private var commitButton: some View {
        Button(scatterTitle) {
            Task { await chrome.scatterPiece() }
        }
        .buttonStyle(ShaftPillStyle(tone: .stack, isLoading: chrome.scatterBusy))
        .disabled(!chrome.canScatter)
        .accessibilityHint("Open a loose painting into words")
    }

    private var scatterTitle: String {
        switch chrome.sign {
        case .rebuilt:
            return "Open another"
        case .spoil, .laid, .waste:
            return "Open a painting"
        }
    }

    private var undoButton: some View {
        Button("Undo") {
            Task { await chrome.peelNewestMark() }
        }
        .buttonStyle(ShaftPillStyle(tone: .quiet, isLoading: chrome.peelBusy))
        .disabled(!chrome.canPeel)
        .accessibilityHint("Undo the newest named or missed word")
    }
}

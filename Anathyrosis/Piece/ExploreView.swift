import SwiftUI

/// Role: Piece. Explore sheet. Searches the Victoria and Albert Museum and writes a loose Piece. Empty query hangs from the crate shelf.
struct ExploreView: View {
    @Bindable var chrome: ShaftChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @FocusState private var searchFocused: Bool

    var body: some View {
        ShaftSheetHost {
            NavigationStack {
                VStack(spacing: 0) {
                    searchField
                    Group {
                        if chrome.exploreIsEmpty, chrome.seekFault != nil {
                            errorPage
                        } else if chrome.exploreIsEmpty {
                            emptyPage
                        } else {
                            populated
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .background(ShaftInk.background.ignoresSafeArea())
                .navigationTitle("Save a painting")
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
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { searchFocused = false }
                            .font(ShaftType.font(.caption, size: typeSize))
                            .foregroundStyle(ShaftInk.ink)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .task {
            if chrome.seekHits.isEmpty {
                chrome.scheduleSeek()
            }
        }
    }

    private var searchField: some View {
        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
            Text("Search the Victoria and Albert Museum, then save a loose painting.")
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, ShaftSpace.outer)
            HStack(spacing: ShaftSpace.gap) {
                TextField("Search a painting", text: $chrome.query)
                    .font(ShaftType.font(.body, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .onChange(of: chrome.query) { _, _ in
                        chrome.scheduleSeek()
                    }
                    .onSubmit {
                        searchFocused = false
                    }
                if chrome.isSeeking {
                    ProgressView()
                        .tint(ShaftInk.ink)
                        .frame(width: ShaftSpace.hit, height: ShaftSpace.hit)
                }
            }
            .padding(.horizontal, ShaftSpace.card)
            .frame(minHeight: ShaftSpace.hit)
            .shaftFlat(ShaftRadius.card, fill: ShaftInk.surface)
            .padding(.horizontal, ShaftSpace.outer)
            if let note = chrome.crateNote {
                Text(note)
                    .font(ShaftType.font(.caption, size: typeSize))
                    .foregroundStyle(ShaftInk.muted)
                    .padding(.horizontal, ShaftSpace.outer)
            }
            if let fault = chrome.seekFault, !chrome.seekHits.isEmpty {
                Text(fault)
                    .font(ShaftType.font(.caption, size: typeSize))
                    .foregroundStyle(ShaftInk.ink)
                    .padding(.horizontal, ShaftSpace.outer)
            }
        }
        .padding(.top, ShaftSpace.inner)
        .padding(.bottom, ShaftSpace.card)
    }

    private var emptyPage: some View {
        WastePage(
            art: ShaftArt.emptyList,
            headline: ShaftCopy.exploreEmptyHeadline,
            line: ShaftCopy.exploreEmptyLine,
            actionTitle: "Show the shelf"
        ) {
            chrome.query = ""
            chrome.scheduleSeek()
        }
    }

    private var errorPage: some View {
        WastePage(
            art: ShaftArt.emptyList,
            headline: "Search paused.",
            line: chrome.seekFault ?? ShaftCopy.searchFail,
            actionTitle: "Try again"
        ) {
            chrome.scheduleSeek()
        }
    }

    private var populated: some View {
        List {
            ForEach(chrome.seekHits) { row in
                Button {
                    Task { await chrome.cratePiece(row) }
                } label: {
                    HStack(alignment: .center, spacing: ShaftSpace.card) {
                        PiecePlate(
                            title: row.title,
                            maker: row.maker,
                            url: row.imageURL,
                            prominence: .row
                        )
                        .frame(width: ShaftSpace.step(8), height: ShaftSpace.step(8))
                        .clipped()
                        VStack(alignment: .leading, spacing: ShaftSpace.inner) {
                            Text(row.title)
                                .font(ShaftType.font(.headline, size: typeSize))
                                .foregroundStyle(ShaftInk.ink)
                                .lineLimit(2)
                            Text(row.maker)
                                .font(ShaftType.font(.caption, size: typeSize))
                                .foregroundStyle(ShaftInk.muted)
                                .lineLimit(1)
                            Text(chrome.shaft.pieces.contains { $0.objectID == row.objectID } ? "In the crate" : "Save")
                                .font(ShaftType.font(.caption, size: typeSize))
                                .foregroundStyle(ShaftInk.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, ShaftSpace.inner)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ShaftRowStyle())
                .disabled(chrome.stockingObjectID != nil)
                .listRowBackground(ShaftInk.surface)
                .listRowInsets(EdgeInsets(
                    top: ShaftSpace.inner,
                    leading: ShaftSpace.outer,
                    bottom: ShaftSpace.inner,
                    trailing: ShaftSpace.outer
                ))
                .accessibilityLabel("\(row.title), \(row.maker)")
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, ShaftSpace.outer)
    }
}

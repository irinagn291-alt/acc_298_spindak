import SwiftUI

/// Role: Shaft. Settings Form. Victoria and Albert Museum credit, Undo, contact, re-run onboarding, resetAllData.
struct SettingsView: View {
    @Bindable var chrome: ShaftChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var confirmReset = false

    var body: some View {
        ShaftSheetHost {
            NavigationStack {
                populated
                .background(ShaftInk.background.ignoresSafeArea())
                .navigationTitle("Progress")
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
                .confirmationDialog(
                    "Erase saved paintings",
                    isPresented: $confirmReset,
                    titleVisibility: .visible
                ) {
                    Button("Erase saved paintings", role: .destructive) {
                        Task { await chrome.resetAllData() }
                    }
                    Button("Keep paintings", role: .cancel) {}
                } message: {
                    Text("Named paintings and word marks leave this device.")
                }
            }
        }
    }

    private var populated: some View {
        Form {
            if chrome.settingsIsEmpty {
                Section {
                    Text("Museum credit and Undo live here once you save a painting.")
                        .font(ShaftType.font(.body, size: typeSize))
                        .foregroundStyle(ShaftInk.muted)
                }
            }

            if chrome.recoveredNotice {
                Section {
                    Text(ShaftCopy.recoverLine)
                        .font(ShaftType.font(.body, size: typeSize))
                        .foregroundStyle(ShaftInk.ink)
                }
            }

            if let fault = chrome.shaftFault {
                Section {
                    Text(fault)
                        .font(ShaftType.font(.body, size: typeSize))
                        .foregroundStyle(ShaftInk.ink)
                }
            }

            if let write = chrome.store.lastWriteError {
                Section {
                    Text(write)
                        .font(ShaftType.font(.caption, size: typeSize))
                        .foregroundStyle(ShaftInk.ink)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: ShaftSpace.inner) {
                    Text("Victoria and Albert Museum")
                        .font(ShaftType.font(.headline, size: typeSize))
                        .foregroundStyle(ShaftInk.ink)
                    Text("Paintings stay on this device. Search uses the museum collection.")
                        .font(ShaftType.font(.body, size: typeSize))
                        .foregroundStyle(ShaftInk.muted)
                }
                Button("Museum site") {
                    openURL(ShaftJob.vamHomeURL)
                }
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.accent)
                .shaftHit()
                Button("Open data") {
                    openURL(ShaftJob.vamOpenDataURL)
                }
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.accent)
                .shaftHit()
            } header: {
                Text("Source")
            }

            Section {
                LabeledContent("Named") {
                    Text(ShaftFigures.whole(chrome.reviewableClamps.count))
                        .font(ShaftType.font(.body, size: typeSize))
                        .monospacedDigit()
                        .foregroundStyle(ShaftInk.ink)
                }
                LabeledContent("Missed") {
                    Text(ShaftFigures.whole(chrome.reviewableSpalls.count))
                        .font(ShaftType.font(.body, size: typeSize))
                        .monospacedDigit()
                        .foregroundStyle(ShaftInk.ink)
                }
                Button("Undo") {
                    Task { await chrome.peelNewestMark() }
                }
                .buttonStyle(ShaftPillStyle(tone: .quiet, isLoading: chrome.peelBusy))
                .disabled(!chrome.canPeel)
                .listRowInsets(EdgeInsets(
                    top: ShaftSpace.inner,
                    leading: ShaftSpace.card,
                    bottom: ShaftSpace.inner,
                    trailing: ShaftSpace.card
                ))
            } header: {
                Text("Score")
            }

            Section {
                Button("Write to us") {
                    openURL(ShaftJob.contactURL)
                }
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.accent)
                .shaftHit()
            } header: {
                Text("Contact")
            }

            Section {
                Button("Replay the first pages") {
                    chrome.replayOnboarding()
                }
                .font(ShaftType.font(.body, size: typeSize))
                .foregroundStyle(ShaftInk.ink)
                .shaftHit()
                Button("Erase saved paintings") {
                    confirmReset = true
                }
                .buttonStyle(ShaftPillStyle(tone: .wipe, isLoading: false))
                .listRowInsets(EdgeInsets(
                    top: ShaftSpace.inner,
                    leading: ShaftSpace.card,
                    bottom: ShaftSpace.inner,
                    trailing: ShaftSpace.card
                ))
            } header: {
                Text("Reset")
            }
        }
        .scrollContentBackground(.hidden)
        .tint(ShaftInk.accent)
    }
}

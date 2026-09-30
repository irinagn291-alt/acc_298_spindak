import SwiftUI
import UIKit

/// Role: Shaft. Root shell. Onboarding cover, then the locked Quiz column. ReviewScreen is applied after onboarding.
struct ContentView: View {
    @State private var chrome: ShaftChrome
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(chrome: ShaftChrome = ShaftChrome.live()) {
        _chrome = State(wrappedValue: chrome)
    }

    var body: some View {
        ZStack {
            ShaftInk.background.ignoresSafeArea()
            if chrome.isBooting {
                Image(ShaftArt.splash)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            } else if chrome.showsOnboarding {
                OnboardingView(
                    onSkip: { Task { await chrome.finishOnboarding() } },
                    onFinish: { Task { await chrome.finishOnboarding() } }
                )
            } else {
                QuizView(chrome: chrome)
            }
        }
        .preferredColorScheme(.light)
        .tint(ShaftInk.accent)
        .animation(ShaftMotion.snap(reduceMotion), value: chrome.showsOnboarding)
        .animation(ShaftMotion.snap(reduceMotion), value: chrome.isBooting)
        .task { await chrome.boot() }
        .task {
            for await notice in NotificationCenter.default.notifications(named: .shaftJob) {
                if let job = ShaftJob.parse(notification: notice) {
                    chrome.handle(job)
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            Task { await chrome.handle(phase: phase) }
        }
        .onOpenURL { chrome.handle(url: $0) }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            chrome.refreshDay()
        }
    }
}

#Preview {
    ContentView()
}

import AppIntents
import Foundation

/// Role: Shaft. App Intents open Quiz, Explore, Saved, or Settings, or fire stackDrum in place.
struct OpenQuizIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Quiz" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        ShaftPost.broadcast(.quiz)
        return .result()
    }
}

struct OpenExploreIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Explore" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        ShaftPost.broadcast(.explore)
        return .result()
    }
}

struct OpenSavedIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Saved" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        ShaftPost.broadcast(.saved)
        return .result()
    }
}

struct OpenSettingsIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Settings" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        ShaftPost.broadcast(.settings)
        return .result()
    }
}

struct StackDrumIntent: AppIntent {
    static var title: LocalizedStringResource { "Stack a drum" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        ShaftPost.broadcast(.stack)
        return .result()
    }
}

struct OpenScatterStackIntent: AppIntent {
    static var title: LocalizedStringResource { "Open scatter then stack" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        ShaftPost.broadcast(.scatterStack)
        return .result()
    }
}

struct AnathyrosisShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenQuizIntent(),
            phrases: [
                "Open Quiz in \(.applicationName)",
                "Stack the drum in \(.applicationName)",
            ],
            shortTitle: "Quiz",
            systemImageName: "square.stack.3d.up"
        )
        AppShortcut(
            intent: OpenExploreIntent(),
            phrases: [
                "Open Explore in \(.applicationName)",
            ],
            shortTitle: "Explore",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenSavedIntent(),
            phrases: [
                "Open Saved in \(.applicationName)",
            ],
            shortTitle: "Saved",
            systemImageName: "bookmark"
        )
        AppShortcut(
            intent: OpenSettingsIntent(),
            phrases: [
                "Open Settings in \(.applicationName)",
            ],
            shortTitle: "Settings",
            systemImageName: "gearshape"
        )
        AppShortcut(
            intent: StackDrumIntent(),
            phrases: [
                "Stack a drum in \(.applicationName)",
            ],
            shortTitle: "Stack",
            systemImageName: "arrow.up.to.line"
        )
        AppShortcut(
            intent: OpenScatterStackIntent(),
            phrases: [
                "Scatter then stack in \(.applicationName)",
            ],
            shortTitle: "Scatter",
            systemImageName: "square.stack"
        )
    }
}

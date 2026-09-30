import Foundation

/// Role: Shaft. Four destinations as shaft-locked sheets. Never a Game tab. ReviewScreen keys are not tabs.
enum ShaftSheet: String, Equatable, Sendable, CaseIterable {
    case quiz
    case explore
    case saved
    case settings
}

/// Role: Shaft. Launch keys for live shots. today, log, and goals open three different screens. Extra key explore.
enum ReviewHook: String, Equatable, Sendable {
    case today
    case log
    case goals
    case explore

    var sheet: ShaftSheet {
        switch self {
        case .today: .quiz
        case .log: .saved
        case .goals: .settings
        case .explore: .explore
        }
    }
}

/// Role: Shaft. Reads ProcessInfo `-ReviewScreen today|log|goals|explore` once after onboarding. No View.
enum ShaftLinks {
    static let flag = "-ReviewScreen"

    static func consume(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        onboardingComplete: Bool,
        consumed: inout Bool
    ) -> ReviewHook? {
        guard onboardingComplete, !consumed else { return nil }
        consumed = true
        guard let index = arguments.firstIndex(of: flag) else { return nil }
        let next = arguments.index(after: index)
        guard arguments.indices.contains(next) else { return nil }
        return ReviewHook(rawValue: arguments[next])
    }
}

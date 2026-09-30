import Foundation

/// Role: Shaft. Jobs for App Intents and anathyrosis:// plus https://anathyrosis-shaft.pro paths. Quiz stays put.
enum ShaftJob: String, Equatable, Sendable {
    case quiz
    case explore
    case saved
    case settings
    case stack
    case scatterStack = "scatter-stack"

    static let httpsHost = "anathyrosis-shaft.pro"
    static let scheme = "anathyrosis"
    /// Programmer constants. Settings credits the museum and opens contact in the system browser.
    static let contactURL = URL(string: "https://anathyrosis-shaft.pro/contact-us")!
    static let vamHomeURL = URL(string: "https://www.vam.ac.uk")!
    static let vamOpenDataURL = URL(string: "https://www.vam.ac.uk/info/open-data")!

    static func parse(_ url: URL) -> ShaftJob? {
        let scheme = url.scheme?.lowercased() ?? ""
        if scheme == Self.scheme {
            let host = url.host?.lowercased() ?? ""
            let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let token = host.isEmpty ? path : host
            return ShaftJob(rawValue: token)
        }
        if scheme == "https", url.host?.lowercased() == httpsHost {
            let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if path.isEmpty { return .quiz }
            if path == "contact-us" { return .settings }
            return ShaftJob(rawValue: path)
        }
        return nil
    }

    static func parse(notification: Notification) -> ShaftJob? {
        guard let raw = notification.userInfo?[ShaftPost.key] as? String else { return nil }
        return ShaftJob(rawValue: raw)
    }

    var cover: ShaftCover? {
        switch self {
        case .quiz, .stack:
            return nil
        case .explore:
            return .explore
        case .saved:
            return .saved
        case .settings:
            return .settings
        case .scatterStack:
            return .scatterStack
        }
    }
}

/// Role: Shaft. Sheets over the locked Quiz. Four destinations plus the scatter-then-stack fold.
enum ShaftCover: String, Identifiable, Equatable, Sendable, CaseIterable {
    case explore
    case saved
    case settings
    case scatterStack

    var id: String { rawValue }
}

extension Notification.Name {
    static let shaftJob = Notification.Name("ahy.shaft.job")
}

/// Role: Shaft. App Intent seam. Views listen. No second Anastylosis enum.
enum ShaftPost {
    static let key = "job"

    static func broadcast(_ job: ShaftJob) {
        NotificationCenter.default.post(
            name: .shaftJob,
            object: nil,
            userInfo: [key: job.rawValue]
        )
    }
}

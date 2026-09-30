import SwiftUI

/// Role: Shaft. Named colours from Assets.xcassets. Hex lives only here: #FAF7F5 #FEFEFD #392818 #CC6D19 #816C5A.
enum ShaftInk {
    enum Hex {
        static let background = "#FAF7F5"
        static let surface = "#FEFEFD"
        static let ink = "#392818"
        static let accent = "#CC6D19"
        static let muted = "#816C5A"
    }

    static var background: Color { Color("background") }
    static var surface: Color { Color("surface") }
    static var ink: Color { Color("ink") }
    static var accent: Color { Color("accent") }
    static var muted: Color { Color("muted") }
}

/// Role: Shaft. SF Pro via Font.system. Six steps: display, title, headline, body, caption, micro.
enum ShaftType {
    static let face = "SF Pro"

    enum Step: CaseIterable {
        case display
        case title
        case headline
        case body
        case caption
        case micro
    }

    static func font(_ step: Step, size: DynamicTypeSize = .large) -> Font {
        switch step {
        case .display:
            if size >= .accessibility3 {
                return .system(.title2, design: .default).weight(.semibold)
            }
            return .system(.title, design: .default).weight(.semibold)
        case .title:
            return .system(.title3, design: .default).weight(.semibold)
        case .headline:
            return .system(.headline, design: .default).weight(.semibold)
        case .body:
            return .system(.body, design: .default)
        case .caption:
            return .system(.footnote, design: .default)
        case .micro:
            return .system(.caption, design: .default)
        }
    }
}

/// Role: Shaft. One 8pt grid. Hits are 44pt. Views never pick a stray padding.
enum ShaftSpace {
    static let unit: CGFloat = 8

    static func step(_ n: Int) -> CGFloat {
        unit * CGFloat(n)
    }

    static var hit: CGFloat { 44 }
    static var outer: CGFloat { step(3) }
    static var card: CGFloat { step(2) }
    static var inner: CGFloat { step(1) }
    static var gap: CGFloat { step(1) }
}

/// Role: Shaft. Cards and sheets 20pt, chips 12pt. Never a second radius language.
enum ShaftRadius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
}

/// Role: Shaft. One soft drop-shadow. Only the Quiz hero sits above the field.
enum ShaftLift {
    static let shadeRadius: CGFloat = 16
    static let shadeY: CGFloat = 8
    static var shade: Color { ShaftInk.ink.opacity(0.12) }
}

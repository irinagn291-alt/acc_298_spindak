import SwiftUI

/// Role: Shaft. Snap motion for press and sheets. Reduce Motion keeps opacity and drops travel.
enum ShaftSnap {
    static let pressScale: CGFloat = 0.97
    static let sheetScale: CGFloat = 0.96
    static let duration: Double = 0.16
}

enum ShaftMotion {
    static func snap(_ reduceMotion: Bool) -> Animation {
        .easeOut(duration: reduceMotion ? 0.12 : ShaftSnap.duration)
    }
}

/// Role: Shaft. Asset names from section 13. Views never invent a second kit.
enum ShaftArt {
    static let appIcon = "ahy_AppIcon"
    static let splash = "ahy_Splash"
    static let onboarding1 = "ahy_Onboarding1"
    static let onboarding2 = "ahy_Onboarding2"
    static let onboarding3 = "ahy_Onboarding3"
    static let emptyHome = "ahy_EmptyHome"
    static let emptyList = "ahy_EmptyList"
    static let cardBackdrop = "ahy_CardBackdrop"
    static let controlFace = "ahy_ControlFace"
    static let twistHero = "ahy_TwistHero"
    static let successMark = "ahy_SuccessMark"
    static let headerDecor = "ahy_HeaderDecor"
    static let columnDrum = "ahy_ColumnDrum"
    static let spoilHeap = "ahy_SpoilHeap"
    static let ironClamp = "ahy_IronClamp"
}

/// Role: Shaft. Warm short copy. Periods, never an em dash. Counts stay in ShaftFigures.
enum ShaftCopy {
    static let wasteHeadline = "Crate empty."
    static let wasteLine = "Save a painting, then stack."
    static let exploreEmptyHeadline = "The crate is quiet."
    static let exploreEmptyLine = "Search the museum, then save a painting."
    static let savedEmptyHeadline = "Nothing rebuilt yet."
    static let savedEmptyLine = "Stack the drums, then look here."
    static let writeFailed = "Write failed. Scatter or Stack again."
    static let recoverLine = "Saved progress did not load. Start from Explore."
    static let searchFail = "Search could not reach the museum. The crate shelf is here."
    static let searchMiss = "The museum had no match. The crate shelf is here."
    static let alreadyCrate = "That painting is already in the crate."
    static let savedLoose = "Saved as loose spoil."
    static let missStays = "That drum stays on the heap."
    static let stackNeedsScatter = "Scatter a painting first."
    static let alreadyLaid = "Finish this shaft first."
    static let nothingToPeel = "Nothing to undo."

    static func verb(sign: ShaftSign) -> String {
        jobTitle(sign: sign, field: nil)
    }

    static func jobTitle(sign: ShaftSign, field: InscriptionField?) -> String {
        switch sign {
        case .waste:
            return "Save a painting"
        case .spoil:
            return "Open a painting"
        case .laid:
            switch field {
            case .title:
                return "Name this painting"
            case .maker, .none:
                return "Name the painter"
            }
        case .rebuilt:
            return "You named it"
        }
    }

    static func nextTap(sign: ShaftSign, field: InscriptionField?) -> String {
        switch sign {
        case .waste:
            return wasteLine
        case .spoil:
            return "Open a painting to start."
        case .laid:
            switch field {
            case .maker:
                return "Tap the next word of the painter."
            case .title:
                return "Tap the next word of the title."
            case .none:
                return "Tap the next word."
            }
        case .rebuilt:
            return "Open another painting when you want."
        }
    }

    static func signLabel(_ sign: ShaftSign) -> String {
        switch sign {
        case .waste: return "Waste"
        case .spoil: return "Spoil"
        case .laid: return "Laid"
        case .rebuilt: return "Rebuilt"
        }
    }

    static func fieldLabel(_ field: InscriptionField) -> String {
        switch field {
        case .maker: return "Maker"
        case .title: return "Title"
        }
    }

    static func namedSummary(painting: String, count: Int) -> String {
        let tally = ShaftFigures.whole(count)
        if painting.isEmpty {
            return count == 1 ? "You named a word on a painting." : "You named \(tally) words on a painting."
        }
        if count == 1 {
            return "You named a word on \(painting)."
        }
        return "You named \(tally) words on \(painting)."
    }

    static func missedSummary(painting: String, count: Int) -> String {
        let tally = ShaftFigures.whole(count)
        if painting.isEmpty {
            return count == 1 ? "You missed a word on a painting." : "You missed \(tally) words on a painting."
        }
        if count == 1 {
            return "You missed a word on \(painting)."
        }
        return "You missed \(tally) words on \(painting)."
    }

    static func clampHeadline(painting: String, word: String) -> String {
        _ = word
        return namedSummary(painting: painting, count: 1)
    }

    static func clampLine(word: String, field: InscriptionField) -> String {
        "You named the word \(word) in the \(fieldLabel(field).lowercased())."
    }

    static func spallHeadline(painting: String, word: String) -> String {
        _ = word
        return missedSummary(painting: painting, count: 1)
    }

    static func spallLine(word: String, field: InscriptionField) -> String {
        "You missed the word \(word) in the \(fieldLabel(field).lowercased())."
    }

    static func fault(_ error: Error) -> String {
        if let fault = error as? ShaftFault {
            switch fault {
            case .stackOnSpoil:
                return stackNeedsScatter
            case .alreadyLaid:
                return alreadyLaid
            case .thinField:
                return "Need two words to scatter."
            case .unknownDrum:
                return "That drum is not on this heap."
            case .notNextWord:
                return missStays
            case .isNextWord:
                return "That drum is next. Stack it."
            case .alreadySeated:
                return "That drum is already seated."
            case .nothingToPeel:
                return nothingToPeel
            case .emptyObjectID:
                return "This painting has no object id."
            case .unknownPiece:
                return "That painting is not in the crate."
            }
        }
        if let fault = error as? CatalogFault {
            return seek(fault)
        }
        return writeFailed
    }

    static func seek(_ fault: CatalogFault) -> String {
        switch fault {
        case .cancelled:
            return "Search stopped."
        case .missing:
            return searchMiss
        case .refused:
            return "The museum refused the search. The crate shelf is here."
        case .transport:
            return searchFail
        case .malformed:
            return "Search could not be read. The crate shelf is here."
        }
    }
}

/// Role: Shaft. ClampMark counts, SpallMark counts, and daykeys go through NumberFormatter. Never interpolate.
enum ShaftFigures {
    static func whole(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func daykey(_ value: Int) -> String {
        let year = value / 10_000
        let month = (value / 100) % 100
        let day = value % 100
        return "\(plain(year)).\(plain(month, digits: 2)).\(plain(day, digits: 2))"
    }

    private static func plain(_ value: Int, digits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = digits
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

extension View {
    func shaftHit() -> some View {
        frame(minWidth: ShaftSpace.hit, minHeight: ShaftSpace.hit)
            .contentShape(Rectangle())
    }

    func shaftFlat(_ radius: CGFloat = ShaftRadius.card, fill: Color = ShaftInk.surface) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return background(fill, in: shape)
    }
}

extension Image {
    func shaftCutout(maxWidth: CGFloat? = .infinity, maxHeight: CGFloat) -> some View {
        resizable()
            .scaledToFit()
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .clipped()
            .accessibilityHidden(true)
    }
}

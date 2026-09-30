import XCTest
@testable import Anathyrosis

final class ShaftJobTests: XCTestCase {
    func test_schemeAndHttpsMapToTheSameJobs() {
        XCTAssertEqual(ShaftJob.parse(URL(string: "anathyrosis://quiz")!), .quiz)
        XCTAssertEqual(ShaftJob.parse(URL(string: "anathyrosis://explore")!), .explore)
        XCTAssertEqual(ShaftJob.parse(URL(string: "anathyrosis://saved")!), .saved)
        XCTAssertEqual(ShaftJob.parse(URL(string: "anathyrosis://settings")!), .settings)
        XCTAssertEqual(ShaftJob.parse(URL(string: "anathyrosis://stack")!), .stack)
        XCTAssertEqual(ShaftJob.parse(URL(string: "anathyrosis://scatter-stack")!), .scatterStack)
        XCTAssertEqual(ShaftJob.parse(URL(string: "https://anathyrosis-shaft.pro/quiz")!), .quiz)
        XCTAssertEqual(ShaftJob.parse(URL(string: "https://anathyrosis-shaft.pro/explore")!), .explore)
        XCTAssertEqual(ShaftJob.parse(URL(string: "https://anathyrosis-shaft.pro/saved")!), .saved)
        XCTAssertEqual(ShaftJob.parse(URL(string: "https://anathyrosis-shaft.pro/settings")!), .settings)
        XCTAssertEqual(ShaftJob.parse(URL(string: "https://anathyrosis-shaft.pro/contact-us")!), .settings)
        XCTAssertEqual(ShaftJob.parse(URL(string: "https://anathyrosis-shaft.pro/")!), .quiz)
        XCTAssertNil(ShaftJob.parse(URL(string: "https://example.com/quiz")!))
        XCTAssertEqual(ShaftJob.stack.cover, nil)
        XCTAssertEqual(ShaftJob.explore.cover, .explore)
        XCTAssertEqual(ShaftJob.saved.cover, .saved)
        XCTAssertEqual(ShaftJob.settings.cover, .settings)
        XCTAssertEqual(ShaftJob.scatterStack.cover, .scatterStack)
        XCTAssertEqual(Set(ShaftCover.allCases.map(\.rawValue)).count, 4)
        XCTAssertFalse(ShaftCover.allCases.map(\.rawValue).contains("game"))
    }

    func test_figuresUseNumberFormatter() {
        XCTAssertFalse(ShaftFigures.whole(4).isEmpty)
        XCTAssertEqual(ShaftFigures.daykey(20260919).contains("2026"), true)
        XCTAssertEqual(ShaftCopy.verb(sign: .laid), "Name the painter")
        XCTAssertEqual(ShaftCopy.jobTitle(sign: .laid, field: .title), "Name this painting")
        XCTAssertEqual(
            ShaftCopy.namedSummary(painting: "Venice from the Giudecca", count: 2),
            "You named \(ShaftFigures.whole(2)) words on Venice from the Giudecca."
        )
        XCTAssertEqual(ShaftCopy.signLabel(.waste), "Waste")
        XCTAssertEqual(ShaftCopy.wasteHeadline, "Crate empty.")
    }
}

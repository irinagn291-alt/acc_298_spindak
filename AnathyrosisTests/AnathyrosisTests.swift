import XCTest
@testable import Anathyrosis

final class AnathyrosisTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: AnathyrosisApp.self), "AnathyrosisApp")
        XCTAssertEqual(String(describing: ShaftStore.self), "ShaftStore")
    }
}

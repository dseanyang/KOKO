import XCTest
@testable import KOKO

@MainActor
final class MainNavigationControllerTests: XCTestCase {

    func test_showingMainTabs_displaysHotGreyNavigationBarWithThreeButtons() {
        let sut = MainNavigationController(rootViewController: ScenarioViewController())
        let mainTabs = MainTabBarController(scenario: .friendsOnly)

        sut.loadViewIfNeeded()
        sut.navigationController(sut, willShow: mainTabs, animated: false)

        XCTAssertFalse(sut.isNavigationBarHidden)
        XCTAssertEqual(mainTabs.navigationItem.leftBarButtonItems?.count, 3)
        XCTAssertNotNil(mainTabs.navigationItem.rightBarButtonItem)
        XCTAssertTrue(mainTabs.navigationItem.hidesBackButton)
        XCTAssertEqual(sut.navigationBar.standardAppearance.backgroundColor, .hotGrey)
        XCTAssertEqual(sut.view.backgroundColor, .hotGrey)
    }

    func test_showingNonTabScreen_hidesNavigationBar() {
        let scenario = ScenarioViewController()
        let sut = MainNavigationController(rootViewController: scenario)

        sut.loadViewIfNeeded()
        sut.navigationController(sut, willShow: scenario, animated: false)

        XCTAssertTrue(sut.isNavigationBarHidden)
    }
}

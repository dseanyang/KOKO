import XCTest
@testable import KOKO

@MainActor
final class EmptyFriendViewTests: XCTestCase {

    func test_illustrationHeight_canYieldWhenParentHasInsufficientSpace() {
        let sut = EmptyFriendView()
        let illustrationView = sut.subviews.compactMap { $0 as? UIImageView }.first
        let illustrationHeightConstraint = illustrationView?.constraints.first { constraint in
            constraint.firstAttribute == .height &&
                constraint.constant == 172
        }

        XCTAssertEqual(illustrationHeightConstraint?.priority, .defaultHigh)
    }
}

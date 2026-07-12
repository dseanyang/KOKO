import XCTest
@testable import KOKO

@MainActor
final class EmptyFriendViewTests: XCTestCase {

    func test_illustrationHeight_canYieldWhenParentHasInsufficientSpace() {
        let sut = EmptyFriendView()
        let illustrationHeightConstraint = sut.constraints.first { constraint in
            (constraint.firstItem as? UIImageView) != nil &&
                constraint.firstAttribute == .height &&
                constraint.constant == 172
        }

        XCTAssertEqual(illustrationHeightConstraint?.priority, .defaultHigh)
    }
}

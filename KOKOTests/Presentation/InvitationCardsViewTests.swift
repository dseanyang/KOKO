import XCTest
@testable import KOKO

@MainActor
final class InvitationCardsViewTests: XCTestCase {

    func test_initialState_hidesPlaceholderCardUntilInvitationDataArrives() {
        let sut = InvitationCardsView()

        XCTAssertTrue(sut.isHidden)
    }

    func test_hiddenState_allowsZeroHeightWithoutBreakingRequiredScrollConstraints() {
        let sut = InvitationCardsView()
        let scrollBottomConstraint = sut.constraints.first { constraint in
            (constraint.firstItem as? UIScrollView) != nil &&
                constraint.firstAttribute == .bottom &&
                (constraint.secondItem as? UIView) === sut &&
                constraint.secondAttribute == .bottom
        }

        XCTAssertEqual(scrollBottomConstraint?.priority, .defaultHigh)
    }

    func test_configureWithNoInvitations_keepsViewHidden() {
        let sut = InvitationCardsView()

        sut.configure(with: [], isExpanded: false)

        XCTAssertTrue(sut.isHidden)
    }

    func test_configureWithInvitation_showsView() {
        let sut = InvitationCardsView()

        sut.configure(with: [InvitationViewData(name: "小明")], isExpanded: false)

        XCTAssertFalse(sut.isHidden)
    }
}

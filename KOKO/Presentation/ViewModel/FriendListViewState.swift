import Foundation

// MARK: - Single Source of Truth for the Friend List UI

/// The only state the ViewController needs to know about.
/// All booleans and display logic are pre-computed here so the VC
/// can be a pure render function: render(state).
struct FriendListViewState: Equatable {
    let profile: ProfileViewData?           // nil → show user loading spinner
    let invitations: [InvitationViewData]
    let displayedFriends: [FriendCellViewModel]
    let invitingBadgeCount: Int             // count of status=2 friends (badge on tab)
    let showEmptyView: Bool
    let showSearchBar: Bool                 // hidden in noFriends scenario
    let isInvitationExpanded: Bool
    let isListLoading: Bool
    let showKokoIdDot: Bool                 // pink dot in noFriends scenario
    let error: String?

    static let initial = FriendListViewState(
        profile: nil,
        invitations: [],
        displayedFriends: [],
        invitingBadgeCount: 0,
        showEmptyView: false,
        showSearchBar: false,
        isInvitationExpanded: false,
        isListLoading: false,
        showKokoIdDot: false,
        error: nil
    )
}

// MARK: - Presentation-layer view data (hides Domain entities from the View)

/// Profile header display data.
struct ProfileViewData: Equatable {
    let name: String
    let kokoIdText: String
}

/// Data needed to render a single friend row cell.
struct FriendCellViewModel: Equatable {
    let name: String
    let isTop: Bool
    let friendStatus: FriendStatus      // reuse the Domain enum — it has no UI code
}

/// Data needed to render a single invitation card / row.
struct InvitationViewData: Equatable {
    let name: String
}

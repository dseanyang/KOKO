import Foundation

// MARK: - Response Wrapper
struct FriendResponse: Decodable {
    let response: [Friend]
}

// MARK: - Friend Status Enum
/// status 0: inviteSent, 1: completed, 2: inviting
enum FriendStatus: Int, Decodable {
    case inviteSent = 0
    case completed  = 1
    case inviting   = 2
}

// MARK: - Friend Model
struct Friend: Decodable {
    let name: String
    let status: Int
    let isTop: String
    let fid: String
    let updateDate: String

    var friendStatus: FriendStatus {
        FriendStatus(rawValue: status) ?? .completed
    }

    /// True when the friend entry is an invitation card (status=0, inviteSent).
    /// status=2 (inviting) means an outgoing request still pending; it stays in the friends list with an "inviting" button.
    var isInvitation: Bool {
        friendStatus == .inviteSent
    }

    var hasStarBadge: Bool {
        isTop == "1"
    }

    var statusLabel: String? {
        switch friendStatus {
        case .completed:  return nil
        case .inviteSent: return "邀請送出"
        case .inviting:   return "邀請中"
        }
    }
}

struct FriendListResult {
    let friends: [Friend]
    let invitations: [Friend]
}

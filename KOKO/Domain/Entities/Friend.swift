import Foundation

enum FriendStatus: Int {
    case inviteSent = 0   // 邀請送出（顯示為 invitation card）
    case completed  = 1   // 好友關係已建立
    case inviting   = 2   // 邀請中（outgoing request，仍在好友列表）
}

struct Friend {
    let fid: String
    let name: String
    let status: Int
    let isTop: String
    let updateDate: String

    var friendStatus: FriendStatus {
        FriendStatus(rawValue: status) ?? .completed
    }

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

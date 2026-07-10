import Foundation

struct FriendResponseDTO: Decodable {
    let response: [FriendDTO]
}

struct FriendDTO: Decodable {
    let name: String
    let status: Int
    let isTop: String
    let fid: String
    let updateDate: String
}

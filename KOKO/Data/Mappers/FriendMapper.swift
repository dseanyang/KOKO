import Foundation

enum FriendMapper {

    static func map(_ dto: FriendDTO) -> Friend {
        Friend(
            fid:        dto.fid,
            name:       dto.name,
            status:     dto.status,
            isTop:      dto.isTop,
            updateDate: dto.updateDate
        )
    }

    static func map(_ dtos: [FriendDTO]) -> [Friend] {
        dtos.map { map($0) }
    }
}

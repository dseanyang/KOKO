import Foundation

enum UserMapper {

    static func map(_ dto: UserDTO) -> User {
        User(
            name:   dto.name,
            kokoid: dto.kokoid
        )
    }
}

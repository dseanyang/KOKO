import Foundation

struct UserResponseDTO: Decodable {
    let response: [UserDTO]
}

struct UserDTO: Decodable {
    let name: String
    let kokoid: String
}

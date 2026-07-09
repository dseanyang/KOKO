import Foundation

// MARK: - Response Wrapper
struct UserResponse: Decodable {
    let response: [User]
}

// MARK: - User Model
struct User: Decodable {
    let name: String
    let kokoid: String
}

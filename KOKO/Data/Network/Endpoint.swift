import Foundation

enum Endpoint {
    case friendList1
    case friendList2
    case friendList3
    case friendList4
    case user

    private static let base = "https://dimanyen.github.io"

    var url: URL {
        let path: String
        switch self {
        case .friendList1: path = "/friend1.json"
        case .friendList2: path = "/friend2.json"
        case .friendList3: path = "/friend3.json"
        case .friendList4: path = "/friend4.json"
        case .user:        path = "/man.json"
        }
        // Force-unwrap is safe: all paths are compile-time constants combined with a fixed base URL.
        return URL(string: Self.base + path)!
    }
}

import Foundation

protocol GetUserUseCaseProtocol {
    func execute() async throws -> User
}

final class GetUserUseCase: GetUserUseCaseProtocol {

    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }

    func execute() async throws -> User {
        try await userRepository.fetchUser()
    }
}

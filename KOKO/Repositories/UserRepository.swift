import Foundation

// MARK: - UserRepositoryProtocol
protocol UserRepositoryProtocol {
    func fetchUser() async -> Result<User, APIError>
    func clearCache()
}

// MARK: - UserRepository
final class UserRepository: UserRepositoryProtocol {

    private let remoteDataSource: UserAPIProtocol
    private let localDataSource: UserLocalDataSourceProtocol

    init(remoteDataSource: UserAPIProtocol = UserAPI(),
         localDataSource: UserLocalDataSourceProtocol = UserCoreData()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchUser() async -> Result<User, APIError> {
        do {
            let users = try await remoteDataSource.fetchUser()
            guard let user = users.first else {
                if let cached = localDataSource.fetchUser() { return .success(cached) }
                return .failure(.noData)
            }
            localDataSource.saveUser(user)
            return .success(user)
        } catch let error as APIError {
            if let cached = localDataSource.fetchUser() { return .success(cached) }
            return .failure(error)
        } catch {
            if let cached = localDataSource.fetchUser() { return .success(cached) }
            return .failure(.networkError(error))
        }
    }

    func clearCache() {
        localDataSource.clearCache()
    }
}

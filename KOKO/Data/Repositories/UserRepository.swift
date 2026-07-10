import Foundation

protocol UserRepositoryProtocol {
    func fetchUser() async throws -> User
    func clearCache()
}

final class UserRepository: UserRepositoryProtocol {

    private let remoteDataSource: UserAPIProtocol
    private let localDataSource: UserLocalDataSourceProtocol

    init(remoteDataSource: UserAPIProtocol = UserAPI(),
         localDataSource: UserLocalDataSourceProtocol = UserCoreData()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchUser() async throws -> User {
        do {
            let users = try await remoteDataSource.fetchUser()
            guard let user = users.first else {
                if let cached = localDataSource.fetchUser() { return cached }
                throw APIError.noData
            }
            localDataSource.saveUser(user)
            return user
        } catch {
            if let cached = localDataSource.fetchUser() { return cached }
            throw error
        }
    }

    func clearCache() {
        localDataSource.clearCache()
    }
}

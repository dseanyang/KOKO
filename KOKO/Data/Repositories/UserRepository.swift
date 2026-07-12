import Foundation
import os

protocol UserRepositoryProtocol {
    func fetchUser() async throws -> User
    func clearCache()
}

final class UserRepository: UserRepositoryProtocol {

    private static let logger = Logger(subsystem: "com.koko.ioskoko", category: "UserRepository")

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
            guard let user = users.first else { throw APIError.noData }
            do {
                try localDataSource.saveUser(user)
            } catch {
                Self.logger.error("Failed to save user cache: \(error.localizedDescription, privacy: .public)")
            }
            return user
        } catch {
            do {
                if let cached = try localDataSource.fetchUser() { return cached }
            } catch {
                Self.logger.error("Failed to read user cache: \(error.localizedDescription, privacy: .public)")
            }
            throw error
        }
    }

    func clearCache() {
        do {
            try localDataSource.clearCache()
        } catch {
            Self.logger.error("Failed to clear user cache: \(error.localizedDescription, privacy: .public)")
        }
    }
}

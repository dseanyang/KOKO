import Foundation

// MARK: - FriendRepositoryProtocol
protocol FriendRepositoryProtocol {
    func fetchFriends(scenario: FriendScenario) async -> Result<[Friend], APIError>
    func clearCache()
}

// MARK: - FriendRepository
final class FriendRepository: FriendRepositoryProtocol {

    // MARK: - Dependencies
    private let remoteDataSource: FriendAPIProtocol
    private let localDataSource: FriendLocalDataSourceProtocol

    // MARK: - Init
    init(remoteDataSource: FriendAPIProtocol = FriendAPI(),
         localDataSource: FriendLocalDataSourceProtocol = FriendCoreData()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    // MARK: - FriendRepositoryProtocol

    func fetchFriends(scenario: FriendScenario) async -> Result<[Friend], APIError> {
        do {
            let friends = try await fetchRemoteFriends(scenario: scenario)
            localDataSource.saveFriends(friends, scenario: scenario)
            return .success(friends)
        } catch let error as APIError {
            if let cached = localDataSource.fetchFriends(scenario: scenario) {
                return .success(cached)
            }
            return .failure(error)
        } catch {
            if let cached = localDataSource.fetchFriends(scenario: scenario) {
                return .success(cached)
            }
            return .failure(.networkError(error))
        }
    }

    func clearCache() {
        localDataSource.clearCache()
    }

    // MARK: - Private Helpers

    private func fetchRemoteFriends(scenario: FriendScenario) async throws -> [Friend] {
        switch scenario {
        case .noFriends:
            return try await remoteDataSource.fetchFriendList4()

        case .friendsOnly:
            async let list1 = remoteDataSource.fetchFriendList1()
            async let list2 = remoteDataSource.fetchFriendList2()
            let (friends1, friends2) = try await (list1, list2)
            return friends1 + friends2

        case .withInvitations:
            return try await remoteDataSource.fetchFriendList3()
        }
    }
}

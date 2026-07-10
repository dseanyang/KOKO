import Foundation
@testable import KOKO

final class MockGetFriendListUseCase: GetFriendListUseCaseProtocol {
    var stubbedResult: FriendListResult = FriendListResult(friends: [], invitations: [])
    var errorToThrow: Error?
    var executeCallCount = 0
    var lastScenario: FriendScenario?

    func execute(scenario: FriendScenario) async throws -> FriendListResult {
        executeCallCount += 1
        lastScenario = scenario
        if let error = errorToThrow { throw error }
        return stubbedResult
    }
}

final class MockGetUserUseCase: GetUserUseCaseProtocol {
    var stubbedResult: User = User(name: "Test", kokoid: "test")
    var errorToThrow: Error?
    var executeCallCount = 0

    func execute() async throws -> User {
        executeCallCount += 1
        if let error = errorToThrow { throw error }
        return stubbedResult
    }
}

final class MockFriendSorter: FriendSorterProtocol {
    var stubbedResult: [Friend] = []
    var sortCallCount = 0
    var lastInput: [Friend] = []

    func sort(_ friends: [Friend]) -> [Friend] {
        sortCallCount += 1
        lastInput = friends
        return stubbedResult
    }
}

final class MockFriendMerger: FriendMergerProtocol {
    var stubbedResult: [Friend] = []
    var mergeCallCount = 0
    var lastInput: [Friend] = []

    func merge(_ list: [Friend]) -> [Friend] {
        mergeCallCount += 1
        lastInput = list
        return stubbedResult
    }
}

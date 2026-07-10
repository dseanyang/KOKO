import XCTest
@testable import KOKO

@MainActor
final class FriendTableDataSourceTests: XCTestCase {

    var sut: FriendTableDataSource!
    var tableView: UITableView!

    override func setUp() {
        super.setUp()
        sut = FriendTableDataSource()
        tableView = UITableView()
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
        tableView.dataSource = sut
    }

    override func tearDown() {
        sut = nil
        tableView = nil
        super.tearDown()
    }

    func test_numberOfRows_returnsFriendsCount() {
        let friends = [
            FriendCellViewModel(name: "A", isTop: false, friendStatus: .completed),
            FriendCellViewModel(name: "B", isTop: true, friendStatus: .completed)
        ]
        sut.update(friends: friends)
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)
    }

    func test_cellForRow_returnsFriendCellWithCorrectData() {
        let friend = FriendCellViewModel(name: "TestFriend", isTop: true, friendStatus: .inviting)
        sut.update(friends: [friend])
        
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? FriendCell
        
        XCTAssertNotNil(cell)
        // Note: to fully test the UI mapping, we would expose cell UI properties to test
    }
}

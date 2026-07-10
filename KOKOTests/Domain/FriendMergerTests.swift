import XCTest
@testable import KOKO

final class FriendMergerTests: XCTestCase {

    var sut: FriendMerger!

    override func setUp() {
        super.setUp()
        sut = FriendMerger()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_merge_uniqueFids_allKept() {
        let list = [
            Friend(fid: "001", name: "Alice", status: 1, isTop: "0", updateDate: "20190801"),
            Friend(fid: "002", name: "Bob",   status: 1, isTop: "0", updateDate: "20190801")
        ]
        let result = sut.merge(list)
        XCTAssertEqual(result.count, 2)
    }

    func test_merge_duplicateFid_takesNewerDate() {
        let list = [
            Friend(fid: "001", name: "Old", status: 1, isTop: "0", updateDate: "20190801"),
            Friend(fid: "001", name: "New", status: 1, isTop: "0", updateDate: "2019/08/02")
        ]
        let result = sut.merge(list)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "New")
    }

    func test_merge_duplicateFid_keepsList1IfNewer() {
        let list = [
            Friend(fid: "001", name: "New", status: 1, isTop: "0", updateDate: "2019/08/02"),
            Friend(fid: "001", name: "Old", status: 1, isTop: "0", updateDate: "20190801")
        ]
        let result = sut.merge(list)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "New")
    }

    func test_merge_maintainsInsertionOrder() {
        let list = [
            Friend(fid: "002", name: "Bob", status: 1, isTop: "0", updateDate: "20190801"),
            Friend(fid: "001", name: "Alice", status: 1, isTop: "0", updateDate: "20190801"),
            Friend(fid: "001", name: "AliceNew", status: 1, isTop: "0", updateDate: "2019/08/02")
        ]
        let result = sut.merge(list)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].fid, "002")
        XCTAssertEqual(result[1].fid, "001")
        XCTAssertEqual(result[1].name, "AliceNew")
    }
}

import XCTest
@testable import KOKO

final class FriendSorterTests: XCTestCase {
    
    var sut: FriendSorter!
    
    override func setUp() {
        super.setUp()
        sut = FriendSorter()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_sort_invitingStatusAlwaysFirst() {
        let f1 = Friend(fid: "1", name: "A", status: 1, isTop: "0", updateDate: "") // completed
        let f2 = Friend(fid: "2", name: "B", status: 2, isTop: "0", updateDate: "") // inviting
        let f3 = Friend(fid: "3", name: "C", status: 0, isTop: "0", updateDate: "") // inviteSent
        
        let result = sut.sort([f1, f2, f3])
        
        XCTAssertEqual(result.first?.name, "B", "Status 2 (inviting) should be first")
    }
    
    func test_sort_starBadgeSecond() {
        let f1 = Friend(fid: "1", name: "A", status: 1, isTop: "0", updateDate: "") // normal
        let f2 = Friend(fid: "2", name: "B", status: 1, isTop: "1", updateDate: "") // star
        let f3 = Friend(fid: "3", name: "C", status: 2, isTop: "0", updateDate: "") // inviting (first)
        
        let result = sut.sort([f1, f2, f3])
        
        XCTAssertEqual(result[0].name, "C")
        XCTAssertEqual(result[1].name, "B", "Star badge should be second after inviting")
        XCTAssertEqual(result[2].name, "A")
    }
    
    func test_sort_alphabeticalWhenOtherConditionsEqual() {
        let f1 = Friend(fid: "1", name: "Z", status: 1, isTop: "0", updateDate: "")
        let f2 = Friend(fid: "2", name: "A", status: 1, isTop: "0", updateDate: "")
        let f3 = Friend(fid: "3", name: "M", status: 1, isTop: "0", updateDate: "")
        
        let result = sut.sort([f1, f2, f3])
        
        XCTAssertEqual(result[0].name, "A")
        XCTAssertEqual(result[1].name, "M")
        XCTAssertEqual(result[2].name, "Z")
    }
}

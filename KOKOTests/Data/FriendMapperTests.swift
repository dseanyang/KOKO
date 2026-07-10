import XCTest
@testable import KOKO

final class FriendMapperTests: XCTestCase {

    func test_map_convertsDTOToEntity() {
        let dto = FriendDTO(name: "Test", status: 1, isTop: "1", fid: "123", updateDate: "20190801")
        let entity = FriendMapper.map(dto)
        
        XCTAssertEqual(entity.name, "Test")
        XCTAssertEqual(entity.status, 1)
        XCTAssertEqual(entity.isTop, "1")
        XCTAssertEqual(entity.fid, "123")
        XCTAssertEqual(entity.updateDate, "20190801")
    }

    func test_map_array_convertsAllDTOs() {
        let dtos = [
            FriendDTO(name: "A", status: 0, isTop: "0", fid: "1", updateDate: ""),
            FriendDTO(name: "B", status: 1, isTop: "1", fid: "2", updateDate: "")
        ]
        let entities = FriendMapper.map(dtos)
        
        XCTAssertEqual(entities.count, 2)
        XCTAssertEqual(entities[0].name, "A")
        XCTAssertEqual(entities[1].name, "B")
    }
}

final class UserMapperTests: XCTestCase {
    
    func test_map_convertsDTOToEntity() {
        let dto = UserDTO(name: "Bob", kokoid: "bob123")
        let entity = UserMapper.map(dto)
        
        XCTAssertEqual(entity.name, "Bob")
        XCTAssertEqual(entity.kokoid, "bob123")
    }
}

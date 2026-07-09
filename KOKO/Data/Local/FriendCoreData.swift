import Foundation
import CoreData

// MARK: - CDFriend (NSManagedObject)
@objc(CDFriend)
public class CDFriend: NSManagedObject {
    @NSManaged public var fid: String
    @NSManaged public var name: String
    @NSManaged public var status: Int64
    @NSManaged public var isTop: String
    @NSManaged public var updateDate: String
    @NSManaged public var scenarioID: Int64

    func toFriend() -> Friend {
        Friend(name: name, status: Int(status), isTop: isTop, fid: fid, updateDate: updateDate)
    }

    static var entityDescription: NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDFriend"
        entity.managedObjectClassName = NSStringFromClass(CDFriend.self)

        let fidAttr = NSAttributeDescription()
        fidAttr.name = "fid"
        fidAttr.attributeType = .stringAttributeType
        fidAttr.isOptional = false

        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = false

        let statusAttr = NSAttributeDescription()
        statusAttr.name = "status"
        statusAttr.attributeType = .integer64AttributeType
        statusAttr.isOptional = false

        let isTopAttr = NSAttributeDescription()
        isTopAttr.name = "isTop"
        isTopAttr.attributeType = .stringAttributeType
        isTopAttr.isOptional = false

        let updateDateAttr = NSAttributeDescription()
        updateDateAttr.name = "updateDate"
        updateDateAttr.attributeType = .stringAttributeType
        updateDateAttr.isOptional = false

        let scenarioAttr = NSAttributeDescription()
        scenarioAttr.name = "scenarioID"
        scenarioAttr.attributeType = .integer64AttributeType
        scenarioAttr.isOptional = false

        entity.properties = [fidAttr, nameAttr, statusAttr, isTopAttr, updateDateAttr, scenarioAttr]
        return entity
    }
}

// MARK: - FriendLocalDataSourceProtocol
protocol FriendLocalDataSourceProtocol {
    func fetchFriends(scenario: FriendScenario) -> [Friend]?
    func saveFriends(_ friends: [Friend], scenario: FriendScenario)
    func clearCache()
}

// MARK: - FriendCoreData
final class FriendCoreData: FriendLocalDataSourceProtocol {

    private let manager = CoreDataManager.shared

    func fetchFriends(scenario: FriendScenario) -> [Friend]? {
        let predicate = NSPredicate(format: "scenarioID == %d", scenario.rawValue)
        let cdFriends: [CDFriend] = manager.fetch(entityName: "CDFriend", predicate: predicate)
        guard !cdFriends.isEmpty else { return nil }
        return cdFriends.map { $0.toFriend() }
    }

    func saveFriends(_ friends: [Friend], scenario: FriendScenario) {
        let predicate = NSPredicate(format: "scenarioID == %d", scenario.rawValue)
        manager.delete(entityName: "CDFriend", predicate: predicate)
        manager.save { context in
            for friend in friends {
                let cdFriend = CDFriend(context: context)
                cdFriend.fid        = friend.fid
                cdFriend.name       = friend.name
                cdFriend.status     = Int64(friend.status)
                cdFriend.isTop      = friend.isTop
                cdFriend.updateDate = friend.updateDate
                cdFriend.scenarioID = Int64(scenario.rawValue)
            }
        }
    }

    func clearCache() {
        manager.delete(entityName: "CDFriend")
    }
}

import Foundation
import CoreData

@objc(CDUser)
public class CDUser: NSManagedObject {
    @NSManaged public var kokoid: String
    @NSManaged public var name: String

    func toUser() -> User {
        User(name: name, kokoid: kokoid)
    }

    static var entityDescription: NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDUser"
        entity.managedObjectClassName = NSStringFromClass(CDUser.self)

        let kokoidAttr = NSAttributeDescription()
        kokoidAttr.name = "kokoid"
        kokoidAttr.attributeType = .stringAttributeType
        kokoidAttr.isOptional = false

        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = false

        entity.properties = [kokoidAttr, nameAttr]
        return entity
    }
}

protocol UserLocalDataSourceProtocol {
    func fetchUser() throws -> User?
    func saveUser(_ user: User) throws
    func clearCache() throws
}

final class UserCoreData: UserLocalDataSourceProtocol {

    private let manager = CoreDataManager.shared

    func fetchUser() throws -> User? {
        let cdUsers: [CDUser] = try manager.fetch(entityName: "CDUser")
        return cdUsers.first?.toUser()
    }

    func saveUser(_ user: User) throws {
        try manager.delete(entityName: "CDUser")
        try manager.save { context in
            let cdUser = CDUser(context: context)
            cdUser.name   = user.name
            cdUser.kokoid = user.kokoid
        }
    }

    func clearCache() throws {
        try manager.delete(entityName: "CDUser")
    }
}

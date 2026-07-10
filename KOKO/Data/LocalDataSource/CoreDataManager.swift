import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    let persistentContainer: NSPersistentContainer = {
        let model = NSManagedObjectModel()
        model.entities = [
            CDFriend.entityDescription,
            CDUser.entityDescription
        ]
        let container = NSPersistentContainer(name: "FriendListCache", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }


    func fetch<T: NSManagedObject>(entityName: String, predicate: NSPredicate? = nil) -> [T] {
        var results: [T] = []
        let ctx = context
        ctx.performAndWait {
            let request = NSFetchRequest<T>(entityName: entityName)
            request.predicate = predicate
            if let fetched = try? ctx.fetch(request) {
                results = fetched
            }
        }
        return results
    }

    func delete(entityName: String, predicate: NSPredicate? = nil) {
        let ctx = context
        ctx.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            request.predicate = predicate
            if let fetched = try? ctx.fetch(request) {
                fetched.forEach { ctx.delete($0) }
            }
            try? ctx.save()
        }
    }

    func save(_ block: (NSManagedObjectContext) -> Void) {
        let ctx = context
        ctx.performAndWait {
            block(ctx)
            if ctx.hasChanges {
                try? ctx.save()
            }
        }
    }
}

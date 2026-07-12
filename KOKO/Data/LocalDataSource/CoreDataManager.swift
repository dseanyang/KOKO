import Foundation
import CoreData
import os

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    private let logger = Logger(subsystem: "com.koko.ioskoko", category: "CoreData")

    let persistentContainer: NSPersistentContainer = {
        let model = NSManagedObjectModel()
        model.entities = [
            CDFriend.entityDescription,
            CDUser.entityDescription
        ]
        let container = NSPersistentContainer(name: "FriendListCache", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                Logger(subsystem: "com.koko.ioskoko", category: "CoreData")
                    .error("Failed to load persistent store: \(error.localizedDescription, privacy: .public)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }


    func fetch<T: NSManagedObject>(entityName: String, predicate: NSPredicate? = nil) throws -> [T] {
        var result: Result<[T], Error> = .success([])
        let ctx = context
        ctx.performAndWait {
            let request = NSFetchRequest<T>(entityName: entityName)
            request.predicate = predicate
            do {
                result = .success(try ctx.fetch(request))
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }

    func delete(entityName: String, predicate: NSPredicate? = nil) throws {
        var result: Result<Void, Error> = .success(())
        let ctx = context
        ctx.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            request.predicate = predicate
            do {
                let fetched = try ctx.fetch(request)
                fetched.forEach { ctx.delete($0) }
                try ctx.save()
            } catch {
                result = .failure(error)
            }
        }
        try result.get()
    }

    func save(_ block: (NSManagedObjectContext) -> Void) throws {
        var result: Result<Void, Error> = .success(())
        let ctx = context
        ctx.performAndWait {
            block(ctx)
            if ctx.hasChanges {
                do {
                    try ctx.save()
                } catch {
                    result = .failure(error)
                }
            }
        }
        do {
            try result.get()
        } catch {
            logger.error("Failed to save cache data: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
}

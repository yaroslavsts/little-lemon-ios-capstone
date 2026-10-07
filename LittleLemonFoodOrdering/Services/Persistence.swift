import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    private static let model: NSManagedObjectModel = {
        let url = Bundle.main.url(forResource: "MenuDatabase", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: url)!
    }()
    let container: NSPersistentContainer

    init(inMemory: Bool = false, storeURL: URL? = nil) {
        container = NSPersistentContainer(name: "MenuDatabase", managedObjectModel: Self.model)
        if inMemory { container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null") }
        else if let storeURL { container.persistentStoreDescriptions.first?.url = storeURL }
        container.loadPersistentStores { _, error in
            if let error { fatalError("Unable to load menu database: \(error.localizedDescription)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func importMenu(_ items: [MenuItem], into context: NSManagedObjectContext) throws {
        var ids = Set<Int>()
        for item in items {
            guard item.id > 0, ids.insert(item.id).inserted,
                  !item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let price = Double(item.price), price.isFinite, price >= 0,
                  let imageURL = URL(string: item.image), imageURL.scheme == "https", imageURL.host != nil else {
                throw MenuError.invalidData
            }
        }
        let saved = try context.fetch(Dish.fetchRequest())
        var byID: [Int64: Dish] = [:]
        for dish in saved {
            if byID[dish.id] == nil { byID[dish.id] = dish } else { context.delete(dish) }
        }
        for item in items {
            let id = Int64(item.id)
            let dish = byID[id] ?? Dish(context: context)
            dish.id = id
            dish.title = item.title
            dish.price = item.price
            dish.image = item.image
            dish.itemDescription = item.description
            dish.category = item.category.lowercased()
            byID[id] = dish
        }
        for dish in saved where !ids.contains(Int(dish.id)) { context.delete(dish) }
        if context.hasChanges { try context.save() }
    }
}

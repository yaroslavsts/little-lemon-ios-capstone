import Foundation
import CoreData

struct MenuList: Decodable {
    let menu: [MenuItem]
}

struct MenuItem: Decodable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let price: String
    let image: String
    let category: String
}

enum MenuCategory: String, CaseIterable, Identifiable {
    case starters, mains, desserts, drinks
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

struct MenuQuery: Hashable {
    var search = ""
    var categories: Set<MenuCategory> = []

    var predicate: NSPredicate {
        var predicates: [NSPredicate] = []
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty { predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", query)) }
        if !categories.isEmpty {
            predicates.append(NSPredicate(format: "category IN %@", categories.map(\.rawValue)))
        }
        return predicates.isEmpty ? NSPredicate(value: true) : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    static var sortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
    }
}

@objc(Dish)
public final class Dish: NSManagedObject, Identifiable {
    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var price: String
    @NSManaged public var image: String
    @NSManaged public var itemDescription: String
    @NSManaged public var category: String

    static func fetchRequest() -> NSFetchRequest<Dish> { NSFetchRequest<Dish>(entityName: "Dish") }
    var formattedPrice: String { String(format: "$%.2f", Double(price) ?? 0) }
    var imageURL: URL? {
        URL(string: image.replacingOccurrences(of: "https://github.com/", with: "https://raw.githubusercontent.com/")
            .replacingOccurrences(of: "/blob/", with: "/").replacingOccurrences(of: "?raw=true", with: ""))
    }
}

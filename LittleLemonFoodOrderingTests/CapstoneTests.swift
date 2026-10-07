import XCTest
import CoreData
@testable import LittleLemonFoodOrdering

@MainActor
final class CapstoneTests: XCTestCase {
    private func profile() -> UserProfile {
        UserProfile(firstName: " Alex ", lastName: " Morgan ", email: " alex@example.com ", phone: " 12345 ")
    }

    private func withDefaults(_ operation: (UserDefaults) -> Void) {
        let suite = "CapstoneTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        operation(defaults)
    }

    func testFirstLaunchRequiresOnboarding() {
        withDefaults { defaults in
            let session = UserSession(defaults: defaults)
            XCTAssertFalse(session.isLoggedIn)
            XCTAssertEqual(session.profile, UserProfile())
        }
    }

    func testRegistrationTrimsAndRestoresProfileAfterRestart() {
        withDefaults { defaults in
            let session = UserSession(defaults: defaults)
            XCTAssertTrue(session.save(profile()))
            let restarted = UserSession(defaults: defaults)
            XCTAssertTrue(restarted.isLoggedIn)
            XCTAssertEqual(restarted.profile.firstName, "Alex")
            XCTAssertEqual(restarted.profile.email, "alex@example.com")
            XCTAssertEqual(restarted.profile.phone, "12345")
        }
    }

    func testProfileEditsAndPreferencesSurviveRestart() {
        withDefaults { defaults in
            let session = UserSession(defaults: defaults)
            session.save(profile())
            var edited = session.profile
            edited.lastName = "Taylor"
            edited.newsletter = true
            edited.orderUpdates = false
            session.save(edited)
            XCTAssertEqual(UserSession(defaults: defaults).profile, edited)
        }
    }

    func testLogoutClearsPersonalInformationAndRegistration() {
        withDefaults { defaults in
            let session = UserSession(defaults: defaults)
            session.save(profile())
            session.logOut()
            XCTAssertNil(defaults.data(forKey: UserSession.profileKey))
            XCTAssertEqual(session.profile, UserProfile())
            XCTAssertFalse(UserSession(defaults: defaults).isLoggedIn)
        }
    }

    func testInvalidProfileCannotOverwriteValidSavedProfile() {
        withDefaults { defaults in
            let session = UserSession(defaults: defaults)
            session.save(profile())
            let saved = session.profile
            var invalid = saved
            invalid.email = "broken@"
            XCTAssertFalse(session.save(invalid))
            XCTAssertEqual(UserSession(defaults: defaults).profile, saved)
        }
    }

    func testMalformedStoredProfileFallsBackToOnboarding() {
        withDefaults { defaults in
            defaults.set(Data("broken".utf8), forKey: UserSession.profileKey)
            XCTAssertFalse(UserSession(defaults: defaults).isLoggedIn)
        }
    }

    func testRequiredFieldsAndEmailValidation() {
        XCTAssertTrue(profile().isValid)
        XCTAssertTrue(UserProfile.isValidEmail("alex+menu@example.co.uk"))
        for email in ["", "alex", "alex@", "alex@localhost", "a b@example.com"] {
            XCTAssertFalse(UserProfile.isValidEmail(email), email)
        }
        var invalid = profile()
        invalid.firstName = " \n "
        XCTAssertFalse(invalid.isValid)
    }

    private func item(_ id: Int, _ title: String, category: String = "starters", price: String = "10") -> MenuItem {
        MenuItem(id: id, title: title, description: "Description", price: price,
                 image: "https://example.com/dish.jpg", category: category)
    }

    func testMenuImportUpdatesWithoutDuplicatesAndRemovesStaleDishes() throws {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        try PersistenceController.importMenu([item(1, "Old"), item(2, "Removed")], into: context)
        try PersistenceController.importMenu([item(1, "Updated"), item(3, "New")], into: context)
        let dishes = try context.fetch(Dish.fetchRequest())
        XCTAssertEqual(Set(dishes.map(\.id)), [1, 3])
        XCTAssertEqual(dishes.first { $0.id == 1 }?.title, "Updated")
        try PersistenceController.importMenu([item(1, "Updated"), item(3, "New")], into: context)
        XCTAssertEqual(try context.count(for: Dish.fetchRequest()), 2)
    }

    func testInvalidMenuDoesNotReplaceCachedDishes() throws {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        try PersistenceController.importMenu([item(1, "Saved")], into: context)
        XCTAssertThrowsError(try PersistenceController.importMenu([item(2, "Invalid", price: "NaN")], into: context))
        XCTAssertThrowsError(try PersistenceController.importMenu([item(2, "A"), item(2, "B")], into: context))
        XCTAssertEqual(try context.fetch(Dish.fetchRequest()).map(\.title), ["Saved"])
    }

    func testSearchIgnoresCaseAndDiacriticsInSQLite() throws {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        try PersistenceController.importMenu([item(1, "Crème brûlée"), item(2, "Greek Salad")], into: context)
        let request = Dish.fetchRequest()
        request.predicate = MenuQuery(search: " CREME ").predicate
        XCTAssertEqual(try context.fetch(request).map(\.title), ["Crème brûlée"])
    }

    func testCategoriesCombineWithSearchAndSupportMultipleSelections() throws {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        try PersistenceController.importMenu([item(1, "Lemon Pasta", category: "mains"), item(2, "Lemon Cake", category: "desserts"), item(3, "Salad")], into: context)
        let request = Dish.fetchRequest()
        request.predicate = MenuQuery(search: "lemon", categories: [.desserts]).predicate
        XCTAssertEqual(try context.fetch(request).map(\.id), [2])
        request.predicate = MenuQuery(search: "LEMON", categories: [.desserts, .mains]).predicate
        XCTAssertEqual(Set(try context.fetch(request).map(\.id)), [1, 2])
        request.predicate = MenuQuery(categories: [.drinks]).predicate
        XCTAssertTrue(try context.fetch(request).isEmpty)
        request.predicate = MenuQuery().predicate
        XCTAssertEqual(try context.count(for: request), 3)
    }

    func testAlphabeticalSortingUsesLocalizedComparison() throws {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        try PersistenceController.importMenu([item(1, "Zucchini"), item(2, "éclair"), item(3, "apple")], into: context)
        let request = Dish.fetchRequest()
        request.sortDescriptors = MenuQuery.sortDescriptors
        XCTAssertEqual(try context.fetch(request).map(\.title), ["apple", "éclair", "Zucchini"])
    }

    func testMenuPersistsInReopenedSQLiteStore() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("menu-\(UUID().uuidString).sqlite")
        defer { for suffix in ["", "-wal", "-shm"] { try? FileManager.default.removeItem(atPath: url.path + suffix) } }
        let first = PersistenceController(storeURL: url)
        try PersistenceController.importMenu([item(1, "Saved dish")], into: first.container.viewContext)
        for store in first.container.persistentStoreCoordinator.persistentStores {
            try first.container.persistentStoreCoordinator.remove(store)
        }
        let second = PersistenceController(storeURL: url)
        XCTAssertEqual(try second.container.viewContext.fetch(Dish.fetchRequest()).map(\.title), ["Saved dish"])
        for store in second.container.persistentStoreCoordinator.persistentStores {
            try second.container.persistentStoreCoordinator.remove(store)
        }
    }

    func testLiveAPIShapeDecodes() throws {
        let json = #"{"menu":[{"id":1,"title":"Greek Salad","description":"Fresh salad","price":"10","image":"https://example.com/salad.jpg","category":"starters"}]}"#
        let result = try JSONDecoder().decode(MenuList.self, from: Data(json.utf8))
        XCTAssertEqual(result.menu.first?.title, "Greek Salad")
        XCTAssertEqual(result.menu.first?.category, "starters")
    }

    func testGitHubImageURLIsConvertedToRawAsset() throws {
        let persistence = PersistenceController(inMemory: true)
        let dish = Dish(context: persistence.container.viewContext)
        dish.image = "https://github.com/Meta-Mobile-Developer-PC/Working-With-Data-API/blob/main/images/lemonDessert%202.jpg?raw=true"
        XCTAssertEqual(dish.imageURL?.absoluteString, "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/images/lemonDessert%202.jpg")
    }
}

import SwiftUI
import CoreData

@main
struct LittleLemonFoodOrderingApp: App {
    @StateObject private var session = UserSession()
    private let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isLoggedIn { HomeView() }
                else { OnboardingView() }
            }
            .id(session.isLoggedIn)
            .environmentObject(session)
            .environment(\.managedObjectContext, persistence.container.viewContext)
            .tint(Brand.green)
        }
    }
}

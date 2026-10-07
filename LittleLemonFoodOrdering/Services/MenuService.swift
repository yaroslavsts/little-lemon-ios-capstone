import Foundation
import Combine
import CoreData

@MainActor
final class MenuService: ObservableObject {
    nonisolated static let menuURL = URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json")!
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    private let session: URLSession
    private let url: URL

    init(session: URLSession = .shared, url: URL = MenuService.menuURL) {
        self.session = session
        self.url = url
    }

    func load(into context: NSManagedObjectContext) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                throw MenuError.serverResponse
            }
            let menu = try JSONDecoder().decode(MenuList.self, from: data)
            try await context.perform {
                do { try PersistenceController.importMenu(menu.menu, into: context) }
                catch { context.rollback(); throw error }
            }
        } catch is CancellationError { }
        catch let error as URLError where error.code == .cancelled { }
        catch { errorMessage = "Could not refresh the menu. Saved dishes are still available. \(error.localizedDescription)" }
    }
}

enum MenuError: LocalizedError {
    case serverResponse, invalidData
    var errorDescription: String? {
        switch self {
        case .serverResponse: return "The server did not return a successful response."
        case .invalidData: return "The menu contains invalid or duplicate items."
        }
    }
}

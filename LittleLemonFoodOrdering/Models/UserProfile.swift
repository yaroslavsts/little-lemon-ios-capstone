import Foundation
import Combine

struct UserProfile: Codable, Equatable {
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var orderUpdates = true
    var specialOffers = false
    var newsletter = false

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Self.isValidEmail(email)
    }

    var trimmed: UserProfile {
        var copy = self
        copy.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        return copy
    }

    var initials: String {
        String(firstName.prefix(1) + lastName.prefix(1)).uppercased()
    }

    static func isValidEmail(_ value: String) -> Bool {
        let email = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return email.range(of: #"^[A-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Z0-9](?:[A-Z0-9-]*[A-Z0-9])?(?:\.[A-Z0-9](?:[A-Z0-9-]*[A-Z0-9])?)+$"#, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

@MainActor
final class UserSession: ObservableObject {
    @Published private(set) var profile: UserProfile
    @Published private(set) var isLoggedIn: Bool
    private let defaults: UserDefaults
    static let profileKey = "littleLemon.savedProfile"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.profileKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data), saved.isValid {
            profile = saved
            isLoggedIn = true
        } else {
            profile = UserProfile()
            isLoggedIn = false
        }
    }

    @discardableResult
    func save(_ value: UserProfile) -> Bool {
        let value = value.trimmed
        guard value.isValid, let data = try? JSONEncoder().encode(value) else { return false }
        defaults.set(data, forKey: Self.profileKey)
        profile = value
        isLoggedIn = true
        return true
    }

    func logOut() {
        defaults.removeObject(forKey: Self.profileKey)
        profile = UserProfile()
        isLoggedIn = false
    }
}

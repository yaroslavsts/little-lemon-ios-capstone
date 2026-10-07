import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: UserSession
    @State private var draft: UserProfile
    @State private var showSaved = false

    init(profile: UserProfile) { _draft = State(initialValue: profile) }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    AvatarView(initials: draft.initials, size: 72)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your profile").font(.title2.bold())
                        Text("Personal information").font(.subheadline).foregroundStyle(.secondary)
                    }
                }.padding(.vertical, 8)
            }
            Section("Personal information") { ProfileFields(profile: $draft) }
            Section("Email notifications") {
                Toggle("Order updates", isOn: $draft.orderUpdates)
                Toggle("Special offers", isOn: $draft.specialOffers)
                Toggle("Newsletter", isOn: $draft.newsletter)
            }
            Section {
                Button("Save changes") { showSaved = session.save(draft); draft = session.profile }
                    .disabled(!draft.isValid || draft.trimmed == session.profile)
                    .accessibilityIdentifier("save-profile")
                Button("Discard changes") { draft = session.profile }
                    .disabled(draft == session.profile)
            }
            Section {
                Button("Log out", role: .destructive) { session.logOut() }
                    .accessibilityIdentifier("logout")
            } footer: { Text("Logging out clears your saved profile and returns to onboarding.") }
        }
        .navigationTitle("Profile").navigationBarTitleDisplayMode(.inline)
        .alert("Profile saved", isPresented: $showSaved) {
            Button("OK", role: .cancel) { }
        } message: { Text("Your changes will be available next time you open Little Lemon.") }
    }
}

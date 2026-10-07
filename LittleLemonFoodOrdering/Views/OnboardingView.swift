import SwiftUI

private enum OnboardingStep: Int, Hashable {
    case welcome = 1, name, contact
}

struct OnboardingView: View {
    @EnvironmentObject private var session: UserSession
    @State private var profile = UserProfile()
    @State private var path: [OnboardingStep] = []

    var body: some View {
        NavigationStack(path: $path) {
            page(.welcome)
                .navigationDestination(for: OnboardingStep.self) { page($0) }
        }
    }

    private func page(_ step: OnboardingStep) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image("Logo").resizable().scaledToFit().frame(height: 50)
                    .frame(maxWidth: .infinity).accessibilityLabel("Little Lemon")
                Text("STEP \(step.rawValue) OF 3").font(.caption.bold()).foregroundStyle(Brand.green)
                switch step {
                case .welcome:
                    HeroView().padding(20).background(Brand.green).clipShape(RoundedRectangle(cornerRadius: 16))
                    Text("Welcome to our table").font(.title2.bold())
                    Text("Create your profile to explore our menu and choose your Mediterranean favorites.")
                        .foregroundStyle(.secondary)
                case .name:
                    Text("Let's get to know you").font(.title.bold())
                    Text("Tell us your name to personalize your Little Lemon experience.").foregroundStyle(.secondary)
                    field("First name", text: $profile.firstName, identifier: "first-name")
                    field("Last name", text: $profile.lastName, identifier: "last-name")
                case .contact:
                    Text("Stay in touch").font(.title.bold())
                    Text("Add your email to complete your profile. You can update your details later.").foregroundStyle(.secondary)
                    field("Email", text: $profile.email, identifier: "email")
                        .keyboardType(.emailAddress).textContentType(.emailAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                    field("Phone (optional)", text: $profile.phone, identifier: "phone")
                        .keyboardType(.phonePad).textContentType(.telephoneNumber)
                    if !profile.email.isEmpty && !UserProfile.isValidEmail(profile.email) {
                        Text("Enter a valid email address.").font(.caption).foregroundStyle(.red)
                    }
                }
            }.padding(20)
        }
        .navigationTitle(step == .welcome ? "Welcome" : step == .name ? "Your details" : "Contact details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button(step == .contact ? "Register" : "Next") {
                if step == .welcome { path.append(.name) }
                else if step == .name { path.append(.contact) }
                else { session.save(profile) }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!canContinue(step)).opacity(canContinue(step) ? 1 : 0.45)
            .accessibilityIdentifier(step == .contact ? "register" : "onboarding-next")
            .padding(20).background(.bar)
        }
    }

    private func canContinue(_ step: OnboardingStep) -> Bool {
        switch step {
        case .welcome: return true
        case .name: return !profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !profile.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .contact: return profile.isValid
        }
    }

    private func field(_ label: String, text: Binding<String>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.subheadline.bold())
            TextField(label, text: text).textFieldStyle(.roundedBorder)
                .accessibilityIdentifier(identifier)
        }
    }
}

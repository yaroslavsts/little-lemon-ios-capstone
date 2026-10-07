import SwiftUI

enum Brand {
    static let green = Color(red: 73/255, green: 94/255, blue: 87/255)
    static let yellow = Color(red: 244/255, green: 206/255, blue: 20/255)
    static let light = Color(red: 237/255, green: 239/255, blue: 238/255)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.black)
            .background(Brand.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct AvatarView: View {
    let initials: String
    var size: CGFloat = 42
    var body: some View {
        Text(initials.isEmpty ? "LL" : initials)
            .font(.system(size: size * 0.35, weight: .semibold))
            .foregroundStyle(Brand.green)
            .frame(width: size, height: size)
            .background(Brand.light)
            .clipShape(Circle())
    }
}

struct HeroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Little Lemon")
                .font(.system(size: 44, weight: .medium, design: .serif))
                .foregroundStyle(Brand.yellow)
                .lineLimit(1).minimumScaleFactor(0.75)
            Text("Chicago").font(.system(size: 28, design: .serif)).foregroundStyle(.white)
            HStack(alignment: .center, spacing: 18) {
                Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                    .font(.subheadline).foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Image("Hero").resizable().scaledToFill()
                    .frame(width: 112, height: 116).clipShape(RoundedRectangle(cornerRadius: 14))
                    .accessibilityLabel("Bruschetta from Little Lemon")
            }
            .padding(.top, 8)
        }
    }
}

struct ProfileFields: View {
    @Binding var profile: UserProfile
    var body: some View {
        TextField("First name", text: $profile.firstName).textContentType(.givenName).accessibilityIdentifier("first-name")
        TextField("Last name", text: $profile.lastName).textContentType(.familyName).accessibilityIdentifier("last-name")
        TextField("Email", text: $profile.email)
            .keyboardType(.emailAddress).textContentType(.emailAddress)
            .textInputAutocapitalization(.never).autocorrectionDisabled()
            .accessibilityIdentifier("email")
        TextField("Phone (optional)", text: $profile.phone).keyboardType(.phonePad).textContentType(.telephoneNumber)
    }
}

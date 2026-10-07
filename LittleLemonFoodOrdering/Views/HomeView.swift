import SwiftUI
import CoreData

struct HomeView: View {
    @EnvironmentObject private var session: UserSession
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(sortDescriptors: MenuQuery.sortDescriptors) private var dishes: FetchedResults<Dish>
    @StateObject private var service = MenuService()
    @State private var query = MenuQuery()

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 20) {
                    HeroView()
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(Brand.green)
                        TextField("Search dishes", text: $query.search)
                            .textInputAutocapitalization(.never).autocorrectionDisabled()
                            .accessibilityIdentifier("menu-search")
                        if !query.search.isEmpty {
                            Button { query.search = "" } label: { Image(systemName: "xmark.circle.fill") }
                                .accessibilityLabel("Clear search").buttonStyle(.plain)
                        }
                    }.padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(20).background(Brand.green)
                .listRowInsets(EdgeInsets()).listRowSeparator(.hidden)

                VStack(alignment: .leading, spacing: 14) {
                    Text("ORDER FOR DELIVERY!").font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            categoryButton("All", selected: query.categories.isEmpty) { query.categories.removeAll() }
                            ForEach(MenuCategory.allCases) { category in
                                categoryButton(category.title, selected: query.categories.contains(category)) {
                                    if query.categories.contains(category) { query.categories.remove(category) }
                                    else { query.categories.insert(category) }
                                }
                            }
                        }
                    }
                }.padding(.vertical, 8).listRowSeparator(.hidden)

                if let error = service.errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(error).font(.footnote).foregroundStyle(.secondary)
                        Button("Try again") { Task { await service.load(into: context) } }
                    }
                }
                if dishes.isEmpty {
                    if service.isLoading { ProgressView("Loading menu…").frame(maxWidth: .infinity) }
                    else {
                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife").font(.title)
                            Text("No dishes found").font(.headline)
                            Text("Try another search or select All categories.").font(.subheadline).foregroundStyle(.secondary)
                        }.padding(.vertical, 30).frame(maxWidth: .infinity).listRowSeparator(.hidden)
                    }
                }
                ForEach(dishes) { dish in
                    NavigationLink { DishDetailView(dish: dish) } label: { DishRow(dish: dish) }
                        .accessibilityIdentifier("dish-\(dish.id)")
                }
            }
            .listStyle(.plain).scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("Logo").resizable().scaledToFit().frame(width: 170, height: 40).accessibilityLabel("Little Lemon")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { ProfileView(profile: session.profile) } label: { AvatarView(initials: session.profile.initials) }
                        .accessibilityLabel("Your profile").accessibilityIdentifier("profile")
                }
            }
            .task { await service.load(into: context) }
            .task(id: query) { dishes.nsPredicate = query.predicate }
            .refreshable { await service.load(into: context) }
        }
    }

    private func categoryButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.subheadline.bold()).padding(.horizontal, 14).padding(.vertical, 9)
                .foregroundStyle(Brand.green).background(selected ? Brand.yellow : Brand.light)
                .clipShape(Capsule())
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct DishPhoto: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { image in image.resizable().scaledToFill() } placeholder: {
            ZStack { Brand.light; Image(systemName: "fork.knife").foregroundStyle(Brand.green) }
        }
    }
}

struct DishRow: View {
    @ObservedObject var dish: Dish
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(dish.title).font(.headline).foregroundStyle(.primary)
                Text(dish.itemDescription).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                Text(dish.formattedPrice).font(.subheadline.bold()).foregroundStyle(Brand.green)
            }.frame(maxWidth: .infinity, alignment: .leading)
            DishPhoto(url: dish.imageURL).frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10)).accessibilityHidden(true)
        }.padding(.vertical, 8)
    }
}

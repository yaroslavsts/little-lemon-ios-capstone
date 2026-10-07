import SwiftUI

struct DishDetailView: View {
    @ObservedObject var dish: Dish
    @State private var quantity = 1
    @State private var showConfirmation = false
    private var total: String { String(format: "$%.2f", (Double(dish.price) ?? 0) * Double(quantity)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DishPhoto(url: dish.imageURL).frame(height: 240).clipped()
                    .accessibilityLabel(dish.title)
                VStack(alignment: .leading, spacing: 18) {
                    Text(dish.category.capitalized).font(.caption.bold()).foregroundStyle(Brand.green)
                    Text(dish.title).font(.largeTitle.bold())
                    Text(dish.itemDescription).foregroundStyle(.secondary)
                    Text(dish.formattedPrice).font(.title2.bold()).foregroundStyle(Brand.green)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                }.padding(.horizontal, 20)
            }
        }
        .navigationTitle(dish.title).navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button("Place order · \(total)") { showConfirmation = true }
                .buttonStyle(PrimaryButtonStyle()).accessibilityIdentifier("place-order")
                .padding(20).background(.bar)
        }
        .alert("Order confirmed", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) { }
        } message: { Text("\(quantity) × \(dish.title) — \(total)\nThank you for choosing Little Lemon!") }
    }
}

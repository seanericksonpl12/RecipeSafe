import ComposableArchitecture
import SwiftUI

struct ShoppingProgressHeader: View {

  let store: StoreOf<ShoppingListReducer>

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("\(store.checkedCount) of \(store.shoppingList.count) items")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(Color.Text.secondary)

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(Color(uiColor: .tertiarySystemFill))
            .frame(height: 4)
          Capsule()
            .fill(Color.green)
            .frame(width: geo.size.width * store.progress, height: 4)
            .animation(.easeInOut(duration: 0.3), value: store.progress)
        }
      }
      .frame(height: 4)
    }
    .padding(.horizontal)
    .padding(.top, 4)
  }
}

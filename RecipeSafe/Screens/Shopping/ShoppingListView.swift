import ComposableArchitecture
import SwiftUI

struct ShoppingListView: View {

  @Bindable var store: StoreOf<ShoppingListReducer>

  var body: some View {
    NavigationStack(path: $store.scope(state: \.navPath, action: \.navPath)) {
      ScrollView {
        VStack(spacing: 0) {
          ShoppingProgressHeader(store: store)
          ShoppingRecipesSection(store: store)
          ShoppingGrocerySections(store: store)
          if !store.isEditing {
            clearCheckedButton
          }
        }
      }
      .scrollContentBackground(.hidden)
      .background(Color.Surface.primary)
      .navigationTitle("Grocery List")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Text("Grocery List")
            .font(.largeTitle)
            .fontWeight(.heavy)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.top)
        }
        .removeLiquidGlassEffect()
        ToolbarItem(placement: .title) {
          Color.clear
        }
        ToolbarItem(placement: .topBarTrailing) {
          HStack {
            if store.isEditing {
              Button("Done") {
                store.send(.toggleEditMode, animation: .default)
              }
              .fontWeight(.semibold)
            } else {
              Button {
                store.send(.addRecipeTapped)
              } label: {
                Image(systemName: "plus")
                  .font(.body.weight(.medium))
              }
              Menu {
                Button("Edit") {
                  store.send(.toggleEditMode, animation: .default)
                }
                Button("Reset Selected") {
                  // TODO: reset
                }
                Button("Delete All", role: .destructive) {
                  store.send(.deleteAllIngredients)
                }
              } label: {
                Image(systemName: "ellipsis")
                  .font(.body.weight(.medium))
                  .frame(width: 28, height: 28)
                  .contentShape(Rectangle())
              }
            }
          }
        }
      }
      .sheet(
        item: $store.scope(
          state: \.destination?.selectRecipes,
          action: \.destination.selectRecipes
        )
      ) { selectStore in
        SelectRecipesView(store: selectStore)
      }
      .alert($store.scope(state: \.alert, action: \.alert))
      .task { store.send(.task) }
    } destination: { path in
      switch path.case {
      case let .recipe(store):
        NewRecipeView(store: store)
      }
    }
  }

  @ViewBuilder
  private var clearCheckedButton: some View {
    if store.checkedCount > 0 {
      Button {
        store.send(.clearChecked)
      } label: {
        Text("Reset Checked Items (\(store.checkedCount))")
          .font(.body)
          .fontWeight(.medium)
          .foregroundStyle(.red)
      }
      .padding(.top, 16)
      .padding(.bottom, 24)
    }
  }
}

#if DEBUG
#Preview {
  var state = ShoppingListState()
  state.shoppingList = [
    ShoppingListModel(id: UUID(), value: "Ground beef", selected: true, index: 0),
    ShoppingListModel(id: UUID(), value: "Chicken thighs", selected: false, index: 1),
    ShoppingListModel(id: UUID(), value: "Garlic", selected: true, index: 2),
    ShoppingListModel(id: UUID(), value: "Fresh parsley", selected: true, index: 3),
    ShoppingListModel(id: UUID(), value: "Thai basil", selected: false, index: 4),
    ShoppingListModel(id: UUID(), value: "Lemon", selected: false, index: 5),
    ShoppingListModel(id: UUID(), value: "Onion", selected: false, index: 6),
    ShoppingListModel(id: UUID(), value: "Eggs", selected: false, index: 7),
    ShoppingListModel(id: UUID(), value: "Parmesan cheese", selected: false, index: 8),
    ShoppingListModel(id: UUID(), value: "Heavy cream", selected: false, index: 9),
    ShoppingListModel(id: UUID(), value: "Spaghetti", selected: false, index: 10),
    ShoppingListModel(id: UUID(), value: "Olive oil", selected: false, index: 11),
    ShoppingListModel(id: UUID(), value: "Jasmine rice", selected: false, index: 12),
    ShoppingListModel(id: UUID(), value: "Fish sauce", selected: false, index: 13),
    ShoppingListModel(id: UUID(), value: "Soy sauce", selected: false, index: 14),
    ShoppingListModel(id: UUID(), value: "Garam masala", selected: false, index: 15),
  ]
  state.recipes = [
    Recipe(title: "Spaghetti & Meatballs"),
    Recipe(title: "Chicken Tikka Masala"),
    Recipe(title: "Thai Basil Fried Rice"),
  ]
  return ShoppingListView(store: .init(
    initialState: state,
    reducer: EmptyReducer.init)
  )
}
#endif

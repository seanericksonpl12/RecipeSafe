import ComposableArchitecture
import SwiftUI

struct AllRecipesView: View {
  
  @Bindable private var store: StoreOf<AllRecipesReducer>
  @State private var showSearchBar: Bool = false
  
  init(store: StoreOf<AllRecipesReducer>) {
    self.store = store
  }
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.navPath, action: \.navPath)) {
      content
        .background(Color(uiColor: UIColor.quaternarySystemFill))
        .navigationTitle("content.nav.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Text("content.nav.title".localized)
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
            Button {
              
            } label: {
              Label("filter", systemImage: "line.3.horizontal.decrease")
            }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              store.send(.createCustomRecipe)
            } label: {
              Label("content.toolbar.add".localized, systemImage: "plus")
            }
          }
        }
        .fullScreenCover(
          item: $store.scope(state: \.destination?.recipe, action: \.destination.recipe)
        ) {
          CustomRecipeView(store: $0)
        }
        .task { store.send(.task) }
        .pageLoad(.allRecipes)
      
    } destination: { path in
      switch path.case {
      case let .recipe(store):
        RecipeView(store: store)
      }
    }
    
  }
}

private extension AllRecipesView {
  var content: some View {
    ScrollView {
      if store.recipeList.isEmpty {
        EmptyListView(description: "empty.desc.1".localized)
      } else {
        ForEach(store.searchList) { recipe in
          Button {
            store.send(.recipeTapped(recipe))
          } label: {
            RecipeListCard(recipe: recipe)
          }
          .padding(.horizontal)
        }
      }
    }
    .searchable(
      text: $store.searchText.sending(\.searchTextUpdated),
      placement: .navigationBarDrawer,
      prompt: "content.search.prompt".localized
    )
    .scrollContentBackground(.hidden)
    .disabled(store.isLoading)
    .overlay {
      if store.isLoading {
        HStack {
          Spacer()
          LoadingView()
          Spacer()
        }
      }
    }
  }
}

#if DEBUG
#Preview {
  var state = AllRecipesState()
  state.recipeList = Recipe.allRecipesMock
  return AllRecipesView(store: .init(
    initialState: state,
    reducer: EmptyReducer.init)
  )
}
#endif

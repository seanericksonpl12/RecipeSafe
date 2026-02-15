import ComposableArchitecture
import SwiftUI

struct AllRecipesView: View {
  
  @Bindable private var store: StoreOf<AllRecipesReducer>
  
  init(store: StoreOf<AllRecipesReducer>) {
    self.store = store
  }
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.navPath, action: \.navPath)) {
      content
      .rootToolbar(title: "content.nav.title".localized) {
        if let createRecipeStore = store.scope(state: \.createRecipeState, action: \.createRecipe) {
          CreateRecipeView(store: createRecipeStore)
        } else {
          Button {
            store.send(.createCustomRecipe)
          } label: {
            Label("content.toolbar.add".localized, systemImage: "plus")
              .frame(width: 44, height: 44)
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
    List {
      if store.recipeList.isEmpty {
        EmptyListView(description: "empty.desc.1".localized)
      } else {
        ForEach(store.searchList) { item in
          Button {
            store.send(.recipeTapped(item))
          } label: {
            Text(item.title)
          }
        }
        .onDelete { store.send(.deleteRecipes($0)) }
        .listRowBackground(Color(uiColor: UIColor.secondarySystemBackground))
        
        if store.searchList.isEmpty {
          Spacer()
            .listRowBackground(Color.clear)
        }
      }
    }
    .searchable(
      text: $store.searchText.sending(\.searchTextUpdated),
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

struct TestingView: View {
  var body: some View {
    VStack {
      Text("testing...")
    }
    .modalToolbar {
      print("dismiss")
    }
  }
}

#if DEBUG
#Preview {
  AllRecipesView(store: .init(initialState: AllRecipesState(), reducer: AllRecipesReducer.init))
}
#endif

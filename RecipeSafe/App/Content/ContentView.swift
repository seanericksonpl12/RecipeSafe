import ComposableArchitecture
import SwiftUI

struct ContentView: View {
  
  @Bindable private var store: StoreOf<ContentReducer>
  
  init(store: StoreOf<ContentReducer>) {
    self.store = store
  }
  
  var content: some View {
    TabView(selection: $store.tabSelection.sending(\.tabSelected)) {
      AllRecipesView(store: store.scope(state: \.allRecipesState, action: \.allRecipes))
        .tabItem {
          Label("app.all".localized, systemImage: "line.3.horizontal")
        }
        .tag(ContentTab.allRecipes)
      GroupGridViewTCA(store: store.scope(state: \.groupGridState, action: \.groupGrid))
        .tabItem {
          Label("app.group".localized, systemImage: "circlebadge.2")
        }
        .tag(ContentTab.group)
      ShoppingListView(store: store.scope(state: \.shoppingListState, action: \.shoppingList))
        .tabItem {
          Label("app.shopping".localized, systemImage: "cart")
        }
        .tag(ContentTab.shoppingList)
    }
  }
  
  var body: some View {
    Group {
      switch store.viewState {
      case .started, .successfullyLoaded, .failedToLoad:
        content
      case .loading:
        LoadingView()
      }
    }
    .onOpenURL { url in
      store.send(.urlOpened(url))
    }
    .alert($store.scope(state: \.alert, action: \.alert))
    .popover(isPresented: $store.launchTutorial.sending(\.launchTutorialChanged)) {
      TutorialView(dismiss: $store.launchTutorial.sending(\.launchTutorialChanged))
    }
  }
}

#Preview {
  ContentView(store: Store(initialState: ContentState(
    allRecipesState: AllRecipesState(),
    groupGridState: GroupGridState(),
//    shoppingListState: ShoppingListState()
  )) {
    ContentReducer()
  })
}

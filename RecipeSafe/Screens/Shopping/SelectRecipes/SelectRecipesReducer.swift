import ComposableArchitecture
import Dependencies
import Foundation

@Reducer
struct SelectRecipesReducer {
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .task:
        state.isLoading = true
        return .run { send in
          let recipes = (try? recipeService.getRecipes()) ?? []
          let addedIds = (try? shoppingService.getRecipeIds()) ?? []
          await send(.recipesLoaded(recipes, addedIds))
        }

      case let .recipesLoaded(recipes, addedIds):
        state.isLoading = false
        state.recipes = recipes
        state.addedRecipeIds = Set(addedIds)
        return .none

      case let .recipeTapped(recipe):
        if state.selectedIds.contains(recipe.id) {
          state.selectedIds.remove(recipe.id)
        } else {
          state.selectedIds.insert(recipe.id)
        }
        return .none

      case .done:
        let toAdd = state.recipes.filter { state.selectedIds.contains($0.id) }
        return .run { send in
          for recipe in toAdd {
            try? shoppingService.addRecipe(recipe)
          }
          await send(.delegate(.dataUpdated))
          await dismiss()
        }

      case .cancel:
        return .run { _ in await dismiss() }
        
      case .binding, .delegate:
        return .none
      }
    }
  }
  
  @Dependency(\.recipeDatabaseService) var recipeService
  @Dependency(\.shoppingListDatabaseService) var shoppingService
  @Dependency(\.dismiss) var dismiss
}

extension SelectRecipesReducer {
  @ObservableState
  struct State: Equatable, Sendable {
    var searchText: String = ""
    var recipes: [Recipe] = []
    var selectedIds: Set<UUID> = []
    var addedRecipeIds: Set<UUID> = []
    var isLoading: Bool = false

    var filteredRecipes: [Recipe] {
      let available = recipes.filter { !addedRecipeIds.contains($0.id) }
      guard !searchText.isEmpty else { return available }
      return available.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
  }

  enum Action: Equatable, Sendable, BindableAction {
    case binding(BindingAction<State>)
    case task
    case recipesLoaded([Recipe], [UUID])
    case recipeTapped(Recipe)
    case done
    case cancel
    
    case delegate(SelectRecipesReducer.DelegateAction)
  }
  
  enum DelegateAction: Equatable, Sendable {
    case dataUpdated
  }
}

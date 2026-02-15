import ComposableArchitecture
import Dependencies
import Foundation
import CoreData

struct AddRecipeReducer: Reducer {
  typealias State = AddRecipeState
  typealias Action = AddRecipeAction
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case let .recipeTapped(recipe):
        if state.selectedRecipes.contains(recipe) {
          state.selectedRecipes.removeAll(where: { $0 == recipe })
        } else {
          state.selectedRecipes.append(recipe)
        }
        return .none
      case .save:
        return .none
      case .cancel:
        return .none
      default:
        return .none
      }
    }
  }
}

@ObservableState
struct AddRecipeState: Sendable, Equatable {
  var selectedRecipes: [Recipe] = []
  var availableRecipes: [Recipe]
  var searchText: String = ""
  
  var searchList: [Recipe] {
    if searchText.isEmpty { return availableRecipes }
    else { return availableRecipes.filter({ $0.title.lowercased().contains(searchText.lowercased()) }) }
  }
  
  init(availableRecipes: [Recipe]) {
    self.availableRecipes = availableRecipes
  }
}

@CasePathable
enum AddRecipeAction: Sendable, Equatable, BindableAction {
  case binding(BindingAction<AddRecipeState>)
  case recipeTapped(Recipe)
  case save
  case cancel
}


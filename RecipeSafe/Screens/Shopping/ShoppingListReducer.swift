//import ComposableArchitecture
//import Dependencies
//import Foundation
//import CoreData
//
//struct ShoppingListReducer: Reducer {
//  typealias State = ShoppingListState
//  typealias Action = ShoppingListAction
//  
//  var body: some ReducerOf<Self> {
//    BindingReducer()
//    Reduce { state, action in
//      switch action {
//      case .task:
//        return reduce(into: &state, action: .reloadData)
//      case .reloadData:
//        do {
//          let items = try coreDataService.fetchAll(ShoppingListItem.self)
//          state.shoppingList = items
//            .sorted { ($0.index, $0.value ?? "") < ($1.index, $1.value ?? "") }
//            .map { ShoppingListModel(dataItem: $0) }
//          
//          let recipeItems = try coreDataService.fetchAll(RecipeItem.self)
//          state.recipes = recipeItems.compactMap { Recipe(dataItem: $0) }
//          state.filteredRecipes = state.recipes.filter { isInList($0) }
//        } catch {
//          state.shoppingList = []
//          state.recipes = []
//          state.filteredRecipes = []
//        }
//        return .none
//      case .toggleEdit:
//        if state.isEditing {
//          state.tempIngredients = state.shoppingList
//        } else {
//          // Clear temp state when exiting edit mode
//          state.tempIngredients = []
//        }
//        state.isEditing.toggle()
//        return .none
//      case let .ingredientValueChanged(item, value):
//        if let index = state.shoppingList.firstIndex(where: { $0.id == item.id }) {
//          state.shoppingList[index].value = value
//          // Update Core Data
//          if let entity = coreDataService.fetch(id: item.id) as? ShoppingListItem {
//            entity.value = value
//            try? coreDataService.save()
//          }
//        }
//        return .none
//      case let .ingredientSubmitted(item):
//        if item == state.shoppingList.last {
//          let trimmed = item.value.trimmingWhitespace().removingNewLines()
//          if trimmed.isEmpty {
//            try? coreDataService.delete(id: item.id)
//            return reduce(into: &state, action: .reloadData)
//          } else {
//            // Update Core Data
//            if let entity = coreDataService.fetch(id: item.id) as? ShoppingListItem {
//              entity.value = trimmed
//              try? coreDataService.save()
//            }
//            if let index = state.shoppingList.firstIndex(where: { $0.id == item.id }) {
//              state.shoppingList[index].value = trimmed
//            }
//            if !state.isEditing {
//              try? coreDataService.createAndAdd("", Int16(state.shoppingList.count))
//              return reduce(into: &state, action: .reloadData)
//            }
//          }
//        }
//        return reduce(into: &state, action: .refreshIndices)
//      case .addNewIngredient:
//        try? coreDataService.createAndAdd("", Int16(state.shoppingList.count))
//        return reduce(into: &state, action: .reloadData)
//      case let .deleteIngredient(offsets):
//        let list = Array(state.shoppingList)
//        for index in offsets {
//          guard let item = list.safeValue(at: index) else { continue }
//          try? coreDataService.delete(id: item.id)
//        }
//        return reduce(into: &state, action: .refreshIndices)
//      case let .deleteRecipe(offsets):
//        let recipes = state.filteredRecipes
//        for index in offsets {
//          guard recipes.count > index else { continue }
//          let recipe = recipes[index]
//          // Fetch RecipeItem to get shopping list items
//          if let recipeId = recipe.dataEntity,
//             let recipeItem = coreDataService.fetch(id: recipeId) as? RecipeItem,
//             let items = recipeItem.shoppinglistitems?.allObjects as? [ShoppingListItem] {
//            for item in items {
//              try? coreDataService.delete(item)
//            }
//          }
//        }
//        return reduce(into: &state, action: .reloadData)
//      case .saveChanges:
//        try? coreDataService.save()
//        state.isEditing = false
//        return .none
//      case .cancelChanges:
//        state.isEditing = false
//        state.shoppingList = state.tempIngredients
//        return reduce(into: &state, action: .reloadData)
//      case .resetSelected:
//        for item in state.shoppingList {
//          if let entity = coreDataService.fetch(id: item.id) as? ShoppingListItem {
//            entity.selected = false
//            if let index = state.shoppingList.firstIndex(where: { $0.id == item.id }) {
//              state.shoppingList[index].selected = false
//            }
//          }
//        }
//        try? coreDataService.save()
//        return .none
//      case let .toggleSelected(item):
//        if let entity = coreDataService.fetch(id: item.id) as? ShoppingListItem {
//          entity.selected.toggle()
//          if let index = state.shoppingList.firstIndex(where: { $0.id == item.id }) {
//            state.shoppingList[index].selected = entity.selected
//          }
//          try? coreDataService.save()
//        }
//        return .none
//      case .addRecipes:
//        state.destination = .addRecipe(AddRecipeState(availableRecipes: state.recipes.filter { !isInList($0) }))
//        return .none
//      case let .saveAddedRecipes(recipes):
//        for recipe in recipes {
//          guard !isInList(recipe) else { continue }
//          // Fetch RecipeItem to add shopping list items
//          if let recipeId = recipe.dataEntity,
//             let recipeItem = coreDataService.fetch(id: recipeId) as? RecipeItem {
//            for ingredient in recipe.ingredients {
//              let newItem = coreDataService.create(ShoppingListItem.self)
//              newItem?.recipe = recipeItem
//              newItem?.value = ingredient
//              recipeItem.addToShoppinglistitems(newItem)
//            }
//          }
//        }
//        try? coreDataService.save()
//        return reduce(into: &state, action: .reloadData)
//      case .showClearAlert:
//        state.alert = .clearAll()
//        return .none
//      case let .alert(.presented(action)):
//        switch action {
//        case .clearAllOk:
//          try? coreDataService.clear()
//          return reduce(into: &state, action: .reloadData)
//        case .clearAllCancel:
//          return .none
//        }
//      case let .destination(.presented(action)):
//        switch action {
//        case .addRecipe(.save(let recipes)):
//          return reduce(into: &state, action: .saveAddedRecipes(recipes))
//        case .addRecipe(.cancel):
//          return .none
//        default:
//          return .none
//        }
//      case .refreshIndices:
//        for (index, item) in state.shoppingList.enumerated() {
//          if let entity = coreDataService.fetch(id: item.id) as? ShoppingListItem {
//            entity.index = Int16(index)
//            state.shoppingList[index].index = index
//          }
//        }
//        try? coreDataService.save()
//        return .none
//      default:
//        return .none
//      }
//    }
//    .ifLet(\.$destination, action: \.destination) { Destination() }
//    .ifLet(\.alert, action: \.alert)
//  }
//  
//  @Dependency(\.coreDataService)
//  private var coreDataService
//  
//  private func isInList(_ recipe: Recipe) -> Bool {
//    guard let recipeId = recipe.dataEntity,
//          let recipeItem = coreDataService.fetch(id: recipeId) as? RecipeItem else {
//      return false
//    }
//    return !(recipeItem.shoppinglistitems?.allObjects.isEmpty ?? true)
//  }
//}
//
//extension ShoppingListReducer {
//  @Reducer
//  struct Destination {
//    enum State: Equatable, Sendable {
//      case addRecipe(AddRecipeState)
//    }
//    enum Action: Equatable, Sendable {
//      case addRecipe(AddRecipeAction)
//    }
//    var body: some ReducerOf<Self> {
//      Scope(state: \.addRecipe, action: \.addRecipe) { AddRecipeReducer() }
//    }
//  }
//}
//
//@ObservableState
//struct ShoppingListState: Sendable, Equatable {
//  var shoppingList: [ShoppingListModel] = []
//  var recipes: [Recipe] = []
//  var filteredRecipes: [Recipe] = []
//  var isEditing: Bool = false
//  var showRecipes: Bool = true
//  var tempIngredients: [ShoppingListModel] = []
//  
//  @Presents
//  var destination: ShoppingListReducer.Destination.State?
//  @Presents
//  var alert: AlertState<ShoppingListAction.AlertAction>?
//}
//
//@CasePathable
//enum ShoppingListAction: Sendable, Equatable, BindableAction {
//  case binding(BindingAction<ShoppingListState>)
//  
//  case task
//  case reloadData
//  case toggleEdit
//  case ingredientValueChanged(ShoppingListModel, String)
//  case ingredientSubmitted(ShoppingListModel)
//  case addNewIngredient
//  case deleteIngredient(IndexSet)
//  case deleteRecipe(IndexSet)
//  case saveChanges
//  case cancelChanges
//  case resetSelected
//  case toggleSelected(ShoppingListModel)
//  case addRecipes
//  case saveAddedRecipes([Recipe])
//  case showClearAlert
//  case refreshIndices
//  
//  case destination(PresentationAction<ShoppingListReducer.Destination.Action>)
//  case alert(PresentationAction<AlertAction>)
//  
//  @CasePathable
//  enum AlertAction: Equatable, Sendable {
//    case clearAllOk
//    case clearAllCancel
//  }
//}
//
//extension AlertState where Action == ShoppingListAction.AlertAction {
//  static func clearAll() -> Self {
//    AlertState {
//      TextState("Are you sure you want to clear all recipes and ingredients?")
//    } actions: {
//      ButtonState(role: .destructive, action: .clearAllOk, label: { TextState("Clear") })
//      ButtonState(role: .cancel, action: .clearAllCancel, label: { TextState("Cancel")})
//    }
//  }
//}

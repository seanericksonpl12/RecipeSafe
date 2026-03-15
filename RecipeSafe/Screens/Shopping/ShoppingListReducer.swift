import ComposableArchitecture
import Dependencies
import Foundation
import CoreData

struct ShoppingListReducer: Reducer {
  typealias State = ShoppingListState
  typealias Action = ShoppingListAction

  @Dependency(\.shoppingListDatabaseService) var shoppingService
  @Dependency(\.recipeDatabaseService) var recipeService

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .task:
        return loadData()

      case let .dataLoaded(items, recipes):
        state.shoppingList = items
        state.recipes = recipes
        return .none
        
      case let .recipeTapped(recipe):
        state.navPath.append(.recipe(.init(recipe: recipe, editingEnabled: false)))
        return .none

      case let .toggleItemSelected(item):
        do {
          if let index = state.shoppingList.firstIndex(where: { $0.id == item.id }) {
            state.shoppingList[index].selected.toggle()
            try shoppingService.toggleItem(item.id, state.shoppingList[index].selected)
          }
        } catch {
          Logger.log("Failed to toggle ingredient: \(error)")
        }
        return .none

      case let .toggleSection(category):
        if state.collapsedSections.contains(category) {
          state.collapsedSections.remove(category)
        } else {
          state.collapsedSections.insert(category)
        }
        return .none

      case .toggleRecipesExpanded:
        state.recipesExpanded.toggle()
        return .none

      case .clearChecked:
        for index in state.shoppingList.indices {
          state.shoppingList[index].selected = false
        }
        try? shoppingService.resetChecks()
        return .none

      case .toggleEditMode:
        state.isEditing.toggle()
        return .none

      case let .deleteItem(item):
        state.shoppingList.removeAll { $0.id == item.id }
        try? shoppingService.removeItem(item.id)
        return .none

      case let .deleteRecipe(recipe):
        state.recipes.removeAll { $0.id == recipe.id }
        state.shoppingList.removeAll { $0.recipeId == recipe.id }
        try? shoppingService.removeRecipe(recipe.id)
        return .none
        
      case let .addFreeformItem(text):
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .none }
        let newItem = ShoppingListModel(id: UUID(), value: trimmed, selected: false, index: state.shoppingList.count)
        state.shoppingList.append(newItem)
        try? shoppingService.addFreeformItem(trimmed)
        return .none

      case .deleteAllIngredients:
        state.alert = .clearAll()
        return .none

      case .addRecipeTapped:
        state.destination = .selectRecipes(SelectRecipesReducer.State())
        return .none

      case .destination(.presented(.selectRecipes(.delegate(.dataUpdated)))):
        return loadData()
        
      case .alert(.presented(.clearAllOk)):
        state.shoppingList = []
        state.recipes = []
        try? shoppingService.clearAll()
        return .none

      default:
        return .none
      }
    }
    .forEach(\.navPath, action: \.navPath)
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.alert, action: \.alert)
  }

  private func loadData() -> Effect<ShoppingListAction> {
    // TODO: Filter recipes in SQL not here
    .run { send in
      let items = (try? shoppingService.getItems()) ?? []
      let addedRecipeIds = Set((try? shoppingService.getRecipeIds()) ?? [])
      let allRecipes = (try? recipeService.getRecipes()) ?? []
      let recipes = allRecipes.filter { addedRecipeIds.contains($0.id) }
      await send(.dataLoaded(items, recipes))
    }
  }
}

extension ShoppingListReducer {
  @Reducer
  enum Destination: Sendable {
    case selectRecipes(SelectRecipesReducer)
    static var body: some ReducerOf<Self> {
      Scope(state: \.selectRecipes, action: \.selectRecipes) { SelectRecipesReducer() }
    }
  }
  
  @Reducer
  enum NavPath: Sendable {
    case recipe(RecipeReducer)
    static var body: some ReducerOf<Self> {
      Scope(state: \.recipe, action: \.recipe) { RecipeReducer() }
    }
  }
}

extension ShoppingListReducer.Destination.State: Equatable, Sendable {}
extension ShoppingListReducer.Destination.Action: Equatable, Sendable {}
extension ShoppingListReducer.NavPath.State: Equatable, Sendable {}
extension ShoppingListReducer.NavPath.Action: Equatable, Sendable {}

@ObservableState
struct ShoppingListState: Sendable, Equatable {
  var shoppingList: [ShoppingListModel] = []
  var recipes: [Recipe] = []
  var isEditing: Bool = false
  var showRecipes: Bool = true
  var collapsedSections: Set<GroceryCategory> = []
  var recipesExpanded: Bool = true
  var addingNewIngredient: Bool = false
  
  var navPath = StackState<ShoppingListReducer.NavPath.State>()
  @Presents
  var destination: ShoppingListReducer.Destination.State?
  @Presents
  var alert: AlertState<ShoppingListAction.AlertAction>?

  var checkedCount: Int {
    shoppingList.filter(\.selected).count
  }

  var progress: Double {
    guard shoppingList.count > 0 else { return 0 }
    return Double(checkedCount) / Double(shoppingList.count)
  }

  var groupedItems: [(category: GroceryCategory, items: [ShoppingListModel])] {
    let grouped = GroceryCategorizer.grouped(shoppingList)
    return GroceryCategory.allCases.compactMap { category in
      guard let items = grouped[category], !items.isEmpty else { return nil }
      return (category: category, items: items)
    }
  }
}

@CasePathable
enum ShoppingListAction: Sendable, Equatable, BindableAction {
  case binding(BindingAction<ShoppingListState>)
  case task
  case dataLoaded([ShoppingListModel], [Recipe])
  case toggleItemSelected(ShoppingListModel)
  case toggleSection(GroceryCategory)
  case toggleRecipesExpanded
  case clearChecked
  case addRecipeTapped
  case recipeTapped(Recipe)
  case toggleEditMode
  case deleteItem(ShoppingListModel)
  case deleteRecipe(Recipe)
  case addFreeformItem(String)
  case deleteAllIngredients

  case navPath(StackActionOf<ShoppingListReducer.NavPath>)
  case destination(PresentationAction<ShoppingListReducer.Destination.Action>)
  case alert(PresentationAction<AlertAction>)

  @CasePathable
  enum AlertAction: Equatable, Sendable {
    case clearAllOk
    case clearAllCancel
  }
}

extension AlertState where Action == ShoppingListAction.AlertAction {
  static func clearAll() -> Self {
    AlertState {
      TextState("Are you sure you want to clear all recipes and ingredients?")
    } actions: {
      ButtonState(role: .destructive, action: .clearAllOk, label: { TextState("Clear") })
      ButtonState(role: .cancel, action: .clearAllCancel, label: { TextState("Cancel")})
    }
  }
}

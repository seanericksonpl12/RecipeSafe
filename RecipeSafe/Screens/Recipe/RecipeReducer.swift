import ComposableArchitecture
import Dependencies
import Foundation


@Reducer
struct RecipeReducer: Sendable {
  typealias State = RecipeState
  typealias Action = RecipeAction
  
  @Reducer
  struct Destination {
    enum State: Equatable, Sendable {
      case selectCategories(SelectCategoriesState)
    }
    enum Action: Equatable, Sendable {
      case selectCategories(SelectCategoriesAction)
    }
    var body: some ReducerOf<Self> {
      Scope(state: \.selectCategories, action: \.selectCategories) {
        SelectCategoriesReducer()
      }
    }
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case let .deleteIngredients(offsets):
        state.recipe.ingredients.remove(atOffsets: offsets)
      case let .deleteInstructions(offsets):
        state.recipe.instructions.remove(atOffsets: offsets)
      case .addIngredient:
        state.recipe.ingredients.append("")
      case .addInstruction:
        state.recipe.instructions.append("")
      case let .toggleIngredientChecked(ingredient):
        if state.checkedIngredients[ingredient.id] == true {
          state.checkedIngredients[ingredient.id] = nil
        } else {
          state.checkedIngredients[ingredient.id] = true
        }
        return .none
      case .favoriteRecipe:
        let currentState = state.recipe.isFavorite
        state.recipe.isFavorite.toggle()
        do {
          try recipeManager.update(recipe: state.recipe)
        } catch {
          state.recipe.isFavorite = currentState
        }
      case .editRecipeTapped:
        state.editRecipe = EditRecipeState(state.recipe)
        return .none
      case .addTagTapped:
        return .none
      case .saveChanges:
        return saveChanges(&state)
      case .cancelChanges:
        return cancelChanges(&state)
      case .deleteSelf:
        try? recipeManager.delete(state.recipe)
//        state.recipe.dataEntity = nil
        return .run { _ in await dismiss() }
        
      case .showAlert:
        state.alert = .deleteRecipe()
      case .showSelectCategories:
        state.destination = .selectCategories(.init(recipe: state.recipe))
        return .none
      case let .alert(.presented(action)):
        switch action {
        case .deleteRecipeOk:
          return reduce(into: &state, action: .deleteSelf)
        case .deleteRecipeCancel:
          return .none
        }
      case let .destination(.presented(action)):
        switch action {
        case let .selectCategories(.delegate(.selectedTags(tags))):
          state.recipe.tags = tags
          try? recipeManager.update(recipe: state.recipe)
          return .none
        default:
          return .none
        }
      default:
        return .none
      }
      return .none
    }
    .ifLet(\.editRecipe, action: \.editRecipe) {
      EditRecipeReducer()
    }
    .ifLet(\.alert, action: \.alert)
    .ifLet(\.$destination, action: \.destination) { Destination() }
  }
  
  @Dependency(\.dismiss)
  private var dismiss

  private let recipeManager = RecipeManager()
  private let groupManager = GroupManager()
}

extension RecipeReducer {
  private func saveChanges(
    _ state: inout State
  ) -> Effect<Action> {
    state.recipe.instructions.removeAll { $0 == "" }
    state.recipe.ingredients.removeAll { $0 == "" }
    try? recipeManager.update(recipe: state.recipe)
    return .send(.binding(.set(\.editingEnabled, false)), animation: .default)
  }
  
  private func cancelChanges(
    _ state: inout State
  ) -> Effect<Action> {
    return .none
//    let effect: Effect<Action> = .send(.binding(.set(\.editingEnabled, false)), animation: .default)
//    guard let id = state.recipe.dataEntity, let entity = recipeManager.getRecipe(for: id) else {
//      return effect
//    }
//    state.recipe.title = entity.title ?? state.recipe.title
//    state.recipe.description = entity.desc ?? ""
//    if let data = entity.photoData { state.recipe.img = .selected(data) }
//    guard
//      var ingredientArr = entity.ingredients?.array as? [Ingredient],
//      var instructionArr = entity.instructions?.array as? [Instruction]
//    else {
//      return effect
//    }
//    ingredientArr = ingredientArr.filter { $0.value != nil }
//    instructionArr = instructionArr.filter { $0.value != nil }
//    
//    state.recipe.ingredients = ingredientArr.map { $0.value! }
//    state.recipe.instructions = instructionArr.map { $0.value! }
//    return effect
  }
  
  private func saveNewRecipe(
    _ state: inout State
  ) -> Effect<Action> {
    if state.recipe.title == "" { state.recipe.title = "recipe.title.new".localized }
    if state.recipe.instructions.contains("") { state.recipe.instructions.removeAll(where: {$0 == ""}) }
    if state.recipe.ingredients.contains("") { state.recipe.ingredients.removeAll(where: {$0 == ""}) }
    _ = try? recipeManager.save(recipe: state.recipe)
    return .run { _ in await dismiss() }
  }
}

@ObservableState
struct RecipeState: Sendable, Equatable {
  var editRecipe: EditRecipeState?

  var recipe: Recipe
  var checkedIngredients: [UUID: Bool] = [:]
  var editingEnabled: Bool
  
  @Presents
  var alert: AlertState<RecipeAction.AlertAction>?
  @Presents
  var destination: RecipeReducer.Destination.State?
}

@CasePathable
enum RecipeAction: Sendable, Equatable, BindableAction {
  case binding(BindingAction<RecipeState>)
  
  case deleteIngredients(IndexSet)
  case deleteInstructions(IndexSet)
  case addIngredient
  case addInstruction
  case toggleIngredientChecked(IdentifiedString)
  case favoriteRecipe
  case editRecipeTapped
  case addTagTapped
  
  case saveChanges
  case cancelChanges
  case deleteSelf
  
  case showAlert
  case showSelectCategories
  
  case editRecipe(EditRecipeAction)
  case alert(PresentationAction<AlertAction>)
  case destination(PresentationAction<RecipeReducer.Destination.Action>)
  
  @CasePathable
  enum AlertAction: Equatable, Sendable {
    case deleteRecipeOk
    case deleteRecipeCancel
  }
}

import ComposableArchitecture
import Dependencies
import PhotosUI
import SwiftUI

@Reducer
struct CustomRecipeReducer {
  typealias State = CustomRecipeState
  typealias Action = CustomRecipeAction
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { (state: inout State, action: Action) -> Effect<Action> in
      switch action {
      case let .photoPicked(item):
        state.photoPickerSelection = item
        guard let item else { return .none }
        return .run { send in
          let data = try await item.loadTransferable(type: Data.self)
          await send(.binding(.set(\.photoData, data)))
        }
      case .addIngredient:
        state.recipe.ingredients.append("")
        return .none
      case .addInstruction:
        state.recipe.instructions.append("")
        return .none
      case let .removeIngredients(indexes):
        state.recipe.ingredients.remove(atOffsets: indexes)
        return .none
      case let .removeInstructions(indexes):
        state.recipe.instructions.remove(atOffsets: indexes)
        return .none
      case let .moveIngredients(from, to):
        state.recipe.ingredients.move(fromOffsets: from, toOffset: to)
        return .none
      case let .moveInstructions(from, to):
        state.recipe.instructions.move(fromOffsets: from, toOffset: to)
        return .none
      case .save:
        return .run { [state] send in
          _ = try recipeManager.save(recipe: state.recipe)
          await dismiss()
        }
      case .dismiss:
        return .run { _ in await dismiss() }

      default:
        return .none
      }
    }
  }
  
  @Dependency(\.dismiss)
  private var dismiss
  
  private let recipeManager = RecipeManager()
}

@ObservableState
struct CustomRecipeState: Equatable, Sendable {
  init(recipe: Recipe = Recipe()) {
    self.recipe = recipe
  }

  var recipe: Recipe
  var photoPickerSelection: PhotosPickerItem?
  var photoData: Data?

  @Presents
  var destination: SelectGroupsState?
}

@CasePathable
enum CustomRecipeAction: Equatable, Sendable, BindableAction {
  case binding(BindingAction<CustomRecipeState>)
  case dismiss
  case save
  case photoPicked(PhotosPickerItem?)
  
  case addIngredient
  case addInstruction
  case removeIngredients(IndexSet)
  case removeInstructions(IndexSet)
  case moveIngredients(from: IndexSet, to: Int)
  case moveInstructions(from: IndexSet, to: Int)

  case destination(PresentationAction<SelectGroupsAction>)
}

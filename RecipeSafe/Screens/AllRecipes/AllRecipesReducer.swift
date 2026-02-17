import ComposableArchitecture
import Dependencies
import Foundation
import SQLiteData

struct AllRecipesReducer: Reducer {
  typealias State = AllRecipesState
  typealias Action = AllRecipesAction
  
  @Reducer
  enum NavPath {
    case recipe(RecipeReducer)
  }
  @Reducer
  enum Destination {
    case recipe(CustomRecipeReducer)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        return .merge(
          reduce(into: &state, action: .reloadRecipeList),
          .run { send in
            for await event in eventBus.stream {
              if event == .recipeDatabaseUpdated {
                await send(.reloadRecipeList)
              }
            }
          }.cancellable(id: "AllRecipesViewDatabaseListener", cancelInFlight: true)
        )
      case .reloadRecipeList:
        do {
          state.recipeList = try recipeManager.fetchAll()
        } catch {
          state.recipeList = []
        }
        return .none
      case let .searchTextUpdated(text):
        state.searchText = text
        return .none
      case let .recipeTapped(recipe):
        state.navPath.append(.recipe(RecipeState(recipe: recipe, editingEnabled: false)))
        return .none
      case let .favoriteRecipe(index):
        state.recipeList[index].isFavorite.toggle()
        try? recipeManager.update(recipe: state.recipeList[index])
        return .none
      case .createCustomRecipe:
        state.destination = .recipe(CustomRecipeState())
        return .none
      case let .deleteRecipe(recipe):
        state.recipeToDelete = recipe
        state.alert = .deleteRecipe()
        return .none
      case .alert(.presented(.deleteRecipeOk)):
        if let recipe = state.recipeToDelete {
          try? recipeManager.delete(recipe)
          state.recipeToDelete = nil
        }
        return .none
      case .alert(.presented(.deleteRecipeCancel)):
        state.recipeToDelete = nil
        return .none
      case .alert:
        return .none
      default:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.createRecipeState, action: \.createRecipe) { CreateRecipeReducer() }
    .forEach(\.navPath, action: \.navPath)
  }
  
  private let recipeManager = RecipeManager()
  
  @Dependency(\.eventBus)
  private var eventBus
  
}

@ObservableState
struct AllRecipesState: Sendable, Equatable {
  var createRecipeState: CreateRecipeReducer.State?
  var recipeList: [Recipe] = []
  var searchText: String = ""
  var isLoading: Bool = false
  
  var recipeToDelete: Recipe?
  @Presents
  var alert: AlertState<AllRecipesAction.AlertAction>?
  @Presents
  var destination: AllRecipesReducer.Destination.State?
  var navPath: StackState<AllRecipesReducer.NavPath.State> = .init()
  
  init() {
    if isImageAnalysisEnabled {
      self.createRecipeState = CreateRecipeReducer.State()
    }
  }
  
  var isImageAnalysisEnabled: Bool {
    @Dependency(\.appConfigCache)
    var appConfigCache
    return appConfigCache.get()?.featureFlags.recipeAnalysisEnabled ?? false
  }
  
  var searchList: [Recipe] {
    searchText.isEmpty ? recipeList : recipeList.filter({ $0.title.lowercased().contains(searchText.lowercased()) })
  }
}

@CasePathable
enum AllRecipesAction: Sendable, Equatable {
  case task
  case reloadRecipeList
  case searchTextUpdated(String)
  case deleteRecipe(Recipe)
  case recipeTapped(Recipe)
  case favoriteRecipe(Int)
  case createCustomRecipe
  
  case alert(PresentationAction<AlertAction>)
  @CasePathable
  enum AlertAction: Equatable, Sendable {
    case deleteRecipeOk
    case deleteRecipeCancel
  }

  case createRecipe(CreateRecipeReducer.Action)
  case navPath(StackActionOf<AllRecipesReducer.NavPath>)
  case destination(PresentationAction<AllRecipesReducer.Destination.Action>)
}

extension AllRecipesReducer.NavPath.State: Equatable, Sendable {}
extension AllRecipesReducer.NavPath.Action: Equatable, Sendable {}
extension AllRecipesReducer.Destination.State: Equatable, Sendable {}
extension AllRecipesReducer.Destination.Action: Equatable, Sendable {}

extension AlertState where Action == AllRecipesAction.AlertAction {
  static func deleteRecipe() -> Self {
    AlertState {
      TextState("recipe.alert.delete.title".localized)
    } actions: {
      ButtonState(role: .destructive, action: .deleteRecipeOk, label: { TextState("button.delete".localized) })
      ButtonState(role: .cancel, action: .deleteRecipeCancel, label: { TextState("button.cancel".localized) })
    } message: {
      TextState("recipe.alert.delete.desc".localized)
    }
  }
}

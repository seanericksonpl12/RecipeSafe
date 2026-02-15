import ComposableArchitecture
import Dependencies
import Foundation

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
        return reduce(into: &state, action: .reloadRecipeList)
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
      case .createCustomRecipe:
        state.destination = .recipe(CustomRecipeState())
        return .none
      case let .fetchRecipe(imgData):
        print("get recipe from camera")
        return .none
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.createRecipeState, action: \.createRecipe) { CreateRecipeReducer() }
    .forEach(\.navPath, action: \.navPath)
  }
  
  private let recipeManager = RecipeManager()
  
}

@ObservableState
struct AllRecipesState: Sendable, Equatable {
  var createRecipeState: CreateRecipeReducer.State?
  var recipeList: [Recipe] = []
  var searchText: String = ""
  var isLoading: Bool = false
  
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
  case deleteRecipes(IndexSet)
  case recipeTapped(Recipe)
  case createCustomRecipe
  case fetchRecipe(Data)
  
  case createRecipe(CreateRecipeReducer.Action)
  case navPath(StackActionOf<AllRecipesReducer.NavPath>)
  case destination(PresentationAction<AllRecipesReducer.Destination.Action>)
}

extension AllRecipesReducer.NavPath.State: Equatable, Sendable {}
extension AllRecipesReducer.NavPath.Action: Equatable, Sendable {}
extension AllRecipesReducer.Destination.State: Equatable, Sendable {}
extension AllRecipesReducer.Destination.Action: Equatable, Sendable {}

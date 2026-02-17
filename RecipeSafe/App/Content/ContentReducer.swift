import ComposableArchitecture
import Dependencies
import Foundation

struct ContentReducer: Reducer {
  typealias State = ContentState
  typealias Action = ContentAction
  
  var body: some ReducerOf<Self> {
    Scope(state: \.allRecipesState, action: \.allRecipes) {
      AllRecipesReducer()
    }
    Scope(state: \.groupGridState, action: \.groupGrid) {
      GroupGridReducer()
    }
//    Scope(state: \.shoppingListState, action: \.shoppingList) {
//      ShoppingListReducer()
//    }
    Reduce { state, action in
      switch action {
      case let .tabSelected(tab):
        state.tabSelection = tab
        return .none
      case let .urlOpened(url):
        state.viewState = .loading
        return .run { send in
          let recipe = try await recipeManager.buildRecipe(url: url)
          try recipeManager.save(recipe: recipe)
          await send(.handleNewRecipe(recipe))
        } catch: { _, send in
          await send(.showFailedAlert)
        }
      case let .handleNewRecipe(recipe):
        state.viewState = .successfullyLoaded
        return reduce(into: &state, action: .openRecipe(recipe))
//        var newRecipe = recipe
//        if let duplicateItem = try? recipeManager.findDuplicates(of: newRecipe), let duplicate = Recipe(dataItem: duplicateItem) {
//          return reduce(into: &state, action: .showDuplicateFoundAlert(new: recipe, duplicate: duplicate))
//        } else {
//          newRecipe.dataEntity = try? recipeManager.save(recipe: recipe).objectID
//          return reduce(into: &state, action: .openRecipe(newRecipe))
//        }
      case let .openRecipe(recipe):
        state.tabSelection = .allRecipes
        return reduce(into: &state, action: .allRecipes(.recipeTapped(recipe)))
        
      case .showFailedAlert:
        state.viewState = .failedToLoad
        state.alert = AlertState.failedToBuildRecipe()
        return .none
      case let .showDuplicateFoundAlert(new, duplicate):
        state.alert = AlertState.duplicateRecipeFound(new: new, duplicate: duplicate)
        return .none
      case let .launchTutorialChanged(value):
        state.launchTutorial = value
        return .none
      case let .alert(.presented(action)):
        switch action {
        case .recipeFailedOk, .duplicateCancel:
          return .none
        case let .duplicateOverwrite(new, duplicate):
//          if let id = duplicate.dataEntity {
//            try? coreDataService.delete(id: id)
//          }
          return reduce(into: &state, action: .openRecipe(new))
        case let .duplicateSaveCopy(recipe):
          return reduce(into: &state, action: .openRecipe(recipe))
        }
      default:
        return .none
      }
    }
    .ifLet(\.alert, action: \.alert)
  }

  @Dependency(\.appConfigCache)
  private var appConfig

  @Dependency(\.coreDataService)
  private var coreDataService
  
  private let recipeManager = RecipeManager()
  private let groupManager = GroupManager()
}

@ObservableState
struct ContentState: Sendable, Equatable {
  
  var allRecipesState = AllRecipesState()
  var groupGridState = GroupGridState()
//  var shoppingListState = ShoppingListState()

  var viewState: ViewState = .started
  var tabSelection: ContentTab = .allRecipes
  var launchTutorial: Bool = false
  var newRecipe: Recipe? = nil
  var newRecipeSwitch: Bool = false

  @Presents
  var alert: AlertState<ContentAction.AlertAction>?
}

enum ContentTab: Equatable, Sendable {
  case allRecipes
  case group
  case shoppingList
}

@CasePathable
enum ContentAction: Sendable, Equatable {
  case allRecipes(AllRecipesAction)
  case groupGrid(GroupGridAction)
//  case shoppingList(ShoppingListAction)
  
  case tabSelected(ContentTab)
  case urlOpened(URL)
  case handleNewRecipe(Recipe)
  case openRecipe(Recipe)
  
  case showFailedAlert
  case showDuplicateFoundAlert(new: Recipe, duplicate: Recipe)
  case launchTutorialChanged(Bool)
  case alert(PresentationAction<AlertAction>)
  
  @CasePathable
  enum AlertAction: Equatable, Sendable {
    case recipeFailedOk
    case duplicateOverwrite(new: Recipe, duplicate: Recipe)
    case duplicateSaveCopy(Recipe)
    case duplicateCancel
  }
}

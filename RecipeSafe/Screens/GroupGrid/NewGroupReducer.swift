import ComposableArchitecture
import Dependencies
import Foundation
import CoreData

struct NewGroupReducer: Reducer {
  typealias State = NewGroupState
  typealias Action = NewGroupAction
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .task:
        do {
//          let recipeItems = try coreDataService.fetchAll(RecipeItem.self)
//          state.availableRecipes = recipeItems
//            .filter { $0.group == nil }
//            .compactMap { Recipe(dataItem: $0) }
        } catch {
          state.availableRecipes = []
        }
        if state.newGroupColor == nil {
          state.newGroupColor = try? groupManager.getNewColor()
        }
        return .none
      case .saveGroup:
        try? groupManager.create(title: state.title, recipes: state.selectedRecipes, color: state.newGroupColor)
        return .none
      case .cancel:
        return .none
      default:
        return .none
      }
    }
  }
  
  @Dependency(\.coreDataService)
  private var coreDataService
  
  private let groupManager = GroupManager()
}

@ObservableState
struct NewGroupState: Sendable, Equatable {
  var title: String = ""
  var selectedRecipes: [Recipe] = []
  var availableRecipes: [Recipe] = []
  var newGroupColor: Int16?
}

@CasePathable
enum NewGroupAction: Sendable, Equatable, BindableAction {
  case binding(BindingAction<NewGroupState>)
  case task
  case saveGroup
  case groupSaved
  case cancel
}

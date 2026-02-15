import ComposableArchitecture
import Dependencies
import Foundation
import CoreData

struct GroupReducer: Reducer {
  typealias State = GroupState
  typealias Action = GroupAction
  
  @Reducer
  enum NavPath {
    case recipe(RecipeReducer)
  }
  
  @Reducer
  enum Destination {
    case addRecipe(AddRecipeReducer)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { (state: inout State, action: Action) -> Effect<Action> in
      switch action {
      case .task:
        return reduce(into: &state, action: .reloadGroup)
      case .reloadGroup:
        guard let groupItem = groupManager.getGroup(for: state.group.dataEntityID) else {
          return .none
        }
        let recipeItems = groupItem.recipes?.array as? [RecipeItem] ?? []
        state.group.recipes = recipeItems.compactMap { Recipe(dataItem: $0) }
        state.group.title = groupItem.title ?? "group.default".localized
        do {
          let allRecipeItems = try coreDataService.fetchAll(RecipeItem.self)
          state.availableRecipes = allRecipeItems.filter { $0.group == nil }.compactMap(Recipe.init)
        } catch {
          state.availableRecipes = []
        }
        return .none
      case let .titleChanged(title):
        state.group.title = title
        return .none
      case .toggleEdit:
        state.editingEnabled.toggle()
        if !state.editingEnabled {
          return reduce(into: &state, action: .saveChanges)
        }
        return .none
      case .saveChanges:
        try? groupManager.update(state.group)
        return .none
      case .cancelChanges:
        guard let groupItem = groupManager.getGroup(for: state.group.dataEntityID) else {
          return .none
        }
        state.group.title = groupItem.title ?? state.group.title
        let recipeItems = groupItem.recipes?.array as? [RecipeItem] ?? []
        state.group.recipes = recipeItems.compactMap { Recipe(dataItem: $0) }
        return .none
      case let .removeRecipe(offsets):
        state.group.recipes.remove(atOffsets: offsets)
        if !state.editingEnabled {
          try? groupManager.update(state.group)
        }
        return .none
      case let .moveRecipes(from: start, to: end):
        state.group.recipes.move(fromOffsets: start, toOffset: end)
        return .none
      case .addRecipe:
        state.destination = .addRecipe(AddRecipeState(availableRecipes: state.availableRecipes))
        return .none
      case let .saveAddedRecipes(recipeItems):
        state.group.recipes.append(contentsOf: recipeItems)
        return reduce(into: &state, action: .saveChanges)
      case .deleteGroup:
        state.alert = .deleteGroup()
        return .none
      case .deleteGroupConfirmed:
        try? coreDataService.delete(id: state.group.dataEntityID)
        return .run { _ in await dismiss() }
      case let .recipeTapped(recipe):
        state.navPath.append(.recipe(RecipeState(recipe: recipe, editingEnabled: false)))
        return .none
      case let .destination(.presented(action)):
        switch action {
//        case .addRecipe(.save(let recipeItems)):
//          return reduce(into: &state, action: .saveAddedRecipes(recipeItems))
        case .addRecipe(.cancel):
          return .none
        default:
          return .none
        }
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
    .forEach(\.navPath, action: \.navPath)
    .ifLet(\.alert, action: \.alert)
  }
  
  @Dependency(\.coreDataService)
  private var coreDataService
  
  @Dependency(\.dismiss)
  private var dismiss
  
  private let groupManager = GroupManager()
}

@ObservableState
struct GroupState: Sendable, Equatable {
  var group: GroupModel
  var editingEnabled: Bool = false
  var availableRecipes: [Recipe] = []
  
  @Presents
  var destination: GroupReducer.Destination.State?
  @Presents
  var alert: AlertState<GroupAction.AlertAction>?
  
  var navPath: StackState<GroupReducer.NavPath.State> = .init()
  
  init(group: GroupModel) {
    self.group = group
  }
}

@CasePathable
enum GroupAction: Sendable, Equatable, BindableAction {
  case binding(BindingAction<GroupState>)
  
  case task
  case reloadGroup
  case titleChanged(String)
  case toggleEdit
  case saveChanges
  case cancelChanges
  case removeRecipe(IndexSet)
  case moveRecipes(from: IndexSet, to: Int)
  case addRecipe
  case saveAddedRecipes([Recipe])
  case deleteGroup
  case deleteGroupConfirmed
  case recipeTapped(Recipe)
  
  case navPath(StackActionOf<GroupReducer.NavPath>)
  case destination(PresentationAction<GroupReducer.Destination.Action>)
  case alert(PresentationAction<AlertAction>)
  
  @CasePathable
  enum AlertAction: Equatable, Sendable {
    case deleteGroupOk
    case deleteGroupCancel
  }
}

extension AlertState where Action == GroupAction.AlertAction {
  static func deleteGroup() -> Self {
    AlertState {
      TextState("group.alert.delete".localized)
    } actions: {
      ButtonState(role: .destructive, action: .deleteGroupOk, label: { TextState("button.delete".localized) })
      ButtonState(role: .cancel, action: .deleteGroupCancel, label: { TextState("button.cancel".localized) })
    }
  }
}

extension GroupReducer.NavPath.State: Equatable, Sendable {}
extension GroupReducer.NavPath.Action: Equatable, Sendable {}
extension GroupReducer.Destination.State: Equatable, Sendable {}
extension GroupReducer.Destination.Action: Equatable, Sendable {}

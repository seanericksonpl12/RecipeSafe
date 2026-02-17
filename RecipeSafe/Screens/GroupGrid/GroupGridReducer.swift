import ComposableArchitecture
import SwiftUI
import CoreData
import Dependencies
import Foundation

struct GroupGridReducer: Reducer {
  typealias State = GroupGridState
  typealias Action = GroupGridAction
  
  @Reducer
  enum NavPath {
    case group(GroupReducer)
    case recipe(RecipeReducer)
  }
  
  @Reducer
  enum Destination {
    case group(GroupReducer)
    case recipe(RecipeReducer)
    case newGroup(NewGroupReducer)
    case selectGroups(SelectGroupsReducer)
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { (state: inout State, action: Action) -> Effect<Action> in
      switch action {
      case .task:
        return reduce(into: &state, action: .reloadGroups)
      case .reloadGroups:
        do {
          let groupItems = try coreDataService.fetchAll(GroupItem.self)
          state.groups = groupItems.map { GroupModel(dataEntity: $0) }
          let recipeItems = try coreDataService.fetchAll(RecipeItem.self)
//          state.recipes = recipeItems.compactMap { Recipe(dataItem: $0) }
        } catch {
          state.groups = []
          state.recipes = []
        }
        return .none
      case .toggleEdit:
        state.editingEnabled.toggle()
        return .none
      case let .groupTapped(group):
        state.navPath.append(.group(GroupState(group: group)))
        return .none
      case .addGroup:
        state.destination = .newGroup(NewGroupState())
        return .none
      case let .deleteGroup(group):
        state.alert = .deleteGroup()
        state.groupToDelete = group
        return .none
      case .deleteGroupConfirmed:
        if let group = state.groupToDelete {
          try? coreDataService.delete(id: group.dataEntityID)
          return reduce(into: &state, action: .reloadGroups)
        }
        return .none
      case let .newRecipeReceived(recipe):
        state.newRecipe = recipe
        state.destination = .selectGroups(SelectGroupsState(recipe: recipe))
        return .none
      case let .selectGroupForRecipe(group, recipe):
        if let groupItem = groupManager.getGroup(for: group.dataEntityID) {
          try? recipeManager.addToGroup(recipe, group: groupItem)
        }
        state.navPath.append(.group(GroupState(group: group)))
        state.navPath.append(.recipe(RecipeState(recipe: recipe, editingEnabled: false)))
        return .none
      case .cancelSelectGroup:
        if let recipe = state.newRecipe {
          state.navPath.append(.recipe(RecipeState(recipe: recipe, editingEnabled: false)))
        }
        return .none
      case let .destination(.presented(action)):
        switch action {
//        case .newGroup(.saveGroup(let title, let recipes, let color)):
//          try? groupManager.create(title: title, recipes: recipes, color: color)
//          return reduce(into: &state, action: .reloadGroups)
        case .newGroup(.cancel):
          return .none
        case .selectGroups(.groupSelected(let group)):
          if let recipe = state.newRecipe {
            return reduce(into: &state, action: .selectGroupForRecipe(group, recipe))
          }
          return .none
        case .selectGroups(.cancel):
          return reduce(into: &state, action: .cancelSelectGroup)
        default:
          return .none
        }
      case .navPath(.element(id: _, action: .group(.deleteGroup))):
        return reduce(into: &state, action: .reloadGroups)
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
  
  private let recipeManager = RecipeManager()
  private let groupManager = GroupManager()
}

@ObservableState
struct GroupGridState: Sendable, Equatable {
  var groups: [GroupModel] = []
  var recipes: [Recipe] = []
  var editingEnabled: Bool = false
  var newRecipe: Recipe?
  var groupToDelete: GroupModel?
  
  @Presents
  var destination: GroupGridReducer.Destination.State?
  @Presents
  var alert: AlertState<GroupGridAction.AlertAction>?
  
  var navPath: StackState<GroupGridReducer.NavPath.State> = .init()
}

@CasePathable
enum GroupGridAction: Sendable, Equatable, BindableAction {
  case binding(BindingAction<GroupGridState>)
  
  case task
  case reloadGroups
  case toggleEdit
  case groupTapped(GroupModel)
  case addGroup
  case deleteGroup(GroupModel)
  case deleteGroupConfirmed
  case newRecipeReceived(Recipe)
  case selectGroupForRecipe(GroupModel, Recipe)
  case cancelSelectGroup
  
  case navPath(StackActionOf<GroupGridReducer.NavPath>)
  case destination(PresentationAction<GroupGridReducer.Destination.Action>)
  case alert(PresentationAction<AlertAction>)
  
  @CasePathable
  enum AlertAction: Equatable, Sendable {
    case deleteGroupOk
    case deleteGroupCancel
  }
}

extension AlertState where Action == GroupGridAction.AlertAction {
  static func deleteGroup() -> Self {
    AlertState {
      TextState("group.alert.delete".localized)
    } actions: {
      ButtonState(role: .destructive, action: .deleteGroupOk, label: { TextState("button.delete".localized) })
      ButtonState(role: .cancel, action: .deleteGroupCancel, label: { TextState("button.cancel".localized) })
    }
  }
}

extension GroupGridReducer.NavPath.State: Equatable, Sendable {}
extension GroupGridReducer.NavPath.Action: Equatable, Sendable {}
extension GroupGridReducer.Destination.State: Equatable, Sendable {}
extension GroupGridReducer.Destination.Action: Equatable, Sendable {}

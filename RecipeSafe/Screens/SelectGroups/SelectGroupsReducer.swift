import ComposableArchitecture
import Dependencies
import Foundation
import CoreData

@Reducer
struct SelectGroupsReducer {
  typealias State = SelectGroupsState
  typealias Action = SelectGroupsAction
  
  var body: some ReducerOf<Self> {
    Reduce {  (state: inout State, action: Action) -> Effect<Action> in
      switch action {
      case .task:
        return reduce(into: &state, action: .reloadGroups)
      case .reloadGroups:
        do {
          let groupItems = try coreDataService.fetchAll(GroupItem.self)
          state.groups = groupItems.compactMap(GroupModel.init)
        } catch {
          state.groups = []
        }
        return .none
      case let .groupTapped(group):
        return reduce(into: &state, action: .groupSelected(group))
      case let .groupSelected(group):
        state.selectedGroup = group
        return .none
      case .cancel:
        return .none
      case .addNewGroup:
        state.destination = .newGroup(NewGroupState())
        return .none
      case let .destination(.presented(action)):
        switch action {
//        case .newGroup(.saveGroup(let title, let recipes, let color)):
//          try? groupManager.create(title: title, recipes: recipes, color: color)
//          let groupItems = try? coreDataService.fetchAll(GroupItem.self)
//          if let newGroup = groupItems?.first(where: { $0.title == title }) {
//            let groupModel = GroupModel(dataEntity: newGroup)
//            return reduce(into: &state, action: .groupSelected(groupModel))
//          }
//          return .none
        case .newGroup(.cancel):
          return .none
        default:
          return .none
        }
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) { Destination() }
  }
  
  @Dependency(\.coreDataService)
  private var coreDataService
  
  private let groupManager = GroupManager()
}

extension SelectGroupsReducer {
  @Reducer
  struct Destination {
    enum State: Equatable, Sendable {
      case newGroup(NewGroupState)
    }
    enum Action: Equatable, Sendable {
      case newGroup(NewGroupAction)
    }
    var body: some ReducerOf<Self> {
      Scope(state: \.newGroup, action: \.newGroup) { NewGroupReducer() }
    }
  }
}

@ObservableState
struct SelectGroupsState: Sendable, Equatable {
  var groups: [GroupModel] = []
  var selectedGroup: GroupModel?
  let recipe: Recipe
  
  @Presents
  var destination: SelectGroupsReducer.Destination.State?
  
  init(recipe: Recipe) {
    self.recipe = recipe
  }
}

@CasePathable
enum SelectGroupsAction: Sendable, Equatable {
  case task
  case reloadGroups
  case groupTapped(GroupModel)
  case groupSelected(GroupModel)
  case cancel
  case addNewGroup
  case destination(PresentationAction<SelectGroupsReducer.Destination.Action>)
}


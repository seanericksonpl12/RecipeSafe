import Dependencies
import ComposableArchitecture
import Foundation
import SQLiteData

@Reducer
struct SelectCategoriesReducer {
  typealias State = SelectCategoriesState
  typealias Action = SelectCategoriesAction

  var body: some ReducerOf<Self> {
    Reduce { (state: inout State, action: Action) -> Effect<Action> in
      switch action {
      case .searchQueryChanged(let query):
        state.searchQuery = query
        return .none

      case .toggleTag(let tag):
        if let index = state.selectedTags.firstIndex(of: tag) {
          state.selectedTags.remove(at: index)
        } else {
          state.selectedTags.append(tag)
        }
        return .none

      case .removeTag(let tag):
        state.selectedTags.removeAll { $0 == tag }
        return .none
        
      case .deleteTag(let tag):
        state.selectedTags.removeAll { $0 == tag }
        deleteTag(tag)
        return .none

      case .createTag:
        let label = state.searchQuery.trimmingCharacters(in: .whitespaces)
        if label.isEmpty {
          state.newTagName = ""
          state.showNewTagAlert = true
        } else {
          let newTag = CategoryTag(label: label, color: 0)
          state.selectedTags.append(newTag)
          state.searchQuery = ""
        }
        return .none

      case .newTagNameChanged(let name):
        state.newTagName = name
        return .none

      case .toggleNewTagAlert(let isPresented):
        state.showNewTagAlert = isPresented
        return .none

      case .confirmNewTag:
        state.showNewTagAlert = false
        let label = state.newTagName.trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty else { return .none }
        let newTag = CategoryTag(label: label, color: 0)
        state.selectedTags.append(newTag)
        state.newTagName = ""
        return .none

      case .cancelTapped:
        return .run { _ in await dismiss() }

      case .doneTapped:
        return .run { [state] send in
          await send(.delegate(.selectedTags(state.selectedTags)))
          await dismiss()
        }
        
      default:
        return .none
      }
    }
  }
  
  @Dependency(\.dismiss)
  private var dismiss
  
  private let recipeManager = RecipeManager()
  
  private func deleteTag(_ tag: CategoryTag) {
    @Dependency(\.defaultDatabase)
    var database
    try? database.write { db in
      try CategoryTagTable
        .delete()
        .where { $0.id.eq(tag.label) }
        .execute(db)
      try RecipeCategoryTagTable
        .delete()
        .where { $0.tagId.eq(tag.label) }
        .execute(db)
    }
  }
}

@ObservableState
struct SelectCategoriesState: Sendable, Equatable {
  @FetchAll
  private var allTagRows: [CategoryTagTable]
  var allTags: [CategoryTag] {
    allTagRows.map { .init(label: $0.id, color: $0.color) }
  }

  var selectedTags: [CategoryTag]
  var searchQuery: String = ""
  
  var newTagName: String = ""
  var showNewTagAlert: Bool = false

  var filteredTags: [CategoryTag] {
    let available = allTags.filter { tag in
      !selectedTags.contains(tag)
    }
    if searchQuery.isEmpty {
      return available
    }
    return available.filter {
      $0.label.localizedCaseInsensitiveContains(searchQuery)
    }
  }

  var canCreateTag: Bool {
    let query = searchQuery.trimmingCharacters(in: .whitespaces)
    return !allTags.contains { $0.label.localizedCaseInsensitiveCompare(query) == .orderedSame }
  }

  init(recipe: Recipe) {
    self.selectedTags = recipe.tags
  }
}

@CasePathable
enum SelectCategoriesAction: Sendable, Equatable {
  case searchQueryChanged(String)
  case toggleTag(CategoryTag)
  case removeTag(CategoryTag)
  case deleteTag(CategoryTag)
  case createTag
  case cancelTapped
  case doneTapped
  
  case newTagNameChanged(String)
  case confirmNewTag
  case toggleNewTagAlert(Bool)

  case delegate(DelegateAction)
  @CasePathable
  enum DelegateAction: Sendable, Equatable {
    case selectedTags([CategoryTag])
  }
}

import Dependencies
import Foundation
import SQLiteData

struct ShoppingListDatabaseService: Sendable {
  var getItems: @Sendable () throws -> [ShoppingListModel]
  var getRecipeIds: @Sendable () throws -> [UUID]
  var addRecipe: @Sendable (Recipe) throws -> Void
  var addFreeformItem: @Sendable (String) throws -> Void
  var toggleItem: @Sendable (UUID, Bool) throws -> Void
  var removeRecipe: @Sendable (UUID) throws -> Void
  var removeItem: @Sendable (UUID) throws -> Void
  var updateSortOrder: @Sendable ([ShoppingListModel]) throws -> Void
  var resetChecks: @Sendable () throws -> Void
  var clearAll: @Sendable () throws -> Void
}

extension ShoppingListDatabaseService: DependencyKey {
  static let liveValue = ShoppingListDatabaseService {

    // MARK: getItems
    @Dependency(\.defaultDatabase) var database
    return try database.read { db in
      let rows = try ShoppingListItemTable.all.fetchAll(db)
      return rows
        .sorted { $0.sortIndex < $1.sortIndex }
        .map {
          ShoppingListModel(id: $0.id, value: $0.value, selected: $0.isCompleted, index: $0.sortIndex, recipeId: $0.recipeId)
        }
    }

  } getRecipeIds: {

    // MARK: getRecipeIds
    @Dependency(\.defaultDatabase) var database
    return try database.read { db in
      try ShoppingListRecipeTable.all.fetchAll(db).map { $0.id }
    }

  } addRecipe: { recipe in

    // MARK: addRecipe
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      // Skip if recipe already in list
      guard try ShoppingListRecipeTable.find(recipe.id).fetchOne(db) == nil else { return }

      try ShoppingListRecipeTable.insert {
        ShoppingListRecipeTable(id: recipe.id, addedAt: Date())
      }.execute(db)

      let allItems = try ShoppingListItemTable.all.fetchAll(db)
      var nextIndex = (allItems.map { $0.sortIndex }.max() ?? -1) + 1

      for ingredient in recipe.ingredients {
        try ShoppingListItemTable.insert {
          ShoppingListItemTable(
            id: UUID(),
            value: ingredient.value,
            isCompleted: false,
            sortIndex: nextIndex,
            recipeId: recipe.id
          )
        }.execute(db)
        nextIndex += 1
      }
    }

  } addFreeformItem: { text in

    // MARK: addFreeformItem
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      let allItems = try ShoppingListItemTable.all.fetchAll(db)
      let nextIndex = (allItems.map { $0.sortIndex }.max() ?? -1) + 1
      try ShoppingListItemTable.insert {
        ShoppingListItemTable(
          id: UUID(),
          value: text,
          isCompleted: false,
          sortIndex: nextIndex,
          recipeId: nil
        )
      }.execute(db)
    }

  } toggleItem: { id, newValue in

    // MARK: toggleItem
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      guard let current = try ShoppingListItemTable.find(id).fetchOne(db) else { return }
      try ShoppingListItemTable.update { $0.isCompleted = newValue }
        .where { $0.id.eq(id) }
        .execute(db)
    }

  } removeRecipe: { recipeId in

    // MARK: removeRecipe
    // Items must be deleted before the recipe row — the schema uses ON DELETE SET NULL,
    // so deleting the recipe first would null out recipeId before we can filter by it.
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      let itemIds = try ShoppingListItemTable.all
        .fetchAll(db)
        .filter { $0.recipeId == recipeId }
        .map { $0.id }
      for id in itemIds {
        try ShoppingListItemTable.delete()
          .where { $0.id.eq(id) }
          .execute(db)
      }
      try ShoppingListRecipeTable.delete()
        .where { $0.id.eq(recipeId) }
        .execute(db)
    }

  } removeItem: { id in

    // MARK: removeItem
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      try ShoppingListItemTable.delete()
        .where { $0.id.eq(id) }
        .execute(db)
    }

  } updateSortOrder: { items in

    // MARK: updateSortOrder
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      for item in items {
        try ShoppingListItemTable.update { $0.sortIndex = item.index }
          .where { $0.id.eq(item.id) }
          .execute(db)
      }
    }

  } resetChecks: {

    // MARK: clearCompleted
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      try ShoppingListItemTable.update { $0.isCompleted = false }
        .where { $0.isCompleted.eq(true) }
        .execute(db)
    }
  } clearAll: {

    // MARK: clearAll
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      try ShoppingListItemTable.delete().execute(db)
      try ShoppingListRecipeTable.delete().execute(db)
    }
  }

  // MARK: - Test Value

  static let testValue = ShoppingListDatabaseService {
    []
  } getRecipeIds: {
    []
  } addRecipe: { _ in
  } addFreeformItem: { _ in
  } toggleItem: { _, _ in
  } removeRecipe: { _ in
  } removeItem: { _ in
  } updateSortOrder: { _ in
  } resetChecks: {
  } clearAll: {
  }
}

extension DependencyValues {
  var shoppingListDatabaseService: ShoppingListDatabaseService {
    get { self[ShoppingListDatabaseService.self] }
    set { self[ShoppingListDatabaseService.self] = newValue }
  }
}

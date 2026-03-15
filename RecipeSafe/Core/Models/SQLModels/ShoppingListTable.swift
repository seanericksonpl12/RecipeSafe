import Foundation
import SQLiteData

@Table
struct ShoppingListRecipeTable: Identifiable {
  let id: UUID
  var addedAt: Date
}

@Table
struct ShoppingListItemTable: Identifiable {
  let id: UUID
  var value: String
  var isCompleted: Bool
  var sortIndex: Int
  var recipeId: UUID?
}

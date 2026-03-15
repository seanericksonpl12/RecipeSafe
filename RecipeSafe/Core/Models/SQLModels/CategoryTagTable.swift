import Foundation
import SQLiteData

@Table
struct CategoryTagTable: Identifiable, Equatable, Sendable {
  @Column(primaryKey: true)
  let id: String
  var color: Int16
}

@Table
struct RecipeCategoryTagTable: Identifiable {
  let id: UUID
  let recipeId: RecipeTable.ID
  let tagId: CategoryTagTable.ID
}

import Foundation
import SQLiteData

@Table
struct RecipeTable: Identifiable, Equatable, Sendable {
  let id: UUID
  var title: String
  var description: String
  var imageUrl: URL?
  var imageData: Data?
  var url: URL?
  var prepTime: String
  var cookTime: String
  var isFavorite: Bool
  var dateAdded: Date
  var viewCount: Int
}

@Table
struct IngredientTable: Identifiable {
  let id: UUID
  var recipeId: RecipeTable.ID
  var value: String
}

@Table
struct InstructionTable: Identifiable {
  let id: UUID
  var recipeId: RecipeTable.ID
  var value: String
}

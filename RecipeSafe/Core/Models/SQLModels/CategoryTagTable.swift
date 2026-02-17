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

//extension CategoryTagTable: FetchKeyRequest {
//  func fetch(_ db: Database) throws -> [CategoryTag] {
//    try CategoryTagTable.fetchAll(db).map { CategoryTag(label: $0.id, color: $0.color) }
//  }
//}

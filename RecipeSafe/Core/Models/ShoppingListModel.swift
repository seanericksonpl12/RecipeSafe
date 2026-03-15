import Foundation

struct ShoppingListModel: Identifiable, Hashable, Sendable {
  let id: UUID
  var value: String
  var selected: Bool
  var index: Int
  var recipeId: UUID? = nil

  var category: GroceryCategory {
    GroceryCategorizer.categorize(value)
  }
}

import CoreData
import Foundation
import Dependencies

struct ShoppingListModel: Identifiable, Hashable, Sendable {
  let id: UUID
  var value: String
  var selected: Bool
  var index: Int
}

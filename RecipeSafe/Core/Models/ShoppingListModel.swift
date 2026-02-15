import CoreData
import Foundation
import Dependencies

struct ShoppingListModel: DataModel, Identifiable, Hashable {
  var id: NSManagedObjectID
  var value: String
  var selected: Bool
  var index: Int
  
  init?(id: NSManagedObjectID) {
    @Dependency(\.coreDataService) var coreDataService
    guard let entity = coreDataService.fetch(id: id) as? ShoppingListItem else {
      return nil
    }
    self.id = id
    self.value = entity.value ?? ""
    self.selected = entity.selected
    self.index = Int(entity.index)
  }
  
  init(dataItem: ShoppingListItem) {
    self.id = dataItem.objectID
    self.value = dataItem.value ?? ""
    self.selected = dataItem.selected
    self.index = Int(dataItem.index)
  }
  
  init(id: NSManagedObjectID, value: String, selected: Bool, index: Int) {
    self.id = id
    self.value = value
    self.selected = selected
    self.index = index
  }
}

import Dependencies
import Foundation
import CoreData

struct GroupModel: Hashable, Equatable, Identifiable, Sendable {
  
  var recipes: [Recipe]
  var title: String
  var color: Int16
  var dataEntityID: NSManagedObjectID
  
  var id: NSManagedObjectID { dataEntityID }
  
  var imgUrl: URL? {
    self.recipes.first(where: {
      if case .downloaded(let url) = $0.img {
        return url != nil
      }
      return false
    }).flatMap {
      if case .downloaded(let url) = $0.img {
        return url
      }
      return nil
    }
  }
  
  init(dataEntity: GroupItem) {
    let recipeItems = dataEntity.recipes?.array as? [RecipeItem] ?? []
//    self.recipes = recipeItems.compactMap { Recipe(dataItem: $0) }
    self.recipes = []
    self.title = dataEntity.title ?? "group.default".localized
    self.color = dataEntity.color
    self.dataEntityID = dataEntity.objectID
  }
}


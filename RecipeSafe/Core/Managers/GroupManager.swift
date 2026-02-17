import Foundation
import CoreData
import SwiftUI
import Dependencies

struct GroupManager {
  
  func create(title: String, recipes: [Recipe], color: Int16?) throws {
    guard let group = coreDataService.create(GroupItem.self) else {
      throw NSError(domain: "Group", code: 0)
    }
    group.title = title
    // Get image URL from Recipe
    let imgUrl = recipes.first(where: { 
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
    group.imgUrl = imgUrl
    group.color = if let color {
      color
    } else {
      try getNewColor()
    }
    // Convert Recipe to RecipeItem for storage
//    for recipe in recipes {
//      if let recipeId = recipe.dataEntity, let recipeItem = coreDataService.fetch(id: recipeId) as? RecipeItem {
//        group.addToRecipes(recipeItem)
//      }
//    }
    try coreDataService.save()
  }
  
  func getGroup(for id: NSManagedObjectID) -> GroupItem? {
    coreDataService.fetch(id: id) as? GroupItem
  }

  func update(_ group: GroupModel) throws {
    guard let groupItem = getGroup(for: group.dataEntityID) else { return }
    groupItem.title = group.title
    groupItem.recipes = []
    groupItem.imgUrl = group.imgUrl
    if groupItem.color == 0 {
        groupItem.color = try getNewColor()
    }
    // Convert Recipe back to RecipeItem for storage
//    for recipe in group.recipes {
//      if let recipeId = recipe.dataEntity, let recipeItem = coreDataService.fetch(id: recipeId) as? RecipeItem {
//        groupItem.addToRecipes(recipeItem)
//      }
//    }
    try coreDataService.save()
  }
  
  func getColor(for id: NSManagedObjectID) -> Int16? {
    getGroup(for: id)?.color
  }
  
  func getNewColor() throws -> Int16 {
    let groups = try coreDataService.fetchAll(GroupItem.self)
    var colors: [Int16 : Bool] = [1:false,2:false,3:false,4:false,5:false,6:false]
    groups.forEach { colors[$0.color] = $0.imgUrl == nil }
    
    return if let newColor = colors.first(where: { $0.value == false })?.key {
      newColor
    } else {
      Int16.random(in: 1..<7)
    }
  }
  
  @Dependency(\.coreDataService)
  private var coreDataService
}

import Foundation
import CoreData
import SwiftUI
import Dependencies

struct RecipeManager {
  func buildRecipe(url: URL) async throws -> Recipe {
    guard url.scheme == Constants.scheme else {
      throw NetworkError.invalidURL("Bad URL scheme")
    }
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      throw NetworkError.invalidURL("Could not create components")
    }
    guard components.host == Constants.host else {
      throw NetworkError.invalidURL("Bad URL host")
    }
    guard let embeddedUrl = components.queryItems?.first(where: { $0.name == "url" })?.value else {
      throw NetworkError.invalidURL("Bad URL queries")
    }
    let recipeComponents = URLComponents(string: "https://".appending(embeddedUrl))
    guard let urlStr = recipeComponents?.url?.absoluteString else {
      throw NetworkError.invalidURL("Could not resolve url")
    }
    
    let slicedURL = urlStr.replacing("\(Constants.scheme)://", with: "")
    
    var recipe = try await (recipeDataService.buildRecipe(slicedURL))
    recipe.url = URL(string: slicedURL)
    
    return recipe
  }
  
  func save(recipe: Recipe) throws {
    try saveRecipe(recipe)
  }
  
  func getRecipe(for id: NSManagedObjectID?) -> RecipeItem? {
    guard let id else { return nil }
    return coreDataService.fetch(id: id) as? RecipeItem
  }
  
  func update(recipe: Recipe, sendUpdateMessage: Bool = false) throws {
    try databaseService.updateRecipe(recipe)
    if sendUpdateMessage {
      eventBus.send(.recipeDatabaseUpdated)
    }
//    guard let id = recipe.dataEntity else { return }
//    if let object = coreDataService.fetch(id: id) as? RecipeItem {
//      try coreDataService.delete(object)
//    }
//    let entity = try saveRecipe(recipe)
//    try coreDataService.save()
//    recipe.dataEntity = entity.objectID
  }
  
  func delete(_ recipe: Recipe) throws {
    try databaseService.deleteRecipe(recipe)
    eventBus.send(.recipeDatabaseUpdated)
//    guard let id = recipe.dataEntity else { return }
//    try coreDataService.delete(id: id)
  }
  
  @MainActor
  func deleteRecipes(at offsets: IndexSet, _ recipes: FetchedResults<RecipeItem>) throws {
    try offsets.map { recipes[$0] }.forEach { try coreDataService.delete($0) }
  }
  
  func findDuplicates(of recipe: Recipe) throws -> RecipeItem? {
    let recipes = try coreDataService.fetchAll(RecipeItem.self)
    guard let url = recipe.url else { throw URLError(.badURL) }
    return recipes.first { $0.url == url }
  }
  
  func addToGroup(_ recipe: Recipe, group: GroupItem) throws {
//    if let id = recipe.dataEntity, let data = coreDataService.fetch(id: id) as? RecipeItem {
//      group.addToRecipes(data)
//      if let recipes = group.recipes?.array as? [RecipeItem] {
//        group.imgUrl = recipes.first(where: {$0.imageUrl != nil })?.imageUrl
//      }
//      try coreDataService.save()
//    }
  }
  
  func fetchAll() throws -> [Recipe] {
    try databaseService.getRecipes()
  }
  
  private func saveRecipe(_ recipe: Recipe) throws {
    try databaseService.saveRecipe(recipe)
    eventBus.send(.recipeDatabaseUpdated)
  }
  
  @Dependency(\.recipeDataService)
  private var recipeDataService
  
  @Dependency(\.coreDataService)
  private var coreDataService
  
  @Dependency(\.databaseService)
  private var databaseService
  
  @Dependency(\.eventBus)
  private var eventBus
  
  private enum Constants {
    static let scheme = "RecipeSafe"
    static let host = "open-recipe"
  }
}

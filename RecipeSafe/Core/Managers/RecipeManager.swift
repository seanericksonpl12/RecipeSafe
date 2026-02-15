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
  
  func save(recipe: Recipe) throws -> RecipeItem {
    try saveRecipe(recipe)
  }
  
  func getRecipe(for id: NSManagedObjectID?) -> RecipeItem? {
    guard let id else { return nil }
    return coreDataService.fetch(id: id) as? RecipeItem
  }
  
  func updateRecipe(_ recipe: inout Recipe) throws {
    guard let id = recipe.dataEntity else { return }
    if let object = coreDataService.fetch(id: id) as? RecipeItem {
      try coreDataService.delete(object)
    }
    let entity = try saveRecipe(recipe)
    try coreDataService.save()
    recipe.dataEntity = entity.objectID
  }
  
  func delete(_ recipe: Recipe) throws {
    guard let id = recipe.dataEntity else { return }
    try coreDataService.delete(id: id)
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
    if let id = recipe.dataEntity, let data = coreDataService.fetch(id: id) as? RecipeItem {
      group.addToRecipes(data)
      if let recipes = group.recipes?.array as? [RecipeItem] {
        group.imgUrl = recipes.first(where: {$0.imageUrl != nil })?.imageUrl
      }
      try coreDataService.save()
    }
  }
  
  func fetchAll() throws -> [Recipe] {
    try coreDataService.fetchAll(RecipeItem.self).compactMap { Recipe(dataItem: $0) }
  }
  
  private func saveRecipe(_ recipe: Recipe) throws -> RecipeItem {
    guard let newRecipe = coreDataService.create(RecipeItem.self) else {
      throw NSError(domain: "RecipeError", code: 0)
    }
    newRecipe.id = recipe.id
    newRecipe.title = recipe.title
    newRecipe.desc = recipe.description
    newRecipe.cookTime = recipe.cookTime
    newRecipe.prepTime = recipe.prepTime
    newRecipe.url = recipe.url
    newRecipe.ingredients = []
    newRecipe.instructions = []
    switch recipe.img {
    case .downloaded(let url):
      newRecipe.imageUrl = url
    case .selected(let data):
      newRecipe.photoData = data
    case .none:
      newRecipe.photoData = nil
      newRecipe.imageUrl = nil
    }
    recipe.ingredients.forEach { item in
      if let i = coreDataService.create(Ingredient.self) {
        i.value = item
        newRecipe.addToIngredients(i)
      }
    }
    recipe.instructions.forEach { item in
      if let i = coreDataService.create(Instruction.self) {
        i.value = item
        newRecipe.addToInstructions(i)
      }
    }
    
    try coreDataService.save()
    return newRecipe
  }
  
  @Dependency(\.recipeDataService)
  private var recipeDataService
  
  @Dependency(\.coreDataService)
  private var coreDataService
  
  private enum Constants {
    static let scheme = "RecipeSafe"
    static let host = "open-recipe"
  }
}

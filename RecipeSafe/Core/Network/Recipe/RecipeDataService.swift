import Dependencies
import Foundation

public struct RecipeDataService: Sendable {
  var buildRecipe: @Sendable (String) async throws -> Recipe
}

extension RecipeDataService: DependencyKey {
  public static let liveValue = RecipeDataService { url in
    let data = try await HttpClient().request(url: url)
    return try RecipeUtil().buildRecipe(from: data)
  }

  public static let testValue = RecipeDataService { _ in
    Recipe.recipeMockScampi
  }
}

extension DependencyValues {
  var recipeDataService: RecipeDataService {
    get { self[RecipeDataService.self] }
    set { self[RecipeDataService.self] = newValue }
  }
}


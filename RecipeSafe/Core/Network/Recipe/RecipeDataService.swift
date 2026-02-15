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

  public static let testValue = RecipeDataService {
    Recipe(
      title: "title",
      description: "Recipe description",
      ingredients: [
        "Ingredient 1",
        "Ingredient 2",
        "Ingredient 3",
        "Ingredient 4",
        "Ingredient 5",
      ],
      instructions: [
        "Instruction 1",
        "Instruction 2",
        "Instruction 3",
        "Instruction 4",
        "Instruction 5",
      ],
      img: .none,
      url: URL(string: $0),
      prepTime: "25 min",
      cookTime: "30 min"
    )
  }
}

extension DependencyValues {
  var recipeDataService: RecipeDataService {
    get { self[RecipeDataService.self] }
    set { self[RecipeDataService.self] = newValue }
  }
}


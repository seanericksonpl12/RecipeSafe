import Dependencies
import Foundation
import SQLiteData

struct DatabaseService: Sendable {
  var getRecipes: @Sendable () throws -> [Recipe]
  var saveRecipe: @Sendable (Recipe) throws -> Void
  var deleteRecipe: @Sendable (Recipe) throws -> Void
  var updateRecipe: @Sendable (Recipe) throws -> Void
}

extension DatabaseService: DependencyKey {
  static let liveValue = DatabaseService {
    
    // MARK: Get Recipes
    @Dependency(\.defaultDatabase) var database
    return try database.read { db in
      let recipes = try RecipeTable.all.fetchAll(db)
      return try recipes.map { recipeRow in
        let ingredients = try IngredientTable
          .where { $0.recipeId.eq(recipeRow.id) }
          .fetchAll(db)
          .map { IdentifiedString(id: $0.id, value: $0.value) }
        let instructions = try InstructionTable
          .where { $0.recipeId.eq(recipeRow.id) }
          .fetchAll(db)
          .map { IdentifiedString(id: $0.id, value: $0.value) }
        let tags = try RecipeCategoryTagTable
          .where { $0.recipeId.eq(recipeRow.id) }
          .fetchAll(db)
          .compactMap { junction in
            try CategoryTagTable.find(junction.tagId).fetchOne(db)
          }
          .map { CategoryTag(label: $0.id, color: $0.color) }
        var recipe = Recipe(
          id: recipeRow.id,
          title: recipeRow.title,
          description: recipeRow.description,
          ingredients: ingredients,
          instructions: instructions,
          imageUrl: recipeRow.imageUrl, imageData: recipeRow.imageData,
          url: recipeRow.url,
          prepTime: recipeRow.prepTime,
          cookTime: recipeRow.cookTime,
          tags: tags,
          isFavorite: recipeRow.isFavorite,
          dateAdded: recipeRow.dateAdded,
          viewCount: recipeRow.viewCount
        )
        return recipe
      }
    }
  }
  
  // MARK: Save Recipe (new)
  saveRecipe: { recipe in
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      try RecipeTable.insert {
        RecipeTable(
          id: recipe.id,
          title: recipe.title,
          description: recipe.description,
          imageUrl: recipe.imageUrl,
          imageData: recipe.imageData,
          url: recipe.url,
          prepTime: recipe.prepTime,
          cookTime: recipe.cookTime,
          isFavorite: recipe.isFavorite,
          dateAdded: recipe.dateAdded,
          viewCount: recipe.viewCount
        )
      }.execute(db)
      for tag in recipe.tags {
        let exists = try CategoryTagTable.find(tag.label).fetchOne(db) != nil
        if !exists {
          try CategoryTagTable.insert {
            CategoryTagTable(id: tag.label, color: tag.color)
          }.execute(db)
        }
        try RecipeCategoryTagTable.insert {
          RecipeCategoryTagTable(id: UUID(), recipeId: recipe.id, tagId: tag.label)
        }.execute(db)
      }
      for ingredient in recipe.ingredients {
        try IngredientTable.insert {
          IngredientTable(id: ingredient.id, recipeId: recipe.id, value: ingredient.value)
        }.execute(db)
      }
      for instruction in recipe.instructions {
        try InstructionTable.insert {
          InstructionTable(id: instruction.id, recipeId: recipe.id, value: instruction.value)
        }.execute(db)
      }
    }
  }

  // MARK: Delete Recipes
  deleteRecipe: { recipe in
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      try RecipeTable.delete().where { $0.id.eq(recipe.id) }.execute(db)
    }
  }
  
  // MARK: Update Recipe (existing)
  updateRecipe: { recipe in
    @Dependency(\.defaultDatabase) var database
    try database.write { db in
      try RecipeTable.update {
        $0.title = recipe.title
        $0.description = recipe.description
        $0.imageUrl = recipe.imageUrl
        $0.imageData = recipe.imageData
        $0.url = recipe.url
        $0.prepTime = recipe.prepTime
        $0.cookTime = recipe.cookTime
        $0.isFavorite = recipe.isFavorite
        $0.dateAdded = recipe.dateAdded
        $0.viewCount = recipe.viewCount
      }.where { $0.id.eq(recipe.id) }.execute(db)
      try IngredientTable.delete().where { $0.recipeId.eq(recipe.id) }.execute(db)
      try InstructionTable.delete().where { $0.recipeId.eq(recipe.id) }.execute(db)
      try RecipeCategoryTagTable.delete().where { $0.recipeId.eq(recipe.id) }.execute(db)
      for tag in recipe.tags {
        let exists = try CategoryTagTable.find(tag.label).fetchOne(db) != nil
        if !exists {
          try CategoryTagTable.insert {
            CategoryTagTable(id: tag.label, color: tag.color)
          }.execute(db)
        }
        try RecipeCategoryTagTable.insert {
          RecipeCategoryTagTable(id: UUID(), recipeId: recipe.id, tagId: tag.label)
        }.execute(db)
      }
      for ingredient in recipe.ingredients {
        try IngredientTable.insert {
          IngredientTable(id: ingredient.id, recipeId: recipe.id, value: ingredient.value)
        }.execute(db)
      }
      for instruction in recipe.instructions {
        try InstructionTable.insert {
          InstructionTable(id: instruction.id, recipeId: recipe.id, value: instruction.value)
        }.execute(db)
      }
    }
  }

  static let testValue = DatabaseService {
    []
  } saveRecipe: { _ in

  } deleteRecipe: { _ in }
  updateRecipe: { _ in }
}

extension DependencyValues {
  var databaseService: DatabaseService {
    get { self[DatabaseService.self] }
    set { self[DatabaseService.self] = newValue }
  }
}

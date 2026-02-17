//
//  DataMigrationTests.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/16/26.
//

import XCTest
import CoreData
import SQLiteData
@testable import RecipeSafe

final class DataMigrationTests: XCTestCase {

  var coreDataStack: PersistenceController!
  var context: NSManagedObjectContext!
  var database: DatabaseQueue!
  var setupManager: DatabaseSetupManager!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false

    // In-memory Core Data
    coreDataStack = PersistenceController(inMemory: true)
    context = coreDataStack.container.viewContext

    // In-memory SQLite
    database = try! DatabaseQueue()
    try! createTables(in: database)

    setupManager = DatabaseSetupManager(database: database)

    // Reset migration flag
    UserDefaults.standard.set(false, forKey: "hasMigratedCoreData")
  }

  override func tearDown() {
    UserDefaults.standard.removeObject(forKey: "hasMigratedCoreData")
    super.tearDown()
  }

  // MARK: - Tests

  func testMigrationSkipsWhenAlreadyMigrated() throws {
    seedRecipe(title: "Should Not Migrate")
    try context.save()

    UserDefaults.standard.set(true, forKey: "hasMigratedCoreData")

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let recipes = try database.read { db in
      try RecipeTable.all.fetchAll(db)
    }
    XCTAssertTrue(recipes.isEmpty, "No recipes should be migrated when flag is already set")
  }

  func testMigrationSetsFlag() throws {
    XCTAssertFalse(UserDefaults.standard.bool(forKey: "hasMigratedCoreData"))

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasMigratedCoreData"))
  }

  func testMigrationSetsFlagWhenNoCoreData() throws {
    // No Core Data records at all
    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasMigratedCoreData"))
    let recipes = try database.read { db in
      try RecipeTable.all.fetchAll(db)
    }
    XCTAssertTrue(recipes.isEmpty)
  }

  func testMigratesBasicRecipe() throws {
    let recipeId = UUID()
    let item = seedRecipe(
      id: recipeId,
      title: "Spaghetti",
      desc: "Classic pasta",
      prepTime: "10 min",
      cookTime: "20 min"
    )
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let recipes = try database.read { db in
      try RecipeTable.all.fetchAll(db)
    }
    XCTAssertEqual(recipes.count, 1)
    let recipe = try XCTUnwrap(recipes.first)
    XCTAssertEqual(recipe.id, recipeId)
    XCTAssertEqual(recipe.title, "Spaghetti")
    XCTAssertEqual(recipe.description, "Classic pasta")
    XCTAssertEqual(recipe.prepTime, "10 min")
    XCTAssertEqual(recipe.cookTime, "20 min")
    XCTAssertEqual(recipe.isFavorite, false)
    XCTAssertEqual(recipe.viewCount, 0)
  }

  func testMigratesIngredients() throws {
    let recipeId = UUID()
    let item = seedRecipe(id: recipeId, title: "Test")
    addIngredient(to: item, value: "Salt")
    addIngredient(to: item, value: "Pepper")
    addIngredient(to: item, value: "") // empty — should be skipped
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let ingredients = try database.read { db in
      try IngredientTable
        .where { $0.recipeId.eq(recipeId) }
        .fetchAll(db)
    }
    XCTAssertEqual(ingredients.count, 2)
    let values = ingredients.map(\.value)
    XCTAssertTrue(values.contains("Salt"))
    XCTAssertTrue(values.contains("Pepper"))
  }

  func testMigratesInstructions() throws {
    let recipeId = UUID()
    let item = seedRecipe(id: recipeId, title: "Test")
    addInstruction(to: item, value: "Boil water")
    addInstruction(to: item, value: "Add pasta")
    addInstruction(to: item, value: "") // empty — should be skipped
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let instructions = try database.read { db in
      try InstructionTable
        .where { $0.recipeId.eq(recipeId) }
        .fetchAll(db)
    }
    XCTAssertEqual(instructions.count, 2)
    let values = instructions.map(\.value)
    XCTAssertTrue(values.contains("Boil water"))
    XCTAssertTrue(values.contains("Add pasta"))
  }

  func testMigratesGroupToTag() throws {
    let recipeId = UUID()
    let item = seedRecipe(id: recipeId, title: "Test")
    let group = GroupItem(context: context)
    group.title = "Italian"
    group.color = 3
    item.group = group
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let (tags, junctions) = try database.read { db -> ([CategoryTagTable], [RecipeCategoryTagTable]) in
      let tags = try CategoryTagTable.all.fetchAll(db)
      let junctions = try RecipeCategoryTagTable
        .where { $0.recipeId.eq(recipeId) }
        .fetchAll(db)
      return (tags, junctions)
    }

    XCTAssertEqual(tags.count, 1)
    XCTAssertEqual(tags.first?.id, "Italian")
    XCTAssertEqual(tags.first?.color, 3)
    XCTAssertEqual(junctions.count, 1)
    XCTAssertEqual(junctions.first?.tagId, "Italian")
  }

  func testMigratesMultipleRecipesWithSameGroup() throws {
    let group = GroupItem(context: context)
    group.title = "Chicken"
    group.color = 4

    let id1 = UUID()
    let item1 = seedRecipe(id: id1, title: "Grilled Chicken")
    item1.group = group

    let id2 = UUID()
    let item2 = seedRecipe(id: id2, title: "Chicken Soup")
    item2.group = group

    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let (tags, junctions) = try database.read { db -> ([CategoryTagTable], [RecipeCategoryTagTable]) in
      let tags = try CategoryTagTable.all.fetchAll(db)
      let junctions = try RecipeCategoryTagTable.all.fetchAll(db)
      return (tags, junctions)
    }

    // Should only create one tag, but two junction rows
    XCTAssertEqual(tags.count, 1)
    XCTAssertEqual(tags.first?.id, "Chicken")
    XCTAssertEqual(junctions.count, 2)
  }

  func testMigrationDeletesCoreDataRecords() throws {
    seedRecipe(title: "Recipe 1")
    seedRecipe(title: "Recipe 2")
    let group = GroupItem(context: context)
    group.title = "TestGroup"
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let recipeFetch: NSFetchRequest<RecipeItem> = RecipeItem.fetchRequest()
    let remainingRecipes = try context.fetch(recipeFetch)
    XCTAssertTrue(remainingRecipes.isEmpty, "Core Data recipes should be deleted after migration")

    let groupFetch: NSFetchRequest<GroupItem> = GroupItem.fetchRequest()
    let remainingGroups = try context.fetch(groupFetch)
    XCTAssertTrue(remainingGroups.isEmpty, "Core Data groups should be deleted after migration")
  }

  func testMigratesRecipeWithNilId() throws {
    let item = seedRecipe(title: "No ID Recipe")
    item.id = nil
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let recipes = try database.read { db in
      try RecipeTable.all.fetchAll(db)
    }
    XCTAssertEqual(recipes.count, 1)
    XCTAssertEqual(recipes.first?.title, "No ID Recipe")
  }

  func testMigratesRecipeWithNilFields() throws {
    let item = RecipeItem(context: context)
    item.id = UUID()
    // Leave all optional fields nil
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let recipes = try database.read { db in
      try RecipeTable.all.fetchAll(db)
    }
    XCTAssertEqual(recipes.count, 1)
    let recipe = try XCTUnwrap(recipes.first)
    XCTAssertEqual(recipe.title, "")
    XCTAssertEqual(recipe.description, "")
    XCTAssertEqual(recipe.prepTime, "")
    XCTAssertEqual(recipe.cookTime, "")
  }

  func testSkipsGroupWithEmptyTitle() throws {
    let recipeId = UUID()
    let item = seedRecipe(id: recipeId, title: "Test")
    let group = GroupItem(context: context)
    group.title = ""
    group.color = 0
    item.group = group
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let (tags, junctions) = try database.read { db -> ([CategoryTagTable], [RecipeCategoryTagTable]) in
      let tags = try CategoryTagTable.all.fetchAll(db)
      let junctions = try RecipeCategoryTagTable.all.fetchAll(db)
      return (tags, junctions)
    }

    XCTAssertTrue(tags.isEmpty, "Empty group title should not create a tag")
    XCTAssertTrue(junctions.isEmpty)
  }

  func testMigratesMultipleRecipes() throws {
    for i in 0..<5 {
      let item = seedRecipe(title: "Recipe \(i)")
      addIngredient(to: item, value: "Ingredient \(i)")
      addInstruction(to: item, value: "Step \(i)")
    }
    try context.save()

    setupManager.migrateFromCoreDataIfNeeded(container: coreDataStack.container)

    let (recipes, ingredients, instructions) = try database.read { db in
      let r = try RecipeTable.all.fetchAll(db)
      let i = try IngredientTable.all.fetchAll(db)
      let ins = try InstructionTable.all.fetchAll(db)
      return (r, i, ins)
    }

    XCTAssertEqual(recipes.count, 5)
    XCTAssertEqual(ingredients.count, 5)
    XCTAssertEqual(instructions.count, 5)
  }

  // MARK: - Helpers

  @discardableResult
  private func seedRecipe(
    id: UUID = UUID(),
    title: String = "",
    desc: String = "",
    prepTime: String = "",
    cookTime: String = ""
  ) -> RecipeItem {
    let item = RecipeItem(context: context)
    item.id = id
    item.title = title
    item.desc = desc
    item.prepTime = prepTime
    item.cookTime = cookTime
    return item
  }

  private func addIngredient(to recipe: RecipeItem, value: String) {
    let ingredient = Ingredient(context: context)
    ingredient.value = value
    recipe.addToIngredients(ingredient)
  }

  private func addInstruction(to recipe: RecipeItem, value: String) {
    let instruction = Instruction(context: context)
    instruction.value = value
    recipe.addToInstructions(instruction)
  }

  private func createTables(in db: DatabaseQueue) throws {
    try db.write { db in
      try db.execute(sql: """
        CREATE TABLE "recipeTables" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
          "title" TEXT NOT NULL DEFAULT '',
          "description" TEXT NOT NULL DEFAULT '',
          "imageUrl" TEXT,
          "imageData" BLOB,
          "url" TEXT,
          "prepTime" TEXT NOT NULL DEFAULT '',
          "cookTime" TEXT NOT NULL DEFAULT '',
          "isFavorite" INTEGER NOT NULL DEFAULT 0,
          "dateAdded" TEXT NOT NULL DEFAULT '',
          "viewCount" INTEGER NOT NULL DEFAULT 0
        ) STRICT
      """)
      try db.execute(sql: """
        CREATE TABLE "ingredientTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "recipeId" TEXT NOT NULL REFERENCES "recipeTables"("id") ON DELETE CASCADE,
          "value" TEXT NOT NULL DEFAULT ''
        ) STRICT
      """)
      try db.execute(sql: """
        CREATE TABLE "instructionTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "recipeId" TEXT NOT NULL REFERENCES "recipeTables"("id") ON DELETE CASCADE,
          "value" TEXT NOT NULL DEFAULT ''
        ) STRICT
      """)
      try db.execute(sql: """
        CREATE TABLE "categoryTagTables" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
          "color" INTEGER NOT NULL DEFAULT 0
        ) STRICT
      """)
      try db.execute(sql: """
        CREATE TABLE "recipeCategoryTagTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "recipeId" TEXT NOT NULL REFERENCES "recipeTables"("id") ON DELETE CASCADE,
          "tagId" TEXT NOT NULL REFERENCES "categoryTagTables"("id") ON DELETE CASCADE,
          UNIQUE("recipeId", "tagId")
        ) STRICT
      """)
    }
  }
}

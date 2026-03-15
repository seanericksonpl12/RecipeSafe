import CoreData
import SQLiteData
import SwiftUI
import OSLog

struct PersistenceController {
  
  static let shared = PersistenceController()
  static let preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    for i in 0..<10 {
      let newItem = RecipeItem(context: viewContext)
      newItem.title = "Recipe Number \(i)"
      let i1 = Ingredient(context: viewContext)
      i1.value = "ingredient 1"
      let i2 = Ingredient(context: viewContext)
      i2.value = "ingredient 2"
      let in1 = Instruction(context: viewContext)
      in1.value = "step 1"
      let in2 = Instruction(context: viewContext)
      in2.value = "step 2"
      newItem.desc = "Description of recipe \(i)"
      newItem.addToIngredients(i1)
      newItem.addToIngredients(i2)
      newItem.addToInstructions(in1)
      newItem.addToInstructions(in2)
    }
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      print("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()
  
  // MARK: - Container
  let container: NSPersistentContainer
  
  // MARK: - Init
  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "RecipeSafe")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        print(String(describing: error))
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}

extension PersistenceController {
  static func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    var configuration = Configuration()
#if DEBUG
    configuration.prepareDatabase { db in
      db.trace(options: .profile) {
        if context == .preview {
          print("\($0.expandedDescription)")
        } else {
          Logger.log("\($0.expandedDescription)", category: .database)
        }
      }
    }
#endif
    let database = try defaultDatabase(configuration: configuration)
    Logger.log("open \(database.path)", category: .database)
    
    var migrator = DatabaseMigrator()
    migrator.eraseDatabaseOnSchemaChange = true
    migrator.registerMigration("Create Tables") { db in
      try #sql("""
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
      """).execute(db)
      try #sql("""
        CREATE TABLE "ingredientTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "recipeId" TEXT NOT NULL REFERENCES "recipeTables"("id") ON DELETE CASCADE,
          "value" TEXT NOT NULL DEFAULT ''
        ) STRICT
      """).execute(db)
      try #sql("""
        CREATE INDEX "index_ingredientTables_on_recipeId" ON "ingredientTables"("recipeId")
      """).execute(db)
      try #sql("""
        CREATE TABLE "instructionTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "recipeId" TEXT NOT NULL REFERENCES "recipeTables"("id") ON DELETE CASCADE,
          "value" TEXT NOT NULL DEFAULT ''
        ) STRICT
      """).execute(db)
      try #sql("""
        CREATE INDEX "index_instructionTables_on_recipeId" ON "instructionTables"("recipeId")
      """).execute(db)
      try #sql("""
        CREATE TABLE "categoryTagTables" (
          "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
          "color" INTEGER NOT NULL DEFAULT 0
        ) STRICT
      """).execute(db)
      try #sql("""
        CREATE TABLE "recipeCategoryTagTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "recipeId" TEXT NOT NULL REFERENCES "recipeTables"("id") ON DELETE CASCADE,
          "tagId" TEXT NOT NULL REFERENCES "categoryTagTables"("id") ON DELETE CASCADE,
          UNIQUE("recipeId", "tagId")
        ) STRICT
      """).execute(db)
      try #sql("""
        CREATE INDEX "index_recipeCategoryTagTables_on_recipeId" ON "recipeCategoryTagTables"("recipeId")
      """).execute(db)
      try #sql("""
        CREATE INDEX "index_recipeCategoryTagTables_on_tagId" ON "recipeCategoryTagTables"("tagId")
      """).execute(db)
    }
    migrator.registerMigration("Add Shopping List Tables") { db in
      try #sql("""
        CREATE TABLE "shoppingListRecipeTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "addedAt" TEXT NOT NULL DEFAULT ''
        ) STRICT
      """).execute(db)
      try #sql("""
        CREATE TABLE "shoppingListItemTables" (
          "id" TEXT PRIMARY KEY NOT NULL,
          "value" TEXT NOT NULL DEFAULT '',
          "isCompleted" INTEGER NOT NULL DEFAULT 0,
          "sortIndex" INTEGER NOT NULL DEFAULT 0,
          "recipeId" TEXT REFERENCES "shoppingListRecipeTables"("id") ON DELETE SET NULL
        ) STRICT
      """).execute(db)
      try #sql("""
        CREATE INDEX "index_shoppingListItemTables_on_recipeId" ON "shoppingListItemTables"("recipeId")
      """).execute(db)
    }
    try migrator.migrate(database)
    
    // Custom Database setup
    let setupManager = DatabaseSetupManager(database: database)
    setupManager.addDefaultTagsIfNeeded()
    setupManager.migrateFromCoreDataIfNeeded()

    return database
  }
}

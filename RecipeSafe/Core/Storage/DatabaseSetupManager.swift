import CoreData
import Dependencies
import Foundation
import SQLiteData

struct DatabaseSetupManager: Sendable {
  let database: any DatabaseWriter

  func addDefaultTagsIfNeeded() {
    if !UserDefaults.standard.hasMigratedDb {
      do {
        try database.write { db in
          for tag in CategoryTag.defaultTags {
            try CategoryTagTable.insert {
              CategoryTagTable(id: tag.label, color: tag.color)
            }.execute(db)
          }
        }
      } catch {
        Logger.log("Failed to add default tags", category: .database)
      }
    }
  }

  func migrateFromCoreDataIfNeeded(
    container: NSPersistentContainer = PersistenceController.shared.container
  ) {
    guard !UserDefaults.standard.hasMigratedCoreData else { return }

    let context = container.viewContext

    let fetchRequest: NSFetchRequest<RecipeItem> = RecipeItem.fetchRequest()
    do {
      let coreDataRecipes = try context.fetch(fetchRequest)
      guard !coreDataRecipes.isEmpty else {
        UserDefaults.standard.hasMigratedCoreData = true
        return
      }

      try database.write { db in
        for item in coreDataRecipes {
          let recipeId = item.id ?? UUID()

          try RecipeTable.insert {
            RecipeTable(
              id: recipeId,
              title: item.title ?? "",
              description: item.desc ?? "",
              imageUrl: item.imageUrl,
              imageData: item.photoData,
              url: item.url,
              prepTime: item.prepTime ?? "",
              cookTime: item.cookTime ?? "",
              isFavorite: false,
              dateAdded: Date(),
              viewCount: 0
            )
          }.execute(db)

          let ingredients = item.ingredients?.array as? [Ingredient] ?? []
          for ingredient in ingredients {
            guard let value = ingredient.value, !value.isEmpty else { continue }
            try IngredientTable.insert {
              IngredientTable(id: UUID(), recipeId: recipeId, value: value)
            }.execute(db)
          }

          let instructions = item.instructions?.array as? [Instruction] ?? []
          for instruction in instructions {
            guard let value = instruction.value, !value.isEmpty else { continue }
            try InstructionTable.insert {
              InstructionTable(id: UUID(), recipeId: recipeId, value: value)
            }.execute(db)
          }

          // Migrate group -> tag
          if let group = item.group, let title = group.title, !title.isEmpty {
            let exists = try CategoryTagTable.find(title).fetchOne(db) != nil
            if !exists {
              try CategoryTagTable.insert {
                CategoryTagTable(id: title, color: group.color)
              }.execute(db)
            }
            try RecipeCategoryTagTable.insert {
              RecipeCategoryTagTable(id: UUID(), recipeId: recipeId, tagId: title)
            }.execute(db)
          }
        }
      }

      // Delete all Core Data records
      let groupFetch: NSFetchRequest<GroupItem> = GroupItem.fetchRequest()
      let groups = (try? context.fetch(groupFetch)) ?? []
      for group in groups {
        context.delete(group)
      }
      for item in coreDataRecipes {
        context.delete(item)
      }
      try context.save()

      Logger.log("Migrated \(coreDataRecipes.count) recipes from Core Data", category: .database)
    } catch {
      Logger.log("Core Data migration failed: \(error.localizedDescription)", category: .database)
    }

    UserDefaults.standard.hasMigratedCoreData = true
  }
}

//
//  RecipeDataService.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/18/25.
//

@preconcurrency import CoreData
import SwiftUI

struct RecipeDataService: CoreDataService {
    
    typealias Item = RecipeItem
    
    let viewContext: NSManagedObjectContext
    var save: @Sendable (Recipe) throws -> RecipeItem?
    var update: @Sendable (inout Recipe) throws -> Void
    var delete: @Sendable (Recipe) throws -> Void
    var deleteRecipes: @Sendable (IndexSet, FetchedResults<RecipeItem>) throws -> Void
    var findDuplicates: @Sendable (Recipe) throws -> RecipeItem?
    var addToGroup: @Sendable (Recipe, GroupItem) throws -> Void
    var getItem: @Sendable (NSManagedObjectID?) -> RecipeItem?
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.save = { recipe in
            try RecipeDataService.saveRecipe(recipe: recipe, viewContext: viewContext)
        }
        
        self.update = { recipe in
            guard let id = recipe.dataEntity else { return }
            viewContext.delete(viewContext.object(with: id))
            let entity = try RecipeDataService.saveRecipe(recipe: recipe, viewContext: viewContext)
            try viewContext.save()
            recipe.dataEntity = entity.objectID
        }
        
        self.delete = { recipe in
            if let id = recipe.dataEntity {
                viewContext.delete(viewContext.object(with: id))
                try viewContext.save()
            }
        }
        
        self.findDuplicates = { recipe in
            let request = try viewContext.fetch(NSFetchRequest(entityName: "RecipeItem"))
            guard let recipes = request as? [RecipeItem] else { print("casting fail"); throw URLError(.resourceUnavailable) }
            guard let url = recipe.url else { throw URLError(.badURL) }
            return recipes.first { $0.url == url }
        }
        
        self.addToGroup = { recipe, group in
            if let id = recipe.dataEntity, let data = viewContext.object(with: id) as? RecipeItem {
                group.addToRecipes(data)
                if let recipes = group.recipes?.array as? [RecipeItem] {
                    group.imgUrl = recipes.first(where: {$0.imageUrl != nil })?.imageUrl
                }
                try viewContext.save()
            }
        }
        
        self.deleteRecipes = { offset, list in
            offset.map { list[$0] }.forEach { viewContext.delete($0) }
            try viewContext.save()
        }
        
        self.getItem = { id in
            if let id {
                return viewContext.object(with: id) as? RecipeItem
            } else {
                return nil
            }
        }
    }
    
    private static func saveRecipe(recipe: Recipe, viewContext: NSManagedObjectContext) throws -> RecipeItem {
        let newRecipe = RecipeItem(context: viewContext)
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
            let i = Ingredient(context: viewContext)
            i.value = item
            newRecipe.addToIngredients(i)
        }
        recipe.instructions.forEach { item in
            let i = Instruction(context: viewContext)
            i.value = item
            newRecipe.addToInstructions(i)
        }
        
        try viewContext.save()
        return newRecipe
    }
}

//
//  ShoppingListDataService.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/19/25.
//

@preconcurrency import CoreData

struct ShoppingListDataService {
    
    typealias Item = ShoppingListItem
    
    let viewContext: NSManagedObjectContext
    
    var isInList: @Sendable (RecipeItem?) -> Bool
    var addToList: @Sendable (RecipeItem?) throws -> Void
    var removeRecipeFromList: @Sendable (RecipeItem?) throws -> Void
    var removeItemFromList: @Sendable (Item?) throws -> Void
    var createAndAdd: @Sendable (String?, Int16) throws -> Void
    var clear: @Sendable () throws -> Void
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        self.isInList = { recipe in
            !(recipe?.shoppinglistitems?.allObjects.isEmpty ?? true)
        }
        
        self.addToList = { recipe in
            guard let recipe else { return }
            if let ingredients = recipe.ingredients?.array as? [Ingredient] {
                for ingredient in ingredients {
                    if let text = ingredient.value {
                        let newItem = ShoppingListItem(context: viewContext)
                        newItem.recipe = recipe
                        newItem.value = text
                        recipe.addToShoppinglistitems(newItem)
                    }
                }
                try viewContext.save()
            }
        }
        
        self.removeRecipeFromList = { recipe in
            guard let recipe else { return }
            
            if let items = recipe.shoppinglistitems?.allObjects as? [ShoppingListItem] {
                for item in items {
                    viewContext.delete(item)
                }
            }
            recipe.shoppinglistitems = nil
            try viewContext.save()
        }
        
        self.removeItemFromList = { item in
            guard let item else { return }
            viewContext.delete(item)
            try viewContext.save()
        }
        
        self.createAndAdd = { text, index in
            let item = ShoppingListItem(context: viewContext)
            item.value = text
            item.index = index
            try viewContext.save()
        }
        
        self.clear = {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingListItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        }
    }
}

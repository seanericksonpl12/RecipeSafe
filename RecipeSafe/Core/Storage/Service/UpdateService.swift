//
//  UpdateService.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 2/20/25.
//

@preconcurrency import CoreData

struct UpdateService: Sendable, CoreDataService {
    typealias Item = RecipeItem
    let viewContext: NSManagedObjectContext
    
    var appUpdate: @Sendable () throws -> Void
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        self.appUpdate = {
            if UserDefaults.standard.bool(forKey: "v1.2Update") { return }
            UserDefaults.standard.set(true, forKey: "v1.2Update")
    
            let recipes: [RecipeItem] = try viewContext.fetchItems()
            if !recipes.isEmpty {
                recipes.forEach { recipe in
                    if let img = recipe.imageUrl {
                        var components = URLComponents(url: img, resolvingAgainstBaseURL: false)
                        components?.query = ""
                        recipe.imageUrl = components?.url ?? img
                    }
                }
            }
    
            let groups: [GroupItem] = try viewContext.fetchItems()
            if !groups.isEmpty {
               try groups.forEach { group in
                    if group.color == 0 { group.color = try GroupDataService.getNewColor(viewContext: viewContext) }
                    if group.imgUrl == nil {
                        if let recipes = group.recipes?.array as? [RecipeItem] {
                            group.imgUrl = recipes.first(where: { $0.imageUrl != nil })?.imageUrl
                        }
                    }
                }
            }
    
            if groups.isEmpty && recipes.isEmpty { return }
            try viewContext.save()
        }
    }
}

//
//  GroupViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import Foundation

@MainActor class GroupViewModel: ObservableObject {
    
    @Published var group: GroupItem
    @Published var addRecipeSwitch: Bool = false
    
    private var dataManager: DataManager = DataManager()
    
    var recipeList: [RecipeItem] {
        group.recipes?.array as? [RecipeItem] ?? []
    }
    
    init(group: GroupItem) {
        self.group = group
    }
}

extension GroupViewModel {
    
    func getRecipes() -> [RecipeItem] {
        dataManager.getRecipesOutsideGroup(for: self.group)
    }
}

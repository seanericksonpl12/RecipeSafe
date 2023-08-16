//
//  SelectGroupsViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/15/23.
//

import Foundation

@MainActor class SelectGroupsViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var editBinding: Bool = true
    @Published var notEditBinding: Bool = false
    @Published var newGroupSwitch: Bool = false
    @Published var newGroupText: String = ""
    @Published var selectedRecipes: [RecipeItem] = []
    
    // MARK: - Stored Properties
    var selectionAction: (GroupItem) -> Void
    var cancelAction: () -> Void
    var newRecipe: RecipeItem
    
    // MARK: - Private
    private var dataManager: DataManager
    
    // MARK: - Init
    init(selectionAction: @escaping (GroupItem) -> Void,
         cancelAction: @escaping () -> Void,
         dataManager: DataManager = DataManager(),
         newRecipe: RecipeItem) {
        
        self.dataManager = dataManager
        self.selectionAction = selectionAction
        self.cancelAction = cancelAction
        self.newRecipe = newRecipe
        self.selectedRecipes = [newRecipe]
    }
}

// MARK: - Functions
extension SelectGroupsViewModel {
    
    func addNewGroup() {
        self.newGroupSwitch.toggle()
    }
    
    func saveNewGroup() {
        dataManager.addGroup(title: newGroupText, recipes: selectedRecipes)
        newGroupSwitch = false
        let groups: [GroupItem] = dataManager.getItems(filter: { group in
            if let recipes = group.recipes?.array as? [RecipeItem] {
                return group.title == self.newGroupText && recipes == self.selectedRecipes
            }
            return false
        })
        newGroupText = ""
        
        guard let group = groups.first else { return }
        selectionAction(group)
    }
    
    func cancelNewGroup() {
        self.newGroupText = ""
        self.newGroupSwitch = false
    }
}

//
//  GroupModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/11/23.
//

import Foundation

struct GroupModel: Hashable {
    
    var recipes: [RecipeItem]
    var title: String
    var dataEntity: GroupItem
    
    init(dataEntity: GroupItem) {
        self.recipes = dataEntity.recipes?.array as? [RecipeItem] ?? []
        self.title = dataEntity.title ?? "group.default".localized
        self.dataEntity = dataEntity
    }
}

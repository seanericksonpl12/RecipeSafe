//
//  Recipe.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation

struct Recipe {
    var id: UUID = UUID()
    var title: String
    var ingredients: [String]
    var img: URL?
}

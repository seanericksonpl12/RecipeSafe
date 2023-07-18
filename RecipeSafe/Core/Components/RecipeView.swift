//
//  RecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import SwiftUI

struct RecipeView: View {
    
    @State var recipe: Recipe = Recipe(title: "", ingredients: [])
    
    var body: some View {
        Text(recipe.title)
            .onOpenURL { url in
                recipe.title = "passed!"
            }
        List(recipe.ingredients, id: \.self) { item in
            Text(item)
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView()
    }
}

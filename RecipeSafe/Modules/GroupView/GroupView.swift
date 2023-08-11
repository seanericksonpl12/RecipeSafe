//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupView: View {
    
    @StateObject var viewModel: GroupViewModel
    
    var body: some View {
        NavigationStack {
            Button {
                viewModel.addRecipeSwitch = true
            } label: { Image(systemName: "plus.circle") }
            List(viewModel.recipeList) { recipe in
                if let recipeModel = Recipe(dataItem: recipe) {
                    NavigationLink {
                        RecipeView(viewModel: RecipeViewModel(recipe: recipeModel))
                    } label: {
                        Text(recipe.title ?? "")
                    }
                }
            }
        }
        .popover(isPresented: $viewModel.addRecipeSwitch) {
            
                List(viewModel.getRecipes()) { recipe in
                    Text(recipe.title ?? "")
            }
        }
    }
}

//struct GroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupView()
//    }
//}

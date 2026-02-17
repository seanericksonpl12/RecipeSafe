//
//  SearchRecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 9/3/24.
//

import SwiftUI

struct SearchRecipeView: View {
    
    var recipe: Recipe
    
    var body: some View {
        HStack {
            if case let .downloaded(url) = recipe.img {
                AsyncImage(url: url) { img in
                    img.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 100, maxHeight: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.leading)
                } placeholder: {
                    LoadingView()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .padding(.leading)
                }
                Spacer()
            }
            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.title3)
                Text(recipe.description ?? "no desc")
                    .font(.callout)
            }
        }
        .frame(maxHeight: 110)
        .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -10))
    }
}

#Preview {
//    SearchRecipeView(recipe: Recipe(title: "Mexican Street Tacos", description: "Mexican Street Tacos - Easy, quick, authentic carne asada street tacos you can now make right at home! Top with onion, cilantro + fresh lime juice! SO GOOD!", ingredients: [], instructions: [], img: .downloaded(URL(string: "https://feelgoodfoodie.net/wp-content/uploads/2017/04/Ground-Beef-Tacos-9.jpg?")!), url: URL(string: "https://feelgoodfoodie.net/recipe/ground-beef-tacos-napa-cabbage-guacamole/"), prepTime: nil, cookTime: nil))
}

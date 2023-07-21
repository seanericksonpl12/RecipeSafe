//
//  RecipeView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/17/23.
//

import SwiftUI

struct RecipeView: View {
    
    @State var recipe: Recipe = Recipe(title: "", ingredients: [])
    
    // MARK: - Body
    var body: some View {
        
        customHeader
        
        List {
            
            Section {
                customDescriptionSection
            }
            
            Section {
                ForEach(recipe.ingredients, id: \.self) { item in
                    Text(item)
                        .font(.callout)
                }
            } header: {
                Text("Ingredients")
            }
            
            Section {
                ForEach(recipe.instructions ?? [String](), id: \.self) { item in
                    Text(item)
                        .font(.callout)
                }
            } header: {
                Text("Instructions")
            }
        }
        
        // MARK: - TESTING VALUES, DELETE ON JSON UPDATE
        .onAppear {
//            recipe.description = "Juicy, perfectly spiced shrimp are wrapped in warm flour tortillas and piled high with tasty toppings in this easy shrimp tacos recipe!"
//            recipe.img = URL(string: "https://therecipecritic.com/wp-content/uploads/2022/12/shrimp_tacos-1-750x1000.jpg")
//            recipe.instructions = ["Prep your shrimp. If frozen, run them under cool water until thawed. Peel them and remove the tails.&nbsp;",
//                                   "Meanwhile, prep your toppings.&nbsp;",
//                                   "Add the shrimp to a skillet along with the olive oil and spices. Cook over medium-high heat until the shrimp are pink, flipping/stirring them occasionally (about 5-6 minutes). ",
//                                   "Assemble tacos as desired and serve immediately.&nbsp;"]
        }
    }
    
    // MARK: - Header
    var customHeader: some View {
        HStack {
            Spacer()
            AsyncImage(url: recipe.img) { img in
                img.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 70, maxHeight: 70)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "circle.dotted")
                    .frame(maxWidth: 70, maxHeight: 70)
            }
            
            Text(recipe.title)
                .font(.title)
                .padding()
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("Open Menu")
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
    
    // MARK: - Description
    var customDescriptionSection: some View {
        VStack {
            Text(recipe.description ?? "")
                .multilineTextAlignment(.center)
                .font(.callout)
                .fontWeight(.light)
            Divider()
            HStack {
                Spacer()
                Text("Prep Time: 20 min")
                    .font(.footnote)
                Spacer()
                Text("Cook Time: 10 min")
                    .font(.footnote)
                Spacer()
            }
        }
    }
    
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(recipe: Recipe(title: "Shrimp Tacos", ingredients: ["Shrimp tails", "Cajon Seasoning", "Oil"]))
    }
}

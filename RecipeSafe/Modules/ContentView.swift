//
//  ContentView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var website: String = "https://therecipecritic.com/easy-shrimp-tacos/"
    @State var navPath: NavigationPath = NavigationPath()
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()

    @FetchRequest(
        sortDescriptors: [],
        animation: .default) private var recipeList: FetchedResults<RecipeItem>

    var body: some View {
        
       
        
        NavigationStack(path: $navPath) {
            Text(website)
                .onOpenURL { _ in
                    addItem()
                    NetworkManager.main.networkRequest(url: website).sink { status in
                        switch status {
                        case .finished:
                            break
                        case .failure(let error):
                            print(error)
                        }
                    } receiveValue: { recipe in
                        let newRecipe = Recipe(id: recipe?.id ?? UUID(), title: recipe?.title ?? "", ingredients: recipe?.ingredients ?? [])
                        navPath.append(newRecipe)
                    }
                    .store(in: &viewModel.subscriptions)
                }
                .navigationDestination(for: Recipe.self) { recipe in
                    RecipeView(recipe: recipe)
                }
                
            
            List {
                ForEach(recipeList, id: \.id) { item in
                    NavigationLink {
                        RecipeView(recipe: Recipe(dataItem: item))
                    } label: {
                        Text(item.title ?? "error")
                    }
                }
                .onDelete(perform: deleteItems)
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newRecipe = RecipeItem(context: viewContext)
            newRecipe.title = "new Recipe"
            newRecipe.id = UUID()
            let i1 = Ingredient(context: viewContext)
            let i2 = Ingredient(context: viewContext)
            let i3 = Ingredient(context: viewContext)
            
            i1.value = "test 1"
            i2.value = "test 2"
            i3.value = "test 3"
            
            newRecipe.ingredients = [i1, i2, i3]
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { recipeList[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

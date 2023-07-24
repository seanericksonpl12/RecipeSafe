//
//  ContentViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 7/13/23.
//

import Foundation
import SwiftUI
import CoreData
import Combine

extension ContentView {
    @MainActor class ContentViewModel: ObservableObject {
        
        // MARK: - Published
        @Published var navPath: NavigationPath = .init()
        @Published var popup: Bool = false
        @Published var displayBadSite: Bool = false
        @Published var viewState: ViewState = .started
        
        // MARK: - Properties
        private var subscriptions = Set<AnyCancellable>()
        
        // MARK: - URL Handling
        func onURLOpen(url: String) {
            self.viewState = .loading
            self.navPath = .init()
            NetworkManager.main.networkRequest(url: url).sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .finished:
                    break
                case .failure(let error):
                    self.displayBadSite = true
                    self.viewState = .failedToLoad
                    print(error)
                }
            } receiveValue: { [weak self] recipe in
                // TODO: - Error Handling
                guard let self = self else { return }
                self.viewState = .successfullyLoaded
                guard var newRecipe = recipe else {
                    displayBadSite = true
                    return
                }
                DispatchQueue.main.async { newRecipe.dataEntity = self.saveItem(newRecipe) }
                self.navPath.append(newRecipe)
            }
            .store(in: &subscriptions)
        }
        
        
        // MARK: - Core Data Functions
        func addItem(context: NSManagedObjectContext) {
            popup.toggle()
            withAnimation {
                let newRecipe = RecipeItem(context: context)
                newRecipe.title = "new Recipe"
                newRecipe.id = UUID()
                newRecipe.cookTime = "20 min"
                newRecipe.prepTime = "1 hour"
                newRecipe.desc = "some description"
                
                let i1 = Ingredient(context: context)
                let i2 = Ingredient(context: context)
                let i3 = Ingredient(context: context)
                
                let in1 = Instruction(context: context)
                let in2 = Instruction(context: context)
                let in3 = Instruction(context: context)
                
                i1.value = "test 1"
                i2.value = "test 2"
                i3.value = "test 3"
                
                in1.value = "instruction 1"
                in2.value = "instruction 2"
                in3.value = "instruction 3"
                
                newRecipe.ingredients = [i1, i2, i3]
                newRecipe.instructions = [in1, in2, in3]
                
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        func deleteItem(offset: IndexSet,
                        list: FetchedResults<RecipeItem>,
                        context: NSManagedObjectContext) {
            offset
                .map { list[$0] }
                .forEach { context.delete($0) }
            do {
                try context.save()
            } catch {
                print("viewContext error.")
            }
        }
        
        
        private func saveItem(_ recipe: Recipe) -> RecipeItem? {
            withAnimation {
                return PersistenceController.shared.saveItem(recipe: recipe)
            }
        }
    }
}

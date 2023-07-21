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
        
        // MARK: - Properties
        private var subscriptions = Set<AnyCancellable>()
        
        // MARK: - URL Handling
        func onURLOpen(url: String) {
            self.navPath = .init()
            NetworkManager.main.networkRequest(url: url).sink { status in
                switch status {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] recipe in
                // TODO: - Error Handling
                guard let self = self else { return }
                guard let newRecipe = recipe else { return }
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
                let i1 = Ingredient(context: context)
                let i2 = Ingredient(context: context)
                let i3 = Ingredient(context: context)
                
                i1.value = "test 1"
                i2.value = "test 2"
                i3.value = "test 3"
                
                newRecipe.ingredients = [i1, i2, i3]
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        
        func deleteItems(context: NSManagedObjectContext, list: FetchedResults<RecipeItem>, offsets: IndexSet) {
            withAnimation(.spring()) {
                offsets.map { list[$0] }.forEach(context.delete)
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}

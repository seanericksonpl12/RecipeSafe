//
//  ShoppingListViewModel.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 10/2/24.
//

import Foundation
import Combine
import SwiftUI

//class ShoppingListViewModel: ObservableObject {
//    
//  //  @Service var dataManager: DataManager?
//    @Published var groceries: [ShoppingListItem]
//
//   private var shoppinglist: ShoppingList
//
//    var cancellable: AnyCancellable?
//    
//    init() {
//        print("initializing viewmodel")
//        // self.shoppinglist = UserDefaults.standard.currentShoppingList
//        self.groceries = shoppinglist.allItems
//        self.cancellable = NotificationCenter.default.publisher(for: .shoppingListUpdated).sink {
//            print("received noti: \($0.object)")
//        }
//       // print("groceries: \(groceries)")
//    }
//    
//    deinit {
//        print("deinit")
//    }
//}

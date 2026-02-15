////
////  GroupDataService.swift
////  RecipeSafe
////
////  Created by Sean Erickson on 2/18/25.
////
//
//@preconcurrency import CoreData
//
//struct GroupDataService: CoreDataService {
//    
//    typealias GroupParams = (title: String, recipes: [RecipeItem], color: Int16?)
//    typealias Item = GroupItem
//    
//    let viewContext: NSManagedObjectContext
//    var create: @Sendable (GroupParams) throws -> Void
//    var update: @Sendable (GroupModel) throws -> Void
//    var getNewColor: @Sendable () throws -> Int16
//    
//    init(viewContext: NSManagedObjectContext) {
//        self.viewContext = viewContext
//        self.create = { params in
//            let group = GroupItem(context: viewContext)
//            group.title = params.title
//            group.imgUrl = params.recipes.first(where: { $0.imageUrl != nil })?.imageUrl
//            if let color = params.color {
//                group.color = color
//            } else { group.color = try GroupDataService.getNewColor(viewContext: viewContext) }
//            params.recipes.forEach { group.addToRecipes($0) }
//
//            try viewContext.save()
//        }
//        
//        self.update = { group in
//            group.dataEntity.title = group.title
//            group.dataEntity.recipes = []
//            group.dataEntity.imgUrl = group.imgUrl
//            if group.dataEntity.color == 0 {
//                group.dataEntity.color = try GroupDataService.getNewColor(viewContext: viewContext)
//            }
//            group.recipes.forEach { group.dataEntity.addToRecipes($0) }
//
//            try viewContext.save()
//        }
//        
//        self.getNewColor = { @Sendable in
//            try GroupDataService.getNewColor(viewContext: viewContext)
//        }
//    }
//}
//
//extension GroupDataService {
//    
//    static func getNewColor(viewContext: NSManagedObjectContext) throws -> Int16 {
//        let groups: [GroupItem] = try viewContext.fetchItems()
//        var colors: [Int16 : Bool] = [1:false,2:false,3:false,4:false,5:false,6:false]
//        groups.forEach {
//            if $0.imgUrl == nil {
//                colors[$0.color] = true
//            }
//        }
//        if let newColor = colors.first(where: { $0.value == false })?.key {
//            return newColor
//        } else { return Int16.random(in: 1..<7) }
//    }
//}

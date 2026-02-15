@preconcurrency import CoreData
import Dependencies

struct CoreDataService: Sendable {

  private var viewContext: NSManagedObjectContext
  
  init(viewContext: NSManagedObjectContext) {
    self.viewContext = viewContext
  }
  
  func save() throws { try viewContext.save() }
  
  func fetchAll<T: NSManagedObject>(_ type: T.Type = T.self) throws -> [T] {
    let request = try viewContext.fetch(NSFetchRequest(entityName: T.description()))
    guard let items = request as? [T] else { print("casting fail"); throw URLError(.resourceUnavailable) }
    return items
  }
  
  func fetch(id: NSManagedObjectID) -> NSManagedObject {
    viewContext.object(with: id)
  }
  
  func delete(_ item: NSManagedObject) throws {
    viewContext.delete(item)
    try save()
  }
  
  func delete(id: NSManagedObjectID) throws {
    try delete(fetch(id: id))
  }
  
  func create<T: NSManagedObject>(_ type: T.Type = T.self) -> T? {
    switch T.self {
    case is RecipeItem.Type: RecipeItem(context: viewContext) as? T
    case is Ingredient.Type: Ingredient(context: viewContext) as? T
    case is Instruction.Type: Instruction(context: viewContext) as? T
    case is GroupItem.Type: GroupItem(context: viewContext) as? T
    case is ShoppingListItem.Type: ShoppingListItem(context: viewContext) as? T
    default: nil
    }
  }
  
  func createAndAdd(_ text: String?, _ index: Int16) throws {
    let item = ShoppingListItem(context: viewContext)
    item.value = text
    item.index = index
    try save()
  }
  
  func clear() throws {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ShoppingListItem")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    try viewContext.execute(deleteRequest)
    try save()
  }
}

extension CoreDataService: DependencyKey {
  static let liveValue = CoreDataService(
    viewContext: PersistenceController.shared.container.viewContext
  )
  static let testValue = CoreDataService(
    viewContext: PersistenceController(inMemory: true).container.viewContext
  )
}

extension DependencyValues {
  var coreDataService: CoreDataService {
    get { self[CoreDataService.self] }
    set { self[CoreDataService.self] = newValue }
  }
}

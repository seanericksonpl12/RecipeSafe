import CoreData

protocol DataModel: Equatable, Sendable {
  init?(id: NSManagedObjectID)
  var id: NSManagedObjectID { get }
}

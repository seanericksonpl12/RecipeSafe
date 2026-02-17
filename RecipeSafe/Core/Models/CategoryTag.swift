import Foundation

struct CategoryTag: Hashable, Identifiable, Sendable {
  var id: String { label }
  let label: String
  let color: Int16
}

extension CategoryTag {
  static let defaultTags: [CategoryTag] = [
    .init(label: "American", color: 0),
    .init(label: "Asian", color: 1),
    .init(label: "Indian", color: 2),
    .init(label: "Italian", color: 3),
    .init(label: "Chicken", color: 4),
    .init(label: "Breakfast", color: 5),
    .init(label: "Lunch", color: 6),
  ]
}

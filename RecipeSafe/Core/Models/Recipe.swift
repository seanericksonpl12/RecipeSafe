import Foundation

struct Recipe: Hashable, Identifiable, Sendable {
  let id: UUID
  var title: String
  var description: String
  var ingredients: [IdentifiedString]
  var instructions: [IdentifiedString]
  var imageUrl: URL?
  var imageData: Data?
  var url: URL?
  var prepTime: String
  var cookTime: String
  var tags: [CategoryTag]
  
  var isFavorite: Bool
  var dateAdded: Date
  var viewCount: Int

  init(
    id: UUID = UUID(),
    title: String = "",
    description: String = "",
    ingredients: [IdentifiedString] = [],
    instructions: [IdentifiedString] = [],
    imageUrl: URL? = nil,
    imageData: Data? = nil,
    url: URL? = nil,
    prepTime: String = "",
    cookTime: String = "",
    tags: [CategoryTag] = [],
    isFavorite: Bool = false,
    dateAdded: Date = Date(),
    viewCount: Int = 0
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.ingredients = ingredients
    self.instructions = instructions
    self.imageUrl = imageUrl
    self.imageData = imageData
    self.url = url
    self.prepTime = prepTime
    self.cookTime = cookTime
    self.tags = tags
    self.isFavorite = isFavorite
    self.dateAdded = dateAdded
    self.viewCount = viewCount
  }
}

extension Recipe {
  var img: ImageData {
    return if let imageData {
      .selected(imageData)
    } else if let imageUrl {
      .downloaded(imageUrl)
    } else {
      .none
    }
  }
}

struct IdentifiedString: Hashable, Identifiable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
  let id: UUID
  var value: String

  init(id: UUID = UUID(), value: String) {
      self.id = id
      self.value = value
  }

  init(stringLiteral value: String) {
      self.id = UUID()
      self.value = value
  }

  var description: String { value }
}

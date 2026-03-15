import Foundation

enum GroceryCategory: String, CaseIterable, Identifiable, Sendable, Hashable {
  case produce
  case dairy
  case meat
  case seafood
  case bakery
  case frozen
  case pantry
  case spices
  case condiments
  case beverages
  case other

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .produce: "Produce"
    case .dairy: "Dairy"
    case .meat: "Meat & Poultry"
    case .seafood: "Seafood"
    case .bakery: "Bakery & Bread"
    case .frozen: "Frozen"
    case .pantry: "Pantry"
    case .spices: "Spices & Seasonings"
    case .condiments: "Condiments & Sauces"
    case .beverages: "Beverages"
    case .other: "Other"
    }
  }

  var iconName: String {
    switch self {
    case .produce: "leaf"
    case .dairy: "cup.and.saucer"
    case .meat: "fork.knife"
    case .seafood: "fish"
    case .bakery: "birthday.cake"
    case .frozen: "snowflake"
    case .pantry: "cabinet"
    case .spices: "flame"
    case .condiments: "drop"
    case .beverages: "mug"
    case .other: "basket"
    }
  }
}

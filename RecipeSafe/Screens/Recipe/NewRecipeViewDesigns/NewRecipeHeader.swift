import SwiftUI

struct NewRecipeHeader: View {
  let recipe: Recipe

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(recipe.title)
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(Color.Text.primary)
      
      HStack(spacing: 12) {
        if !recipe.prepTime.isEmpty {
          timeCard(value: recipe.prepTime, label: "Prep", icon: "clock")
        }
        if !recipe.cookTime.isEmpty {
          timeCard(value: recipe.cookTime, label: "Cook", icon: "flame")
        }
        timeCard(value: "\(recipe.ingredients.count)", label: "Ingredients", icon: "list.bullet")
      }
      .padding(.bottom, 4)
      
      // Category tags
      if !recipe.tags.isEmpty {
        HStack(spacing: 8) {
          ForEach(recipe.tags) { tag in
            Text(tag.label)
              .font(.caption)
              .fontWeight(.medium)
              .padding(.horizontal, 10)
              .padding(.vertical, 4)
              .background(ColorSet.color(tag.color).opacity(0.5), in: Capsule())
          }
        }
      }
      
      if !recipe.description.isEmpty {
        Text(recipe.description)
          .font(.subheadline)
          .foregroundStyle(Color.Text.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func timeCard(value: String, label: String, icon: String) -> some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .font(.caption)
        .foregroundStyle(Color.Icon.default)
      Text(label)
        .font(.caption2)
        .foregroundStyle(Color.Text.secondary)
      Text(value)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(Color.Text.primary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 10)
    .background(Color.Card.background, in: RoundedRectangle(cornerRadius: 10))
  }
}

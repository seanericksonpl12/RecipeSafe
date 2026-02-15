import ComposableArchitecture
import SwiftUI

extension AlertState where Action == RecipeAction.AlertAction {
  static func deleteRecipe() -> Self {
    AlertState {
      TextState("recipe.alert.delete.title".localized)
    } actions: {
      ButtonState(role: .destructive, action: .deleteRecipeOk, label: { TextState("button.delete".localized) })
      ButtonState(role: .cancel, action: .deleteRecipeCancel, label: { TextState("button.cancel".localized) })
    } message: {
      TextState("recipe.alert.delete.desc".localized)
    }
  }
}

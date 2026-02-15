import ComposableArchitecture
import SwiftUI

extension AlertState where Action == ContentAction.AlertAction {
  static func failedToBuildRecipe() -> Self {
    AlertState {
      TextState("content.alert.fail.title".localized)
    } actions: {
      ButtonState(action: .recipeFailedOk, label: { TextState("button.ok".localized) })
    } message: {
      TextState("content.alert.fail.desc".localized)
    }
  }

  static func duplicateRecipeFound(new: Recipe, duplicate: Recipe) -> Self {
    AlertState {
      TextState("content.alert.fail.title".localized)
    } actions: {
      ButtonState(action: .duplicateOverwrite(new: new, duplicate: duplicate), label: { TextState("button.overwrite".localized) })
      ButtonState(action: .duplicateSaveCopy(new), label: { TextState("button.savecopy".localized) })
      ButtonState(role: .cancel, action: .duplicateCancel, label: { TextState("button.cancel".localized) })
    } message: {
      TextState("content.alert.copy.desc".localized)
    }
  }
}

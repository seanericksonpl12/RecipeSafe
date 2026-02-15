import SwiftUI

private struct ModalToolbarModifier<TrailingContent: View>: ViewModifier {
  let dismiss: () -> Void
  let trailingContent: () -> TrailingContent
  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          CloseButton(action: dismiss)
        }
        ToolbarItem(placement: .topBarTrailing, content: trailingContent)
      }
  }
}

extension View {
  func modalToolbar(
    dismiss: @escaping () -> Void,
    @ViewBuilder trailingContent: @escaping () -> some View = { EmptyView() }
  ) -> some View {
    self.modifier(ModalToolbarModifier(dismiss: dismiss, trailingContent: trailingContent))
  }
}

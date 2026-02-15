import SwiftUI

private struct ModalCoverModifier<Item: Identifiable, ModalContent: View, TrailingContent: View>: ViewModifier {
  @Binding var item: Item?
  let onDismiss: () -> Void
  let trailingContent: () -> TrailingContent
  let modalContent: (Item) -> ModalContent
  
  func body(content: Content) -> some View {
    content
      .fullScreenCover(item: $item) { item in
        NavigationStack {
          modalContent(item)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .topBarLeading) {
                CloseButton(action: onDismiss)
              }
            }
        }
      }
  }
}

extension View {
  func modalCover<Item: Identifiable>(
    item: Binding<Item?>,
    onDismiss: @escaping () -> Void,
    @ViewBuilder trailingContent: @escaping () -> some View = { EmptyView() },
    @ViewBuilder content: @escaping (Item) -> some View
  ) -> some View {
    self.modifier(
      ModalCoverModifier(
        item: item,
        onDismiss: onDismiss,
        trailingContent: trailingContent,
        modalContent: content
      )
    )
  }
}

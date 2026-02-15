import SwiftUI

private struct RootToolbarModifier<TrailingContent: View>: ViewModifier {
  let title: String
  let trailingItem: () -> TrailingContent
  func body(content: Content) -> some View {
    content
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Text(title)
          .font(.largeTitle)
          .fontWeight(.heavy)
          .fixedSize(horizontal: true, vertical: false)
          .padding(.top)
      }
      .removeLiquidGlassEffect()

      ToolbarItem(placement: .title) {
        Color.clear
      }
      ToolbarItem(placement: .topBarTrailing) {
        trailingItem()
      }
    }
  }
}

extension View {
  func rootToolbar(
    title: String, @ViewBuilder
    trailingContent: @escaping () -> some View
  ) -> some View {
    self.modifier(RootToolbarModifier(title: title, trailingItem: trailingContent))
  }
}

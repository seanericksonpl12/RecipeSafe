import SwiftUI

struct CloseButton: View {
  let action: () -> Void
  var body: some View {
    Button(action: action) {
      Image(systemName: "xmark")
    }
  }
}

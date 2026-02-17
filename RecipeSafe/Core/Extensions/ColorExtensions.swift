import SwiftUI

extension Color {

  // MARK: - Text
  enum Text {
    static let primary = Color("TextPrimary")
    static let secondary = Color("TextSecondary")
    static let tertiary = Color("TextTertiary")
  }

  // MARK: - Icon
  enum Icon {
    static let `default` = Color("IconDefault")
  }

  // MARK: - Surface
  enum Surface {
    static let primary = Color("SurfacePrimary")
    static let secondary = Color("SurfaceSecondary")
  }

  // MARK: - Card
  enum Card {
    static let background = Color("CardBackground")
    static let backgroundSecondary = Color("CardBackgroundSecondary")
  }

  // MARK: - Border
  enum Border {
    static let separator = Color("Separator")
  }

  // MARK: - Tag
  enum Tag {
    static let terracotta = Color("TagTerracotta")
    static let amber = Color("TagAmber")
    static let copper = Color("TagCopper")
    static let sage = Color("TagSage")
    static let gold = Color("TagGold")
    static let steel = Color("TagSteel")
    static let slate = Color("TagSlate")
  }
}

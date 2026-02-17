import ComposableArchitecture
import SwiftUI

struct SelectCategoriesView: View {
  @Bindable var store: StoreOf<SelectCategoriesReducer>
  
  var body: some View {
    NavigationStack {
      ScrollView {
        HStack {
          VStack(alignment: .leading, spacing: 20) {
            // MARK: Selected Tags
            if !store.selectedTags.isEmpty {
              VStack(alignment: .leading, spacing: 10) {
                Text("Selected")
                  .font(.caption)
                  .fontWeight(.semibold)
                  .foregroundStyle(.secondary)
                  .textCase(.uppercase)
                
                FlowLayout(spacing: 8) {
                  ForEach(store.selectedTags) { tag in
                    selectedTagChip(tag)
                  }
                }
              }
            }
            
            // MARK: All / Filtered Tags
            VStack(alignment: .leading, spacing: 10) {
              Text(store.searchQuery.isEmpty ? "All Tags" : "Results")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
              
              if store.filteredTags.isEmpty && !store.searchQuery.isEmpty {
                // No results — offer to create
                VStack(spacing: 10) {
                  Text("No tags match \"\(store.searchQuery)\"")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                  
                  createTagButton
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
              } else {
                FlowLayout(spacing: 8) {
                  ForEach(store.filteredTags) { tag in
                    unselectedTagChip(tag)
                  }
                }
              }
            }
            
            // MARK: New Tag (when not searching)
            if store.searchQuery.isEmpty {
              createTagButton
            }
          }
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
      }
      .scrollBounceBehavior(.basedOnSize)
      .searchable(
        text: $store.searchQuery.sending(\.searchQueryChanged),
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Search tags"
      )
      .navigationTitle("Tags")
      .navigationBarTitleDisplayMode(.inline)
      .animation(.easeInOut, value: store.filteredTags)
      .alert("New Tag", isPresented: $store.showNewTagAlert.sending(\.toggleNewTagAlert)) {
        TextField("Tag name", text: $store.newTagName.sending(\.newTagNameChanged))
        Button("Add") { store.send(.confirmNewTag) }
        Button("Cancel", role: .cancel) { }
      } message: {
        Text("Enter a name for the new tag.")
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            store.send(.cancelTapped)
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            store.send(.doneTapped)
          }
          .fontWeight(.semibold)
        }
      }
    }
  }
}

// MARK: - Tag Chips
private extension SelectCategoriesView {
  func selectedTagChip(_ tag: CategoryTag) -> some View {
    let tagColor = tag.swiftUIColor
    return Button {
      store.send(.removeTag(tag))
    } label: {
      HStack(spacing: 6) {
        Text(tag.label)
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundStyle(tagColor)
        Image(systemName: "xmark")
          .font(.caption2)
          .fontWeight(.bold)
          .foregroundStyle(.white)
          .frame(width: 18, height: 18)
          .background(tagColor, in: Circle())
      }
      .padding(.leading, 14)
      .padding(.trailing, 12)
      .padding(.vertical, 7)
      .background(tagColor.opacity(0.1), in: Capsule())
      .overlay(Capsule().strokeBorder(tagColor, lineWidth: 1.5))
      .contextMenu {
        Button("Delete", systemImage: "trash", role: .destructive) {
          store.send(.deleteTag(tag))
        }
      }
    }
  }
  
  func unselectedTagChip(_ tag: CategoryTag) -> some View {
    Button {
      store.send(.toggleTag(tag))
    } label: {
      Text(tag.label)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.secondary.opacity(0.2), lineWidth: 1.5))
        .contextMenu {
          Button("Delete", systemImage: "trash", role: .destructive) {
            store.send(.deleteTag(tag))
          }
        }
    }
  }
  
  var createTagButton: some View {
    Button {
      store.send(.createTag)
    } label: {
      HStack(spacing: 6) {
        Image(systemName: "plus")
          .font(.caption)
          .fontWeight(.bold)
        Text(store.searchQuery.isEmpty ? "New Tag" : "Create \"\(store.searchQuery)\"")
          .font(.subheadline)
          .fontWeight(.medium)
      }
      //      .foregroundStyle(.accent)
      .padding(.horizontal, 14)
      .padding(.vertical, 7)
      .background(Color.accentColor.opacity(0.04), in: Capsule())
      .overlay(Capsule().strokeBorder(Color.accentColor.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])))
    }
    .disabled(!store.canCreateTag)
  }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
  var spacing: CGFloat = 8
  
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let result = layout(subviews: subviews, containerWidth: proposal.width ?? .infinity)
    return result.size
  }
  
  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let result = layout(subviews: subviews, containerWidth: bounds.width)
    for (index, position) in result.positions.enumerated() {
      subviews[index].place(
        at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
        proposal: .unspecified
      )
    }
  }
  
  private func layout(subviews: Subviews, containerWidth: CGFloat) -> (size: CGSize, positions: [CGPoint]) {
    var positions: [CGPoint] = []
    var x: CGFloat = 0
    var y: CGFloat = 0
    var rowHeight: CGFloat = 0
    var maxWidth: CGFloat = 0
    
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if x + size.width > containerWidth && x > 0 {
        x = 0
        y += rowHeight + spacing
        rowHeight = 0
      }
      positions.append(CGPoint(x: x, y: y))
      rowHeight = max(rowHeight, size.height)
      x += size.width + spacing
      maxWidth = max(maxWidth, x - spacing)
    }
    
    return (CGSize(width: maxWidth, height: y + rowHeight), positions)
  }
}

// MARK: - CategoryTag Color
extension CategoryTag {
  var swiftUIColor: Color {
    switch color {
    case 0: Color("TagTerracotta")  // American / Italian
    case 1: Color("TagAmber")       // Asian
    case 2: Color("TagCopper")      // Indian
    case 3: Color("TagTerracotta")  // Italian (same palette)
    case 4: Color("TagSage")        // Chicken
    case 5: Color("TagGold")        // Breakfast
    case 6: Color("TagSteel")       // Lunch
    default: Color("TagSlate")
    }
  }
}

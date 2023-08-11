//
//  GroupView.swift
//  RecipeSafe
//
//  Created by Sean Erickson on 8/10/23.
//

import SwiftUI

struct GroupGridView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .easeIn) private var groups: FetchedResults<GroupItem>
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    Button("add group") {
                        let group = GroupItem(context: self.viewContext)
                        group.title = "title"
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: (geo.size.width / 3)))]) {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.blue, lineWidth: 4)
                            .frame(width: (geo.size.width / 3), height: (geo.size.width / 3))
                            .overlay {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                            .padding()
                            .onTapGesture {
                                let group = GroupItem(context: self.viewContext)
                                group.title = "title"
                                try? self.viewContext.save()
                            }
                        ForEach(Array(groups.enumerated()), id: \.offset) { index, item in
                            NavigationLink {
                                GroupView(viewModel: GroupViewModel(group: item))
                                    .navigationTitle(item.title ?? "")
                            } label: {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.blue, lineWidth: 4)
                                    .frame(width: (geo.size.width / 3), height: (geo.size.width / 3))
                                    .overlay {
                                        Text(item.title ?? "" )
                                    }
                                    .padding()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GroupGridView_Previews: PreviewProvider {
    static var previews: some View {
        GroupGridView()
    }
}

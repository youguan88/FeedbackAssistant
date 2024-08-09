//
//  UserFilterRow.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 23/7/24.
//

import SwiftUI

struct UserFilterRow: View {
    @EnvironmentObject var dataController: DataController

    var filter: Filter
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.tag?.name ?? "No name", systemImage: filter.icon)
                .badge("\(filter.tag?.tagActiveIssues.count ?? 0) issues")
                .contextMenu(ContextMenu(menuItems: {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }))
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, rename: {_ in}, delete: {_ in})
}

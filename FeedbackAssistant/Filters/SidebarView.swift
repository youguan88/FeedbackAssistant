//
//  SidebarView.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 18/7/24.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel: ViewModel
    let smartFilters: [Filter] = [.all, .recent]
    @State private var showingAwards = false

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter, content: {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    SmartFilterRow(filter: filter)
                }
            }
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: viewModel.rename, delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete)
            }
        })
        .toolbar(content: {
            SidebarViewToolbar(showingAwards: $showingAwards)
        })
        .alert("Rename tag", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) {}
            TextField("New name", text: $viewModel.tagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        .navigationTitle("Filters")
    }
}

#Preview {
    SidebarView(dataController: .preview)
}

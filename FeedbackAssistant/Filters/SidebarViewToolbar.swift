//
//  SidebarViewToolbar.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 23/7/24.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @Binding var showingAwards: Bool
    @State private var showingStore = false

    var body: some View {
        Button(action: tryNewTag, label: {
            Label("Add tag", systemImage: "plus")
        })
        .sheet(isPresented: $showingStore, content: {
            StoreView()
        })

        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }

        #if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
        #endif
    }

    func tryNewTag() {
        if dataController.newTag() == false {
            showingStore = true
        }
    }
}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
        .environmentObject(DataController.preview)
}

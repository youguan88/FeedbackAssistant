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
    
    var body: some View {
        Button(action: dataController.newTag, label: {
            Label("Add tag", systemImage: "plus")
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
}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
        .environmentObject(DataController.preview)
}

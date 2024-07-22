//
//  NoIssueView.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 19/7/24.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue", action: dataController.newIssue)
    }
}

#Preview {
    NoIssueView()
        .environmentObject(DataController.preview)
}

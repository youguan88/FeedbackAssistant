//
//  ContentView.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 17/7/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, prompt: "Filter Issues, or type # to add tags") { token in
            Text(token.tagName)
        }
        .searchSuggestions {
            ForEach(dataController.suggestedFilterTokens) { suggestedToken in
                Button {
                    dataController.filterTokens.append(suggestedToken)
                    dataController.filterText = ""
                } label: {
                    Text(suggestedToken.tagName)
                }
            }
        }
        .toolbar(content: {
            ContentViewToolbar()
        })
    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()
        
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
    
}

#Preview {
    ContentView()
        .environmentObject(DataController.preview)
}

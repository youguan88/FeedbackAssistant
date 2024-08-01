//
//  ContentView.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 17/7/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @StateObject var viewModel: ViewModel

    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $viewModel.filterText,
                    tokens: $viewModel.filterTokens,
                    prompt: "Filter Issues, or type # to add tags") { token in
            Text(token.tagName)
        }
        .searchSuggestions {
            ForEach(viewModel.suggestedFilterTokens) { suggestedToken in
                Button {
                    viewModel.filterTokens.append(suggestedToken)
                    viewModel.filterText = ""
                } label: {
                    Text(suggestedToken.tagName)
                }
            }
        }
        .toolbar(content: {
            ContentViewToolbar()
        })
        .onAppear(perform: {
            askForReview()
        })
    }


    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
}

#Preview {
    ContentView(dataController: .preview)
}

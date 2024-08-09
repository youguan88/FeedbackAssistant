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

    private let newIssueActivity = "me.eng.yg.FeedbackAssistant.newIssue"

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
        .onOpenURL(perform: { url in
            viewModel.openURL(url)
        })
        .userActivity(newIssueActivity, { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Issue"
        })
        .onContinueUserActivity(newIssueActivity, perform: { userActivity in
            resumeActivity(userActivity)
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

    func resumeActivity(_ userActivity: NSUserActivity) {
        viewModel.dataController.newIssue()
    }
}

#Preview {
    ContentView(dataController: .preview)
}

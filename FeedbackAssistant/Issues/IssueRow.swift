//
//  IssueRow.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 18/7/24.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    @StateObject var viewModel : ViewModel

    var body: some View {
        NavigationLink(value: viewModel.issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(viewModel.iconIdentifier)
                VStack(alignment: .leading, content: {
                    Text(viewModel.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(viewModel.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                })

                Spacer()

                VStack(alignment: .trailing, content: {
                    Text(viewModel.createdDate)
                        .font(.subheadline)
                    if viewModel.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                })
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier(viewModel.issueTitle)
    }

    init(issue: Issue) {
        let viewModel = ViewModel(issue: issue)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    IssueRow(issue: .example)
}

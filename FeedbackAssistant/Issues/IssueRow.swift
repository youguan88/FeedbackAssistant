//
//  IssueRow.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 18/7/24.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue

    var body: some View {
        NavigationLink(value: issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                    .accessibilityIdentifier(issue.priority == 2 ? "\(issue.issueTitle) High Priority" : "")

                VStack(alignment: .leading, content: {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                })

                Spacer()

                VStack(alignment: .trailing, content: {
                    Text(issue.issueCreatedDateFormatted)
                        .font(.subheadline)

                    if issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                })
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier(issue.issueTitle)
    }
}

#Preview {
    IssueRow(issue: .example)
}

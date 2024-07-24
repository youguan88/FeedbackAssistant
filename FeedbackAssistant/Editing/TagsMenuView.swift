//
//  TagsMenuView.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 23/7/24.
//

import SwiftUI

struct TagsMenuView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue

    var body: some View {
        Menu {
            ForEach(issue.issueTags) { tag in
                Button {
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }

            let otherTags = dataController.missingTags(from: issue)
            if otherTags.isEmpty == false {
                Divider()
                Section("Add Tags") {
                    ForEach(otherTags) { tag in
                        Button(tag.tagName) {
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.issueTagsList)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    TagsMenuView(issue: Issue.example)
        .environmentObject(DataController.preview)
}

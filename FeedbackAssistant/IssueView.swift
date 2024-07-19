//
//  IssueView.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 19/7/24.
//

import SwiftUI

struct IssueView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, content: {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                })
                Text("**Modified:** \(issue.issueModifiedDate.formatted(date: .long, time: .shortened))")
                    .foregroundStyle(.secondary)
                
                Text("**Status:** \(issue.issueStatus)")
                    .foregroundStyle(.secondary)
                
            }
            Picker("Priority", selection: $issue.priority) {
                Text("Low").tag(Int16(0))
                Text("Medium").tag(Int16(1))
                Text("High").tag(Int16(2))
            }
            
            Menu {
                ForEach(issue.issueTags) { tag in
                    Button{
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
            
            Section {
                VStack(alignment: .leading, content: {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    TextField("Description", text: $issue.issueContent, prompt: Text("Enter the issue description here"), axis: .vertical)
                })
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
    }
}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataController.preview)
}

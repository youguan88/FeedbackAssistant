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

    @State private var showingNotificationsError = false
    @Environment(\.openURL) var openURL

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

                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                TagsMenuView(issue: issue)
            }
            Section {
                VStack(alignment: .leading, content: {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    TextField("Description",
                              text: $issue.issueContent,
                              prompt: Text("Enter the issue description here"),
                              axis: .vertical)
                })
            }
            Section("Reminders") {
                Toggle("Show reminders", isOn: $issue.reminderEnabled.animation())
                if issue.reminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $issue.issueReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar(content: {
            IssueViewToolbar(issue: issue)
        })
        .alert("Oops!", isPresented: $showingNotificationsError, actions: {
            Button("Check Settings", action: showAppSetting)
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        })
        .onChange(of: issue.reminderEnabled) {
            updateReminder()
        }
        .onChange(of: issue.reminderTime) {
            updateReminder()
        }
    }

    func showAppSetting() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }
        openURL(settingsURL)
    }

    func updateReminder() {
        dataController.removeReminder(for: issue)

        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)
                if success == false {
                    issue.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataController.preview)
}

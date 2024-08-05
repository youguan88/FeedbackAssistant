//
//  FeedbackAssistantWidget.swift
//  FeedbackAssistantWidget
//
//  Created by Eng You Guan on 1/8/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: .now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 1)
        return dataController.results(for: request)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct FeedbackAssistantWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Up next...")
                .font(.title)
            if let issue = entry.issues.first {
                Text(issue.issueTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

struct FeedbackAssistantWidget: Widget {
    let kind: String = "FeedbackAssistantWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                FeedbackAssistantWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                FeedbackAssistantWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next...")
        .description("Your #1 top-priority issue.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    FeedbackAssistantWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}

//
//  FeedbackAssistantWidget.swift
//  FeedbackAssistantWidget
//
//  Created by Eng You Guan on 1/8/24.
//

import WidgetKit
import SwiftUI

struct ComplexProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplexEntry {
        ComplexEntry(date: .now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplexEntry) -> Void) {
        let entry = ComplexEntry(date: .now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = ComplexEntry(date: .now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 7)
        return dataController.results(for: request)
    }
}

struct ComplexEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct ComplexFeedbackAssistantWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var entry: ComplexProvider.Entry

    var issues: ArraySlice<Issue> {
        let issueCount: Int
        switch widgetFamily {
        case .systemSmall:
            issueCount = 1
        case .systemMedium:
            if dynamicTypeSize < .xLarge {
                issueCount = 3
            } else {
                issueCount = 2
            }
        default:
            if dynamicTypeSize < .xLarge {
                issueCount = 6
            } else {
                issueCount = 5
            }
        }
        return entry.issues.prefix(issueCount)
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(issues) { issue in
                Link(destination: issue.objectID.uriRepresentation()) {
                    VStack(alignment: .leading, content: {
                        Text(issue.issueTitle)
                            .font(.headline)
                            .layoutPriority(1)

                        if issue.issueTags.isEmpty == false {
                            Text(issue.issueTagsList)
                                .foregroundStyle(.secondary)
                        }
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct ComplexFeedbackAssistantWidget: Widget {
    let kind: String = "ComplexFeedbackAssistantWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplexProvider()) { entry in
            if #available(iOS 17.0, *) {
                ComplexFeedbackAssistantWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ComplexFeedbackAssistantWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next...")
        .description("Your most important issues.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemSmall) {
    ComplexFeedbackAssistantWidget()
} timeline: {
    ComplexEntry(date: .now, issues: [.example])
    ComplexEntry(date: .now, issues: [.example])
}

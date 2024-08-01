//
//  FeedbackAssistantApp.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 17/7/24.
//

import CoreSpotlight
import SwiftUI

@main
struct FeedbackAssistantApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var dataController = DataController()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)
            } content: {
                ContentView(dataController: dataController)
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .onChange(of: scenePhase) {
                if scenePhase != .active {
                    dataController.save()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: { userActivity in
                loadSpotlightItem(userActivity)
            })
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        // retrive string from Spotlight
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
}

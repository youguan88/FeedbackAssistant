//
//  FeedbackAssistantApp.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 17/7/24.
//

import SwiftUI

@main
struct FeedbackAssistantApp: App {
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView{
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
        }
    }
}

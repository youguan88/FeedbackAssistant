//
//  AwardsView.swift
//  FeedbackAssistant
//
//  Created by Eng You Guan on 22/7/24.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController : DataController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    var awardTitle : String {
        if dataController.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5))
                        }
                    }
                })
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails, content: {
            Alert(title: Text(awardTitle), message: Text(selectedAward.description))
        })
    }
}

#Preview {
    AwardsView()
        .environmentObject(DataController.preview)
}

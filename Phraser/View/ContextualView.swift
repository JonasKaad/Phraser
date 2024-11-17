//
//  ContextualView.swift
//  Phraser
//
//  Created by Jonas Kaad on 13/11/2024.
//

import SwiftUI
import CoreLocation

struct ContextualView: View {
    @State private var phrases: [String] = []
        
        var body: some View {
            NavigationLink(destination: ContextualPhraseView(phrases: phrases)) {
                VStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                        .padding(8)
                    Text("Context-Aware Phrases")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: 180, minHeight: 130)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            }
            .onAppear(perform: loadContextualPhrases)
        }
        
        private func loadContextualPhrases() {
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            if currentHour < 12 {
                phrases = ["Good morning!", "How's your morning going?"]
            } else if currentHour < 18 {
                phrases = ["Good afternoon!", "Enjoying the day?"]
            } else {
                phrases = ["Good evening!", "How was your day?"]
            }
        }
}
struct ContextualPhraseView: View {
    @Environment(\.modelContext) private var modelContext
    let phrases: [String]
    @State private var isShowingAddSheet = false
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                ContextWidgetView()
                
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView {
                        ForEach(phrases, id: \.self) { phrase in
                            ContextualPhraseDisplayView(text: phrase)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
#Preview{
    let phrases = ["Good evening!", "How was your day?"];
    ContextualPhraseView(phrases: phrases)
}

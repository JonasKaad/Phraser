//
//  ContextualView.swift
//  Phraser
//
//  Created by Jonas Kaad on 13/11/2024.
//

import SwiftUI
import CoreLocation
import SimpleToast

struct ContextualView: View {
    @StateObject private var locationManager = KakaoLocationManager()
    @State private var phrases: [PhraseWrapper] = []
        var body: some View {
            NavigationLink(destination: ContextualPhraseView(phrases: locationManager.currentPhrases)) {
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
        }
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
    let phrases: [PhraseWrapper]
    @State private var isShowingAddSheet = false
    @State private var searchText = ""
    @State private var notification: ToastNotification?
    private let toastOptions = SimpleToastOptions(
        alignment: .bottom, hideAfter: 4
    )
    
    var body: some View {
        NavigationView {
            VStack {
                ContextWidgetView()
                
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView {
                        ForEach(phrases) { phrase in
                            ContextualPhraseDisplayView(
                                text: phrase.phrase,
                                translation: phrase.translation,
                                phonetic: phrase.transliteration
                            )
                            Spacer()
                        }
                    }
                }
            }
        }.onToastNotification {
            notification = $0
        }
        .simpleToast(item: $notification, options: toastOptions) {
            
                HStack {
                    Image(systemName: notification?.icon ?? "exclamationmark.triangle")
                    Text(notification?.text ?? "Default message")
                    
                }
                .padding()
                .background(notification?.color.opacity(0.8))
                .foregroundColor(Color.white)
            
        }
    }
}
#Preview{
    let phrases: [PhraseWrapper] = [PhraseWrapper(phrase: "Good evening!", translation: "좋은 저녁", transliteration: "joeun jonyok")]
    ContextualPhraseView(phrases: phrases)
}

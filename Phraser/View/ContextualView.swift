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
    @StateObject private var phraseManager = PhraseFetchManager()
//    @State private var phrases: [PhraseWrapper] = []
        var body: some View {
            NavigationLink(destination: ContextualPhraseView()) {
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

struct ContextualPhraseView: View {
    @Environment(\.modelContext) private var modelContext
    //@State var phrases: [PhraseWrapper]
   // let text: String
    @State private var phraseManager = PhraseFetchManager()
    @State private var isShowingAddSheet = false
    @State private var searchText = ""
    @State private var notification: ToastNotification?
    @State private var isLoading = true
    private let toastOptions = SimpleToastOptions(
        alignment: .bottom, hideAfter: 4
    )
    
    var body: some View {
        NavigationView {
            VStack {
                ContextWidgetView()
                if phraseManager.currentPhrases.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer()
                        ProgressView("Loading Phrases...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                            .padding(.top, 10)
                            .tint(.purple)
                        
                        Spacer()
                        
//                        Button("Load Phrases") {
//                            isLoading = false
//                            phraseManager.fetchPhrases()
//                        }
                        Spacer()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        ScrollView {
                            ForEach(phraseManager.currentPhrases) { phrase in
                                ContextualPhraseDisplayView(
                                    text: phrase.phrase,
                                    translation: phrase.translation,
                                    phonetic: phrase.transliteration
                                )
                                Spacer()
                            }
                            Button("Refresh Phrases") {
                                isLoading = false
                                phraseManager.fetchPhrases(mode: "append")
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: {phraseManager.fetchPhrases()})
        .onToastNotification {
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
    ContextualPhraseView()
}

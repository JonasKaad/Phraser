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
    @State private var phraseManager = PhraseFetchManager()
    @State private var isShowingAddSheet = false
    @State private var notification: ToastNotification?
    @State private var isFirstLoad = true
    @State private var isRefreshing = false
    @State private var showCheckmark = false
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
                        Spacer()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        if isRefreshing {
                            Spacer()
                            VStack {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(1.5)
                                    Spacer()
                                }
                            }
                        } else if showCheckmark {
                            Spacer()
                            VStack {
                                HStack {
                                    Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .transition(.scale)
                                    .scaleEffect(2)
                                    Spacer()
                                }
                            }
                        }
                        ScrollView {
                            ForEach(phraseManager.currentPhrases) { phrase in
                                ContextualPhraseDisplayView(
                                    text: phrase.phrase,
                                    translation: phrase.translation,
                                    phonetic: phrase.transliteration
                                )
                                Spacer()
                            }
                        }
                        .refreshable {
                            isRefreshing = true
                            showCheckmark = false
                            await phraseManager.fetchPhrases(mode: "refresh")
                        }
                    }
                }
            }
        }
        .task {
            await phraseManager.fetchPhrases()
        }
        .onChange(of: phraseManager.refreshCompleted, {
            
            // Only trigger if it's not the first load
            if !isFirstLoad && phraseManager.refreshCompleted {
                stopRefreshing()
            }
            
            // Reset the first load flag after the initial load
            if isFirstLoad {
                isFirstLoad = false
            }
        })
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
    
    // Stops the refresh animation and shows the checkmark
    private func stopRefreshing() {
        isRefreshing = false
        showCheckmark = true
        
        // Hide the checkmark after 1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showCheckmark = false
            }
        }
    }
        
    
}
#Preview{
    ContextualPhraseView()
}

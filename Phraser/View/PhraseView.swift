//
//  PhraseView.swift
//  Phraser
//
//  Created by Jonas Kaad on 07/11/2024.
//

import SwiftUI
import SwiftData
import AVFoundation
import SimpleToast

struct PhraseView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var category: Category
    @Query var phrases: [Phrase]
    @State private var isShowingAddSheet = false
    @State private var searchText = ""
    @State private var notification: ToastNotification?
    @State private var sortOption: SortOption = .newestFirst
    @State private var isShowingSortMenu = false
    private let toastOptions = SimpleToastOptions(
        alignment: .bottom, hideAfter: 4
    )
    
    enum SortOption {
        case newestFirst
        case oldestFirst
        case alphabetical
        case phonetic
    }

    var body: some View {
        NavigationView {
            VStack {
                if let phrases = category.phrases, !phrases.isEmpty {
                    TextField("Search phrases", text: $searchText)
                        .padding(14)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 1.8)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // Drop shadow for depth
                        .padding(.horizontal, 20) // 12 padding for same dimensions
                        .font(.system(size: 20))
                }
                
                
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView {
                        if let phrases = category.phrases, !phrases.isEmpty {
                            ForEach(filteredPhrases) { phrase in
                                DisplayPhraseView(category: category, phrase: phrase)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .leading)
                                            .combined(with: .opacity)
                                            .combined(with: .scale(scale: 0.9)),
                                        removal: .move(edge: .trailing)
                                            .combined(with: .opacity)
                                    ))                                    
                                Spacer()
                            }
                        } else {
                            Spacer(minLength: 60)
                            VStack {
                                Text("No phrases found in")
                                    .font(.title)
                                HStack(spacing: 4) {
                                    Image(systemName: category.logo)
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                        .padding(2)
                                    Text(category.name)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                }
                            }
                            Spacer(minLength: 40)
                            Text("Add some phrases to get started!")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        
                    }.animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5), value: sortOption)
                    
                }
            }
            
        }
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
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Picker("Sorting Order", selection: $sortOption) {
                        Text("Newest First").tag(SortOption.newestFirst)
                        Text("Oldest First").tag(SortOption.oldestFirst)
                        Text("Alphabetical").tag(SortOption.alphabetical)
                        Text("Phonetic").tag(SortOption.phonetic)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .bold()
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                        .foregroundColor(.blue)
                }

                Button(action: {
                    isShowingAddSheet.toggle()}) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .roundedCorners()
                            
                    } //.padding()
                    .padding(.trailing, 8)
                }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            CreateNewPhraseView(isPresented: $isShowingAddSheet, createPhrase: createPhrase)
                //.presentationDetents([.fraction(0.60)])
        }

    }
    // Filter the phrases based on the search text
    private var filteredPhrases: [Phrase] {
            let filteredResult = if searchText.isEmpty {
                category.phrases ?? []
            } else {
                category.phrases?.filter {
                    $0.text.localizedCaseInsensitiveContains(searchText) ||
                    $0.translation.localizedCaseInsensitiveContains(searchText) ||
                    $0.phonetic.localizedCaseInsensitiveContains(searchText)
                } ?? []
            }
            return sortPhrases(filteredResult)
        }
    
    private func createPhrase(_text: String, _phonetic: String, _translation: String) {
        let phraseText = _text
        let phraseTranslation = _translation
        let phrasePhonetic = _phonetic
        let newPhrase = Phrase(id:  UUID() , timestamp:Date(), category:category , text: phraseText  , translation: phraseTranslation, phonetic: phrasePhonetic )
        withAnimation(.spring()) {
            modelContext.insert(newPhrase)
            
            if category.phrases == nil {
                category.phrases = [newPhrase]
            } else {
                category.phrases?.append(newPhrase)
            }
        }
    }
    
    private func sortPhrases(_ phrases: [Phrase]) -> [Phrase] {
        switch sortOption {
        case .alphabetical:
            return phrases.sorted { $0.text.localizedCaseInsensitiveCompare($1.text) == .orderedAscending }
        case .oldestFirst:
            return phrases.sorted { $0.timestamp < $1.timestamp }
        case .newestFirst:
            return phrases.sorted { $0.timestamp > $1.timestamp }
        case .phonetic:
            return phrases.sorted { $0.phonetic.localizedCaseInsensitiveCompare($1.phonetic) == .orderedAscending }
        }
    }
}

#Preview {
    let p = Phrase(id:UUID() , timestamp: Date(), category: Category(id: UUID(), timestamp: Date(), name: "Food", logo: "folder", language: "ko"), text: "Hello" , translation: "안녕하세요", phonetic: "annyonghaseyo")
    let p2 = Phrase(id:  UUID(), timestamp: Date(), category: Category(id: UUID(), timestamp: Date(), name: "food", logo: "folder", language: "ko"), text: "Jonas", translation: "조나스", phonetic: "jonaseu")
    NavigationView {
        PhraseView(category: Category(id: UUID(), timestamp: Date(), name:"Transportation" , logo: "folder", phrases: [p,p2], language: "ko"))
            .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
    }
    
}

//
//  PhraseView.swift
//  Phraser
//
//  Created by Jonas Kaad on 07/11/2024.
//

import SwiftUI
import SwiftData
import AVFoundation

struct PhraseView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var category: Category
    @Query var phrases: [Phrase]
    @State private var isShowingAddSheet = false
    @State private var searchText = ""

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
                    }
                }
            }
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingAddSheet.toggle()}) {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .bold()
                                .foregroundColor(.white)
                                // different vertical and horizontal padding
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .roundedCorners()
                                
                        }
                        .padding()
                }
                //}
        
        }
        .sheet(isPresented: $isShowingAddSheet) {
            CreateNewPhraseView(isPresented: $isShowingAddSheet, createPhrase: createPhrase)
                //.presentationDetents([.fraction(0.60)])
        }

    }
    private var filteredPhrases: [Phrase] {
            if searchText.isEmpty {
                return category.phrases ?? []
            } else {
                return category.phrases?.filter {
                    $0.text.localizedCaseInsensitiveContains(searchText) ||
                    $0.translation.localizedCaseInsensitiveContains(searchText) ||
                    $0.phonetic.localizedCaseInsensitiveContains(searchText)
                } ?? []
            }
        }
    
    private func createPhrase(_text: String, _phonetic: String, _translation: String) {
        let phraseText = _text
        let phraseTranslation = _translation
        let phrasePhonetic = _phonetic
        let newPhrase = Phrase(id:  UUID() , timestamp:Date(), category:category , text: phraseText  , translation: phraseTranslation, phonetic: phrasePhonetic )
        
        modelContext.insert(newPhrase)
        
        // Add the new phrase to the category's phrases array
        if category.phrases == nil {
            category.phrases = [newPhrase]
        } else {
            category.phrases?.append(newPhrase)
        }
    }
}

#Preview {
    let p = Phrase(id:UUID() , timestamp: Date(), category: Category(id: UUID(), timestamp: Date(), name: "Food", logo: "folder"), text: "Hello" , translation: "안녕하세요", phonetic: "annyonghaseyo")
    let p2 = Phrase(id:  UUID(), timestamp: Date(), category: Category(id: UUID(), timestamp: Date(), name: "food", logo: "folder"), text: "Jonas", translation: "조나스", phonetic: "jonaseu")
    PhraseView(category: Category(id: UUID(), timestamp: Date(), name:"Transportation" , logo: "folder", phrases: [p,p2]))
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

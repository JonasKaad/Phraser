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
                HStack(spacing: 10) {
                    Image(systemName: category.logo)
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                        .padding(8)
                    Text(category.name)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                VStack(alignment: .leading, spacing: 20) {
                    ScrollView {
                        if let phrases = category.phrases, !phrases.isEmpty {
                            ForEach(phrases) { phrase in
                                DisplayPhraseView(category: category, phrase: phrase)
                                Spacer()
                            }
                        } else {
                            Text("No phrases for \(category.name)")
                            Text("Add some phrases!")
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
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.blue) // Set blue color within the rounded rectangle shape
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.blue, lineWidth: 1.5)
                                )
                                
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
    let p2 = Phrase(id:  UUID(), timestamp: Date(), category: Category(id: UUID(), timestamp: Date(), name: "Food", logo: "folder"), text: "Jonas", translation: "조나스", phonetic: "jonaseu")
    PhraseView(category: Category(id: UUID(), timestamp: Date(), name:"Food" , logo: "folder", phrases: [p,p2]))
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

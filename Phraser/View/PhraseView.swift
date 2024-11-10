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

    //let synthesizer = AVSpeechSynthesizer()
    @State private var isShowingAddSheet = false

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
                            
                            Button(action: {
                                isShowingAddSheet.toggle()}) {
                                    CategoryAddView()
                                }
                                .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            CreateNewPhraseView(isPresented: $isShowingAddSheet.wrappedValue, createPhrase: createPhrase)
        }
    }
    
    private func createPhrase(_text: String, _phoentic: String, _translation: String) {
        let phraseText = _text
        let phraseTranslation = _translation
        let phrasePhoentic = _phoentic
        let newPhrase = Phrase(text:phraseText , id: UUID(), category:category , timestamp:Date() , phoentic:phrasePhoentic , translation: phraseTranslation)
        
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
    let p = Phrase(text: "Hello", id: UUID(), category: Category(timestamp: Date(), id: UUID(), name: "Food", logo: "folder"), timestamp: Date(), phoentic: "annyonghaseyo", translation: "안녕하세요")
    let p2 = Phrase(text: "Jonas", id: UUID(), category: Category(timestamp: Date(), id: UUID(), name: "Food", logo: "folder"), timestamp: Date(), phoentic: "jonaseu", translation: "조나스")
    PhraseView(category: Category(timestamp: Date(), id: UUID(), name:"Food" , logo: "folder", phrases: [p,p2]))
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

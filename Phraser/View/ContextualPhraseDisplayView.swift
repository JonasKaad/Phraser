//
//  ContextualPhraseDisplayView.swift
//  Phraser
//
//  Created by Jonas Kaad on 13/11/2024.
//

import SwiftUI
import AVFoundation
import Translation
import SwiftData
import SimpleToast

struct ContextualPhraseDisplayView: View {
    let text: String
    @State private var translation: String = ""
    @State private var phonetic: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var showingAddToCategorySheet = false

    let translator = AzureTranslator.shared

    var body: some View {
        
        Spacer()
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(text)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
                    .onTapGesture {
                        showingAddToCategorySheet = true
                }
            }
            HStack {
                Text(translation)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                
                Image(systemName: "document.on.document")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .onTapGesture {
                        UIPasteboard.general.string = translation
                        withAnimation {
                            SimpleToastNotificationPublisher.publish(
                                notification: ToastNotification(
                                    text: "Translation copied",
                                    color: .blue, icon: "document.on.document.fill")
                            )
                        }
                    }
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .onTapGesture {
                        let utterance = AVSpeechUtterance(string: translation)
                        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                        SpeechSynthesizerManager.shared.speak(utterance)
                    }
            }
                Text(phonetic)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
        
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(18)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.blue, lineWidth: 1.8)
        ).sheet(isPresented: $showingAddToCategorySheet) {
            AddToPhraseView(
                isPresented: $showingAddToCategorySheet, text: text, translation: translation, phonetic: phonetic
            )
        }
        
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 10)
        .onAppear(perform: translateText)
    }
    

    private func translateText() {
            isLoading = true
            errorMessage = nil
            
            translator?.translate(text: text, to: "ko") { translatedText, transliteration, error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.translation = translatedText ?? ""
                        self.phonetic = transliteration ?? ""
                    }
                }
            }
        }
}

struct AddToPhraseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Binding var isPresented: Bool
    let text: String
    let translation: String
    let phonetic: String
    
    
    var body: some View {
        NavigationView {
            List(categories) { category in
                Button(action: {
                    addPhraseToCategory(category)
                }) {
                    
                HStack {
                    Image(systemName: category.logo)
                            .font(.system(size: 30))
                    Text(category.name)
                        .font(.title)
                }
                .padding(.vertical, 6)
                    
                    
                }
            }
            .navigationTitle("Add to Category")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    private func addPhraseToCategory(_ category: Category) {
        let phrase = Phrase(id:UUID() , timestamp: Date(), category: category, text: text, translation: translation, phonetic: phonetic)
        // Add the phrase to the selected category
        if category.phrases == nil {
            category.phrases = [phrase]
        } else {
            category.phrases?.append(phrase)
        }
        
        // Save the context
        do {
            try modelContext.save()
            isPresented = false
            withAnimation {
                SimpleToastNotificationPublisher.publish(
                    notification: ToastNotification(
                        text: "Phrase added to \(category.name)",
                        color: .green, icon: "folder.badge.plus")
                )
            }
        } catch {
            print("Failed to save phrase to category: \(error)")
        }
    }
}

#Preview {
    ContextualPhraseDisplayView(text: "test")
}

struct PreviewContainer: View {
    @State private var isPresented = true

    var body: some View {
        do {
            let container = try ModelContainer(for: Category.self, Phrase.self)
            preloadMockData(container: container)
            return AddToPhraseView(
                isPresented: $isPresented,
                text: "Hello",
                translation: "안녕하세요",
                phonetic: "annyonghaseyo"
            )
            .modelContainer(container)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        
        
       
    }
    
    func preloadMockData(container: ModelContainer) {
        let context = container.mainContext

        let mockCategory1 = Category(id: UUID(), timestamp: Date(), name: "Help", logo: "sos", phrases: [])
        let mockCategory2 = Category(id: UUID(), timestamp: Date(), name: "Drinks", logo: "wineglass", phrases: [])
        let mockCategory3 = Category(id: UUID(), timestamp: Date(), name: "Conversation", logo: "translate", phrases: [])
        
        context.insert(mockCategory1)
        context.insert(mockCategory2)
        context.insert(mockCategory3)
    }
}
}

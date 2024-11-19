//
//  DisplayPhraseView.swift
//  Phraser
//
//  Created by Jonas Kaad on 10/11/2024.
//

import SwiftUI
import SwiftData
import AVFoundation
import SimpleToast

struct DisplayPhraseView: View {
    @ObservedObject var category: Category
    @ObservedObject var phrase: Phrase
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Spacer()
        VStack(alignment: .leading, spacing: 10) {
            Text(phrase.text)
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
            HStack {
                Text(phrase.translation)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .onTapGesture {
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = phrase.translation
                        
                        withAnimation {
                            SimpleToastNotificationPublisher.publish(
                                notification: ToastNotification(
                                    text: "Text copied",
                                    color: .blue, icon: "doc.on.doc")
                            )
                        }
                    }
                    
                    
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .onTapGesture {
                        let utterance = AVSpeechUtterance(string: phrase.translation)
                                utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
                                SpeechSynthesizerManager.shared.speak(utterance)
                        }
            }
            Text(phrase.phonetic)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(18)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30)) // Clip the content to the rounded shape
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.blue, lineWidth: 1.8) // Creates a rounded blue border
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 10)
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Phrase"),
                message: Text("Are you sure you want to delete phrase: \(phrase.text)"),
                primaryButton: .destructive(Text("Delete")) {
                    deletePhrase(phrase)
                },
                secondaryButton: .cancel()
            )
        }
    }
    private func deletePhrase(_ phrase: Phrase) {
        print("Before deletion: \(String(describing: category.phrases))")
        modelContext.delete(phrase)
        if let index = category.phrases?.firstIndex(where: { $0.id == phrase.id }) {
            category.phrases?.remove(at: index)
        }
        withAnimation {
            SimpleToastNotificationPublisher.publish(
                notification: ToastNotification(
                    text: "Phrase deleted",
                    color: .red, icon: "trash")
            )
        }
        print("After deletion: \(String(describing: category.phrases))")
    }
    
}


#Preview {
    let p = Phrase(id:UUID() , timestamp: Date(), category: Category(id: UUID(), timestamp: Date(), name: "Food", logo: "folder"), text: "Hello" , translation: "안녕하세요", phonetic: "annyonghaseyo")
    let p2 = Phrase(id:  UUID(), timestamp: Date(), category: Category(id: UUID(), timestamp: Date(), name: "Food", logo: "folder"), text: "Jonas", translation: "조나스", phonetic: "jonaseu")
    PhraseView(category: Category(id: UUID(), timestamp: Date(), name:"transportation" , logo: "folder", phrases: [p,p2]))
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

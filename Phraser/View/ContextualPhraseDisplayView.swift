//
//  ContextualPhraseDisplayView.swift
//  Phraser
//
//  Created by Jonas Kaad on 13/11/2024.
//

import SwiftUI
import AVFoundation
import Translation

struct ContextualPhraseDisplayView: View {
    let text: String
    @State private var translation: String = ""
    @State private var phonetic: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
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
                .foregroundColor(.blue)
                .onTapGesture {
                    UIPasteboard.general.string = translation
                }
            }
            HStack {
                Text(translation)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .onTapGesture {
                        UIPasteboard.general.string = translation
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
        )
        
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

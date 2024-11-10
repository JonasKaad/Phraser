//
//  CreateNewPhraseView.swift
//  Phraser
//
//  Created by Jonas Kaad on 10/11/2024.
//

import SwiftUI
import SwiftData
import Translation
import SwiftUIIntrospect
import AVFoundation


struct CreateNewPhraseView: View {
    @Binding var isPresented: Bool
    let createPhrase: (String, String, String) -> Void
    @State private var configuration = TranslationSession.Configuration(source: .init(identifier: "en-US"), target: .init(identifier: "ko-kr"))
    @State var text: String = "nachos"
    @State private var becomeFirstResponder = true
    @State var translation: String = "나촛"
    @State var phonetic: String = "na-chos"
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)
    
    var body: some View {
            Form {
                Section() {
                    TextField("Enter Phrase", text: $text)
                        .frame(height: 30)
                        .padding(.vertical)
                        .font(.system(size: 24))
                        .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { textField in
                            if self.becomeFirstResponder {
                                textField.becomeFirstResponder()
                                self.becomeFirstResponder = false
                            }
                        }
                }
                Section() {
                    
                    VStack(alignment: .leading) {
                        Text(text)
                            .frame(height: 40)
                            .font(.system(size: 20))
                        HStack {
                            Text(translation)
                                .frame(height: 40)
                                .font(.largeTitle)
                                .bold()
                            Spacer()
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
                            .frame(height: 40)
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                .listRowBackground(Color.teal.opacity(0.2))
                
                
                Section() {
                    Button("Save Phrase") {
                        createPhrase(text, phonetic, translation)
                        isPresented = false
                    }
                    .disabled(text.isEmpty)
                    .frame(maxWidth: .infinity, maxHeight: 5)
                    .font(.title2)
                    .padding()
                    .bold()
                    .foregroundColor(.white)
                    
                    .background(text.isEmpty ? Color.gray : Color.blue)
                    .listRowBackground(text.isEmpty ? Color.gray:Color.blue)
                
                    .cornerRadius(8)
                }
            }
        }
    
}
#Preview {
    @Previewable @State  var isPresented = true
    CreateNewPhraseView(isPresented: $isPresented, createPhrase: {_,_,_ in })
}

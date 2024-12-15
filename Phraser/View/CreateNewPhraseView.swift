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
    @ObservedObject var localizedManager = LocalizedManager.shared
    @State private var configuration = TranslationSession.Configuration(source: .init(identifier: "en-US"), target: .init(identifier: "ko-KR"))
    @State var text: String = ""
    @State private var becomeFirstResponder = true

    @State var translation: String = ""
    @State var phonetic: String = ""
    let translator = AzureTranslator.shared
    @State private var isLoading: Bool = false  // Loading state for spinner
    @State private var errorMessage: String?

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
                        .onChange(of: text, {
                            translateText()
                        })
                }
                Section() {
                    
                    VStack(alignment: .leading) {
                        Text(text)
                            .frame(height: 40)
                            .font(.system(size: 20))
                        if isLoading {
                            ProgressView()
                               .progressViewStyle(CircularProgressViewStyle())
                               .padding(.top, 10)
                               .font(.largeTitle)
                        } else if let errorMessage = errorMessage {
                           Text("Error: \(errorMessage)")
                               .foregroundColor(.red)
                               .padding(.top, 10)
                        } else {
                            HStack {
                                Text(translation)
                                    .frame(height: 40)
                                    .font(.largeTitle)
                                    .bold()
                                Spacer()
                                if !translation.isEmpty {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            let utterance = AVSpeechUtterance(string: translation)
                                            utterance.voice = AVSpeechSynthesisVoice(language: localizedManager.currentLanguage.localeInfo.speech)
                                            SpeechSynthesizerManager.shared.speak(utterance)
                                        }
                                    }
                            }
                            Text(phonetic)
                                .frame(height: 40)
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
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
        private func translateText() {
            isLoading = true
            errorMessage = nil

            
            translator?.translate(text: text, to: localizedManager.currentLanguage.localeInfo.translate) { translatedText, transliteration, error in
                    DispatchQueue.main.async {
                        isLoading = false  // End loading
                        
                        if let error = error as NSError? {
                            print("Error Translating: \(error)")
                            if error.domain == NSURLErrorDomain, error.code == NSURLErrorNotConnectedToInternet {
                                self.errorMessage = "No internet connection. Please check your network settings."
                            } else {
                                self.errorMessage = "An error occurred: \(error.localizedDescription)"
                            }
                            return
                        }
                        
                        self.translation = translatedText ?? ""
                        self.phonetic = transliteration ?? ""
                    }
            }
        }
    
}
#Preview {
    @Previewable @State  var isPresented = true
    CreateNewPhraseView(isPresented: $isPresented, createPhrase: {_,_,_ in })
}

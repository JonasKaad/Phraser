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


struct CreateNewPhraseView: View {
    @Binding var isPresented: Bool
    let createPhrase: (String, String, String) -> Void
    @State private var configuration = TranslationSession.Configuration(source: .init(identifier: "en-US"), target: .init(identifier: "ko-kr"))
    @State var text: String = ""
    @State private var becomeFirstResponder = true
    @State var phonetic: String = ""
    @State var translation: String = ""
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)
    
    var body: some View {
            Form {
                Section() {
                    TextField("Enter Phrase", text: $text)
                        .frame(height: 30)
                        .padding()
                        .font(.system(size: 24))
                        .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { textField in
                            if self.becomeFirstResponder {
                                textField.becomeFirstResponder()
                                self.becomeFirstResponder = false
                            }
                        }
                }
                VStack {
                    Text(text)
                        .frame(height: 40)
                        .font(.system(size: 24))
                    Text(phonetic)
                        .frame(height: 40)
                        .font(.system(size: 24))
                }
                
                Section() {
                    Button("Add Phrase") {
                        createPhrase(text, phonetic, translation)
                        isPresented = false
                    }
                    .disabled(text.isEmpty)
                    .frame(maxWidth: .infinity)
                    .font(.title2)
                    .padding()
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

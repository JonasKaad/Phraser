//
//  CreateNewPhraseView.swift
//  Phraser
//
//  Created by Jonas Kaad on 10/11/2024.
//

import SwiftUI
import SwiftData

struct CreateNewPhraseView: View {
    @State var isPresented: Bool
    let createPhrase: (String, String, String) -> Void
    
    @State var text: String = ""
    @State var phonetic: String = "annyonghaseyo"
    @State var translation: String = "안녕하세요"
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)
    var body: some View {
            Form {
                TextField("Enter a phrase", text: $text)
                .frame(height: 40)
                .font(.system(size: 24))
                

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

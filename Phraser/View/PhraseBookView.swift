//
//  PhraseBookView.swift
//  Phraser
//
//  Created by Jonas Kaad on 15/12/2024.
//
import SwiftUI
import SwiftData


struct PhraseBookView: View {
    @Query var categories: [Category]
    @Binding var isPresented: Bool
    @ObservedObject var localizedManager = LocalizedManager.shared
        
        var body: some View {
                VStack {
                    Spacer()
                    Text("Select Language")
                        .font(.largeTitle.bold())
                        .foregroundColor(.black)

                    Spacer()
                }
                
                TabView(selection: $localizedManager.currentLanguage) {
                    ForEach(SupportedLanguage.allCases, id: \.self) { language in
                        LanguageView(language: language, isPresented: $isPresented)
                            .tag(language)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.horizontal, 20)
                
                VStack {
                    HStack {
                        Spacer()
                        ForEach(0..<SupportedLanguage.allCases.count, id: \.self) { index in
                            Circle()
                                .fill(localizedManager.currentLanguage == SupportedLanguage.allCases[index] ? Color.black : Color.black.opacity(0.5))
                                .frame(width: 10, height: 10)
                        }
                        Spacer()
                    }
                    Text("\(totalPhraseCount(for: localizedManager.currentLanguage))")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
                .padding(.top, 20)
            
                VStack {
                    Spacer()
                    Button("Select") {
                        isPresented = false
                    }
                    .frame(maxWidth: 160, maxHeight: 16)
                    .frame(maxWidth: 160)
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                    
                    .background(Color.blue)
                    .listRowBackground(Color.blue)
                    
                    .cornerRadius(8)
                    Spacer()
                }
            }
    private func totalPhraseCount(for language: SupportedLanguage) -> String {
            var totalCount = 0
            
            // Retrieve the categories for the selected language
            let theCategories = categories.filter { $0.language == language.rawValue }
            
            // Count the total number of phrases for each category
            for category in theCategories {
                if let phrases = category.phrases {
                    totalCount += phrases.count
                }
            }
            if(totalCount == 1) {
                return String(totalCount) + " phrase"
            }
            return String(totalCount) + " phrases"
        }
}
struct LanguageView: View {
    let language: SupportedLanguage
    @Binding var isPresented: Bool

    var body: some View {
        
        VStack {
            Text(flag(for: language.localeInfo.flag.uppercased()))
                .font(.system(size: 160))
                .padding(.top, 30)
            Text(language.displayName)
                .font(.title)
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
    }
       
}

func flag(for country: String) -> String {
    country.uppercased().unicodeScalars.reduce(into: "") {
        $0.unicodeScalars.append(UnicodeScalar(127397 + $1.value)!)
    }
}

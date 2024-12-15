//
//  PhraseBookView.swift
//  Phraser
//
//  Created by Jonas Kaad on 15/12/2024.
//
import SwiftUI


struct PhraseBookView: View {
    @ObservedObject var localizedManager = LocalizedManager.shared
        
        var body: some View {
            VStack {
                Text("Select Language")
                    .font(.title)
                    .padding()
                
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    Button(action: {
                        localizedManager.changeLanguage(to: language)
                    }) {
                        HStack {
                            Text(language.displayName)
                                .font(.headline)
                            Spacer()
                            Text(flag(for: language.localeInfo.flag.uppercased()))
                                .font(.system(size: 40))
                                .padding(.trailing, 4)
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
}
func flag(for country: String) -> String {
    country.uppercased().unicodeScalars.reduce(into: "") {
        $0.unicodeScalars.append(UnicodeScalar(127397 + $1.value)!)
    }
}

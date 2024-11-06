//
//  PhraseView.swift
//  Phraser
//
//  Created by Jonas Kaad on 07/11/2024.
//

import SwiftUI
import SwiftData

struct PhraseView: View {
    @ObservedObject var category: Category

    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Phrases for \(category.name)")
                .font(.title)
                .bold()
            Text("This is where the phrases for the selected category will be displayed.")
                .font(.body)
        }
        .padding()
    }
}

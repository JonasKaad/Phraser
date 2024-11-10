//
//  ContentView.swift
//  Phraser
//
//  Created by Jonas Kaad on 04/11/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var categories: [Category]
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationView {
            
            VStack(alignment: .leading, spacing: 20) {
                ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    // For each category stored in the database show a CategoryView
                    ForEach(categories) { category in
                        CategoryView(category: category)
                    }
                    // Add button
                    Button(action: {
                        // If creating a new category is not currently being shown
                        isShowingAddSheet.toggle()}) {
                            // Show the Add new catgory button
                            CategoryAddView()
                    }
                }
                }
                
            }
            .navigationTitle("Phrasebook")
            .padding()
        }
        .sheet(isPresented: $isShowingAddSheet) {
                    CreateNewCategoryView(isPresented: $isShowingAddSheet, createCategory: createCategory)
        }
    }
    
    private func createCategory(_name: String, _logo: String) {
        let categoryName = _name
        let categoryLogo = _logo
        let newCategory = Category(timestamp: Date(), id: UUID(), name: categoryName, logo: categoryLogo)
        
        modelContext.insert(newCategory)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

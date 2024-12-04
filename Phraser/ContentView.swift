//
//  ContentView.swift
//  Phraser
//
//  Created by Jonas Kaad on 04/11/2024.
//

import SwiftUI
import SwiftData
import SimpleToast

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var categories: [Category]
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    @State private var isShowingAddSheet = false
    @State private var notification: ToastNotification?
    private let toastOptions = SimpleToastOptions(
        alignment: .bottom, hideAfter: 4
    )

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                ScrollView {
                Spacer()
                LazyVGrid(columns: columns, spacing: 20) {
                    // For each category stored in the database show a CategoryView
                    ContextualView()
                        .roundedCorners(color: Color.purple)
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
        .onToastNotification {
            notification = $0
        }
        .simpleToast(item: $notification, options: toastOptions) {
            
                HStack {
                    Image(systemName: notification?.icon ?? "exclamationmark.triangle")
                    Text(notification?.text ?? "Default message")
                    
                }
                .padding()
                .background(notification?.color.opacity(0.8))
                .foregroundColor(Color.white)
            
        }
        .sheet(isPresented: $isShowingAddSheet) {
            CreateNewCategoryView(isPresented: $isShowingAddSheet, createCategory: createCategory)
                //.presentationDetents([.fraction(0.60)])
        }
        
    }
    
    private func createCategory(_name: String, _logo: String) {
        let categoryName = _name
        let categoryLogo = _logo
        let newCategory = Category(id: UUID(), timestamp: Date(), name: categoryName, logo: categoryLogo)
        
        modelContext.insert(newCategory)
    }
    
    private func sortCategory(_ categories: [Category]) -> [Category] {
        switch sortOption {
        case .alphabetical:
            return categories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .oldestFirst:
            return categories.sorted { $0.timestamp < $1.timestamp }
        case .newestFirst:
            return categories.sorted { $0.timestamp > $1.timestamp }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

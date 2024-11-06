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
    @Environment(\.colorScheme) var colorScheme
    @Query private var categories: [Category]
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    
    var body: some View {
        
//        NavigationSplitView {
//            List(categories) { category in
//                VStack {
//
//                    HStack
//                    {
//                        CategoryView(category: category)
//                        CategoryView(category: category)
//                    }
//                }
//                Spacer()
//            }
//        }detail: {
//            Text("Create a category")
//        }
//        categoryCard
        VStack(alignment: .leading, spacing: 20) {
                    Text("Phrasebook")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)
                        .safeAreaPadding(.top, 20)
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories) { category in
                    CategoryView(category: category)
                }
                // Add button
                Button(action: createCategory) {
                    AddCategoryView()
                }
            }
            
        }
        .padding()
        }
    }
    
    // private view that contains the category name and the emoji/logo
    struct CategoryView: View {
        var category: Category
        var body: some View {
            VStack(spacing: 10) {
                Image(systemName: category.logo)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                .padding(8)
                Text(category.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: 180, minHeight: 130)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
    
    struct AddCategoryView: View {
        var body: some View {
            VStack(spacing: 10) {
                Image(systemName:"plus")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                .padding(8)
                Text("Add")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
            .frame(maxWidth: 180, minHeight: 130)
            .background(Color.blue.opacity(0.12))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
            
    }
    
    

    private func createCategory() {
        withAnimation(.spring()) {
        
            // prompt the user to enter name for the category and select an emoji
            let categoryName = "Test"
            let categoryLogo = "folder"
            let newCategory = Category(timestamp: Date(), id: UUID(), name: categoryName, logo: categoryLogo)
            
            modelContext.insert(newCategory)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

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
                Button(action: {
                    isShowingAddSheet.toggle()}) {
                    AddView()
                }
            }
            }
            
        }
        .padding()
        }
        .sheet(isPresented: $isShowingAddSheet) {
                    AddCategoryView(isPresented: $isShowingAddSheet, createCategory: createCategory)
                }
    }
    
    struct CategoryView: View {
        @ObservedObject var category: Category
        @Environment(\.modelContext) private var modelContext
        @Environment(\.presentationMode) private var presentationMode

        
        @State private var showDeleteConfirmation = false
        
        var body: some View {
            NavigationLink(destination: PhraseView(category: category)) {

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
                .contextMenu {
                            Button(role: .destructive) {
                                showDeleteConfirmation.toggle()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("Delete Category"),
                                message: Text("Are you sure you want to delete \(category.name)?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    deleteCategory(category)
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
            }
        private func deleteCategory(_ category: Category) {
                modelContext.delete(category)
        }
    }
    
    struct AddView: View {
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
    
    struct AddCategoryView: View {
        @Binding var isPresented: Bool
        let createCategory: (String, String) -> Void

        @State private var newCategoryName = ""
        @State private var selectedIcon = "folder"
            
        private let icons = [
            "folder.fill", "fork.knife", "wineglass.fill", "translate", "bus", "airplane", "hand.raised.fill", "map.fill", "sos", "cloud.fill", "bell.fill", "camera.fill",
        ]
        private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)
        var body: some View {
                Form {
                    TextField("Category Name", text: $newCategoryName)
                    .frame(height: 40)
                    .font(.system(size: 24))

                    Section("icon") {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(icons, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                }) {
                                    Image(systemName: icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .padding()
                                        .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                        .foregroundStyle(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
            
                                .background(selectedIcon == icon ? Color.teal.opacity(0.1) : Color.clear)
                                    
                                .border(selectedIcon == icon ? Color.blue.opacity(0.8): Color.clear)
                                .cornerRadius(2)
                            }
                        }
                    }
                    
                    Button("Add Category") {
                        createCategory(newCategoryName, selectedIcon)
                        isPresented = false
                    }
                    .disabled(newCategoryName.isEmpty)
                    .frame(maxWidth: .infinity)
                    .font(.title2)
                    .padding()
                    .foregroundColor(.white)
                    
                    .background(newCategoryName.isEmpty ? Color.gray : Color.blue)
                    .listRowBackground(newCategoryName.isEmpty ? Color.gray:Color.blue)
                
                    .cornerRadius(8)
                }
            }
    }
    
    private func createCategory(_name: String, _logo: String) {
        let categoryName = _name
        let categoryLogo = _logo
        let newCategory = Category(timestamp: Date(), id: UUID(), name: categoryName, logo: categoryLogo)
        
        modelContext.insert(newCategory)
    }
    private func deleteCategory(_ category: Category) {
            modelContext.delete(category)
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Phrase.self], inMemory: true)
}

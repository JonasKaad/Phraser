//
//  CreateNewCategoryView.swift
//  Phraser
//
//  Created by Jonas Kaad on 10/11/2024.
//

import SwiftUI
import SwiftData

struct CreateNewCategoryView: View {
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

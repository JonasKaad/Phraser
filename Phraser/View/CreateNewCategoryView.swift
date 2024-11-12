//
//  CreateNewCategoryView.swift
//  Phraser
//
//  Created by Jonas Kaad on 10/11/2024.
//

import SwiftUI
import SwiftData
import SwiftUIIntrospect


struct CreateNewCategoryView: View {
    @Binding var isPresented: Bool
    let createCategory: (String, String) -> Void
    @State var isEditing = true
    @FocusState var focused: Bool
    @State private var becomeFirstResponder = true
    @State private var newCategoryName = ""
    @State private var selectedIcon = "folder"
        
    private let icons = [
        "folder.fill", "fork.knife", "wineglass.fill", "translate", "bus", "airplane", "hand.raised.fill", "map.fill", "sos", "cloud.fill", "bell.fill", "camera.fill",
    ]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)
    var body: some View {
        
        Form {
            TextField("Category Name", text: $newCategoryName)
                .frame(height: 30)
                .padding(.vertical)
                .font(.system(size: 24))
                .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { textField in
                        if self.becomeFirstResponder {
                            textField.becomeFirstResponder()
                            self.becomeFirstResponder = false
                        }
                    }
           

            Section("icon") {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(icons, id: \.self) { icon in
                    Button(action:  {
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
                        
                        .clipShape(RoundedRectangle(cornerRadius: 16)) // Clip the content to the rounded shape
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedIcon == icon ? Color.blue.opacity(0.8): Color.clear, lineWidth: 1.8) // Creates a rounded blue border
                        )
                    }
                }
            }
            
            Button("Add Category") {
                createCategory(newCategoryName, selectedIcon)
                isPresented = false
            }
            .frame(maxWidth: .infinity, maxHeight: 5)
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
#Preview {
    @Previewable @State  var isPresented = true
    CreateNewCategoryView(isPresented: $isPresented, createCategory: {_,_ in })
}

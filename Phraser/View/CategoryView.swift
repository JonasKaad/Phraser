//
//  CategoryView.swift
//  Phraser
//
//  Created by Jonas Kaad on 10/11/2024.
//

import SwiftUI
import SwiftData
import SimpleToast

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
            withAnimation {
                SimpleToastNotificationPublisher.publish(
                    notification: ToastNotification(
                        text: "Category deleted",
                        color: .red, icon: "trash")
                )
            }
    }
}

struct CategoryAddView: View {
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

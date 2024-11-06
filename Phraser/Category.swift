//
//  Category.swift
//  Phraser
//
//  Created by Jonas Kaad on 06/11/2024.
//

import Foundation
import SwiftData

@Model
final class Category: ObservableObject, Identifiable {
    var name: String {
            didSet {
                objectWillChange.send()
            }
        }
    var phrases: [Phrase]? {
            didSet {
                objectWillChange.send()
            }
        }
    var id: UUID
    var logo: String {
        didSet {
            objectWillChange.send()
        }
    }
    var timestamp: Date

    init(timestamp: Date, id: UUID, name: String, logo: String) {
        self.timestamp = timestamp
        self.id = UUID()
        self.name = name
        self.logo = logo
    }
}

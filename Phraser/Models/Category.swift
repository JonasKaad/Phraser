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
    
    var id: UUID
    var timestamp: Date
    var name: String {
        didSet {
            objectWillChange.send()
        }
    }
    var logo: String {
        didSet {
            objectWillChange.send()
        }
    }
    @Relationship(deleteRule: .cascade, inverse: \Phrase.category)
    var phrases: [Phrase]?{
        didSet {
            objectWillChange.send()
        }
    }

    init(id: UUID, timestamp: Date, name: String, logo: String, phrases: [Phrase]? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.name = name
        self.logo = logo
        self.phrases = phrases
    }
}

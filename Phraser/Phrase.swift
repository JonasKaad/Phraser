//
//  Phrase.swift
//  Phraser
//
//  Created by Jonas Kaad on 06/11/2024.
//


import Foundation
import SwiftData

@Model
final class Phrase{
    var text: String
    var id: UUID
    var category: Category
    var timestamp: Date
    var phoentic: String
    var translation: String
    
    init(text: String, id: UUID,  category: Category, timestamp: Date, phoentic: String, translation: String) {
        self.text = text
        self.id = UUID()
        self.category = category
        self.timestamp = timestamp
        self.phoentic = phoentic
        self.translation = translation
    }
}

//
//  Phrase.swift
//  Phraser
//
//  Created by Jonas Kaad on 06/11/2024.
//


import Foundation
import SwiftData

@Model
final class Phrase:  ObservableObject, Identifiable{
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var category: Category?
    var text: String  {
        didSet {
            objectWillChange.send()
        }
    }
    var translation: String  {
        didSet {
            objectWillChange.send()
        }
    }
    var phonetic: String  {
        didSet {
            objectWillChange.send()
        }
    }
    
    init( id: UUID, timestamp: Date, category: Category, text: String, translation: String, phonetic: String) {
        self.id = UUID()
        self.timestamp = timestamp
        self.category = category
        self.text = text
        self.translation = translation
        self.phonetic = phonetic
    }
}

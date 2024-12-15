//
//  Category.swift
//  Phraser
//
//  Created by Jonas Kaad on 06/11/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Category: ObservableObject, Identifiable {
    @Attribute(.unique) var id: UUID
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
    var phrases: [Phrase]?{
        didSet {
            objectWillChange.send()
        }
    }
    var language: String {
        didSet {
            objectWillChange.send()
        }
    }

    init(id: UUID, timestamp: Date, name: String, logo: String, phrases: [Phrase]? = nil, language: String) {
        self.id = UUID()
        self.timestamp = timestamp
        self.name = name
        self.logo = logo
        self.phrases = phrases
        self.language = language
    }
}

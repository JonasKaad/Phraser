//
//  LanguageManager.swift
//  Phraser
//
//  Created by Jonas Kaad on 15/12/2024.
//


import Foundation
import Combine

enum SupportedLanguage: String, CaseIterable {
    case korean = "ko"
    case french = "fr"
    case chinese = "cn"
    
    var localeInfo: (speech: String, translate: String, flag: String) {
        switch self {
        case .korean:
            return ("ko-KR", "ko", "kr")
        case .french:
            return ("fr-FR", "fr", "fr")
        case .chinese:
            return ("zh-CN", "zh", "cn")
        }
    }
    
    var displayName: String {
        switch self {
        case .korean: return "Korean"
        case .french: return "French"
        case .chinese: return "Chinese"
        }
    }
}

class LocalizedManager: ObservableObject {
    @Published var currentLanguage: SupportedLanguage = .korean
    @Published var categories: [Category] = []
    
    static let shared = LocalizedManager()
    private init() {
    }
    
    func changeLanguage(to language: SupportedLanguage) {
        currentLanguage = language
    }
}

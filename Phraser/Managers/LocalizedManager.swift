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
    @Published var currentLanguage: SupportedLanguage {
            didSet {
                saveLanguageToUserDefaults()
            }
        }
    //@Published var currentLanguage: SupportedLanguage = .korean
    
    static let shared = LocalizedManager()
    private let languageKey = "SelectedLanguage" // Key for UserDefaults

    
    private init() {
        self.currentLanguage = LocalizedManager.loadLanguageFromUserDefaults()
    }
    
    func changeLanguage(to language: SupportedLanguage) {
        currentLanguage = language
    }
    
    private func saveLanguageToUserDefaults() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
    }
    private static func loadLanguageFromUserDefaults() -> SupportedLanguage {
            if let savedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage"),
               let language = SupportedLanguage(rawValue: savedLanguage) {
                return language
            }
            return .korean // Default to Korean if no saved language
        }
}

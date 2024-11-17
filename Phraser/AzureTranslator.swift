//
//  AzureTranslator.swift
//  Phraser
//
//  Created by Jonas Kaad on 12/11/2024.
//

import Foundation

struct TranslationResult: Codable {
    struct DetectedLanguage: Codable {
        let language: String
        let score: Float
    }

    struct Translation: Codable {
        let text: String
        struct Transliteration: Codable {
            let text: String
            let script: String
        }
        let transliteration: Transliteration?
        let to: String
    }

    let detectedLanguage: DetectedLanguage?
    let translations: [Translation]
}

class AzureTranslator {
    static let shared = AzureTranslator()

    private let endpoint = "https://api.cognitive.microsofttranslator.com/translate"
    private let apiKey: String
    private let region: String

    init?() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "AZURE_TRANSLATOR_API_KEY") as? String,
              let region = Bundle.main.object(forInfoDictionaryKey:"AZURE_TRANSLATOR_REGION") as? String else {
                return nil
            }
            self.apiKey = apiKey
            self.region = region
            print("AzureTranslator initialized with API key: \(apiKey) and region: \(region)")
        }

    func translate(text: String, to targetLanguage: String, completion: @escaping (String?, String?, Error?) -> Void) {
        guard let url = URL(string: "\(endpoint)?api-version=3.0&to=\(targetLanguage)&toScript=Latn") else {
            completion(nil, nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue(region, forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        let body = [
            ["Text": text]
        ]
        
        request.httpBody = try? JSONEncoder().encode(body)

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }

            guard let data = data else {
                completion(nil, nil, NSError(domain: "No data returned", code: -1, userInfo: nil))
                return
            }

            do {
                let results = try JSONDecoder().decode([TranslationResult].self, from: data)
                let translatedText = results.first?.translations.first?.text
                let transliteration = results.first?.translations.first?.transliteration?.text
                completion(translatedText, transliteration, nil)
            } catch {
                completion(nil, nil, error)
            }
        }
        
        task.resume()
    }
}

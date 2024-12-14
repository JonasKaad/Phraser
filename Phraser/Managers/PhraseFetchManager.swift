//
//  PhraseFetchManager.swift
//  Phraser
//
//  Created by Jonas Kaad on 13/12/2024.
//

import Foundation

struct PhraseWrapper: Codable, Identifiable, Hashable {
    let id: UUID
    let phrase: String
    let translation: String
    let transliteration: String

    enum CodingKeys: String, CodingKey {
        case phrase, translation, transliteration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.phrase = try container.decode(String.self, forKey: .phrase)
        self.translation = try container.decode(String.self, forKey: .translation)
        self.transliteration = try container.decode(String.self, forKey: .transliteration)
    }

    init(phrase: String, translation: String, transliteration: String) {
        self.id = UUID()
        self.phrase = phrase
        self.translation = translation
        self.transliteration = transliteration
    }
}

struct PhraseResponse: Codable {
    let phrases: [PhraseWrapper]
}

class PhraseFetchManager:  NSObject, ObservableObject {
    @Published var currentPhrases: [PhraseWrapper] = []
    @Published var foundPhrases: String = "Fetching phrases..."
    let locationManager: KakaoLocationManager = KakaoLocationManager()
    private var serverAddress: String
    
    override init() {
        self.serverAddress = "http://172.30.1.100:8080/phrases"
        print("Server address: \(self.serverAddress)")
    }
    
    
    func fetchPhrases(mode: String = "new") {
        let url = URL(string: serverAddress)!
        print("Fetching phrases from: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestObject: [String: String] = [
            "name": locationManager.place?.name ?? "Unknown",
            "category": locationManager.place?.category ?? "Unknown",
            "address": locationManager.place?.address ?? "Unknown",
            "mode": mode
        ]
        print("Request object: \(requestObject)")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestObject)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                    if let error = error {
                        print("Failed to fetch phrase info: \(error)")
                        DispatchQueue.main.async {
                            self?.foundPhrases = "Failed to fetch phrases"
                        }
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        let response = try JSONDecoder().decode(PhraseResponse.self, from: data)
                        //print(response)
                        DispatchQueue.main.async {
                            self?.currentPhrases = response.phrases
                        }
                        print("Fetched phrases: \(response.phrases)")
                    } catch {
                        print("Decoding error with phrases: \(error)")
                    }
                }
        task.resume()
    }
}

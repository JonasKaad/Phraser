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

class PhraseFetchManager: ObservableObject {
    @Published var currentPhrases: [PhraseWrapper] = []
    @Published var foundPhrases: String = "Fetching phrases..."
    @Published var refreshCompleted = false
    @Published var isLoading = false
    
    let locationManager: KakaoLocationManager = KakaoLocationManager()
    private var serverAddress: String
    private var currentTask: Task<Void, Never>? // To keep track of ongoing tasks

    init() {
        self.serverAddress = "http://172.30.1.100:8080/phrases"
        // Decode server address from Base64 encoding
//        if let encodedAddress = Bundle.main.object(forInfoDictionaryKey: "SERVER_PHRASES_ADDRESS") as? String,
//           let data = Data(base64Encoded: encodedAddress),
//           let serverAddress = String(data: data, encoding: .utf8) {
//            print("Decoded Server Address: \(serverAddress)")
//            self.serverAddress = serverAddress
//        } else {
//            print("Failed to decode server address")
//            self.serverAddress = "undefined"
//        }
    }
    
    func cancelOngoingTask() {
            currentTask?.cancel()
            currentTask = nil
    }
    
    @MainActor
    func fetchPhrases(mode: String = "new") async {
        cancelOngoingTask()
        
        self.refreshCompleted = false
        self.isLoading = true
        
        currentTask = Task {
            do {
                guard let url = URL(string: serverAddress) else {
                    throw URLError(.badURL)
                }
                
                print("Fetching phrases from: \(url)")
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let requestObject: [String: String] = [
                    "name": locationManager.place?.name ?? "Unknown",
                    "category": locationManager.place?.category ?? "Unknown",
                    "address": locationManager.place?.address ?? "Unknown",
                    "time": currentDateTime(),
                    "mode": mode
                ]
                
                print("Request object: \(requestObject)")
                
                
                
                request.httpBody = try JSONSerialization.data(withJSONObject: requestObject)
                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(PhraseResponse.self, from: data)
                
                // Ensure UI updates happen on main thread
                await MainActor.run {
                    self.currentPhrases = response.phrases
                    self.refreshCompleted = true
                    self.isLoading = false
                }
            } catch {
                
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    print("Fetch was cancelled")
                } else {
                    print("Error fetching phrases: \(error)")
                    
                    // Ensure UI updates happen on main thread
                    await MainActor.run {
                        self.foundPhrases = "Failed to fetch phrases"
                        self.refreshCompleted = true
                        self.isLoading = false
                    }
                }
        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: requestObject)
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//                    if let error = error {
//                        print("Failed to fetch phrase info: \(error)")
//                        DispatchQueue.main.async {
//                            self?.foundPhrases = "Failed to fetch phrases"
//                            self?.refreshCompleted = true
//                        }
//                        return
//                    }
//                    
//                    guard let data = data else { return }
//                    
//                    do {
//                        let response = try JSONDecoder().decode(PhraseResponse.self, from: data)
//                        //print(response)
//                        DispatchQueue.main.async {
//                            self?.currentPhrases = response.phrases
//                            self?.refreshCompleted = true
//                        }
//                        print("Fetched phrases: \(response.phrases)")
//                    } catch {
//                        print("Decoding error with phrases: \(error)")
//                        DispatchQueue.main.async {
//                            self?.refreshCompleted = true
//                        }
//                    }
//                }
//        task.resume()
            }
        }
    }
    
    func currentDateTime() -> String {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return RFC3339DateFormatter.string(from: Date())
    }
}

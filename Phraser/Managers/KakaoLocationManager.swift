//
//  KakaoLocationManager.swift
//  Phraser
//
//  Created by Jonas Kaad on 17/11/2024.
//

import Foundation
import CoreLocation

struct LocationResponse: Codable {
    let isInPlace: Bool
    let place: Place?
    let message: String?
}

struct Place: Codable {
    let name: String
    let category: String
    let distance: Int
    let address: String?
    let phone: String?
    let isCustomLocation: Bool
}

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

struct GeocodeResponse: Codable {
    let location: LocationResponse
    let phrases: [PhraseWrapper]
}

struct LocationOnlyResponse: Codable {
    let location: LocationResponse
}

class KakaoLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let clientId: String
    private var locationManager: CLLocationManager
    @Published var currentPlace: String = "Fetching location..."
    @Published var currentPhrases: [PhraseWrapper] = []
    private var serverAddress: String

    override init() {
        // Decode server address from Base64 encoding
//        if let encodedAddress = Bundle.main.object(forInfoDictionaryKey: "SERVER_ADDRESS") as? String,
//           let data = Data(base64Encoded: encodedAddress),
//           let serverAddress = String(data: data, encoding: .utf8) {
//            print("Decoded Server Address: \(serverAddress)")
//            self.serverAddress = serverAddress
//        } else {
//            print("Failed to decode server address")
//            self.serverAddress = "undefined"
//        }
        if let savedId = UserDefaults.standard.string(forKey: "clientId") {
            self.clientId = savedId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "clientId")
            self.clientId = newId
        }
        self.serverAddress = "http://172.30.1.16:8080/geocode"
        print("Server address: \(self.serverAddress)")
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchPlaceInfo(location: location)
    }

    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
        currentPlace = "Unable to fetch location"
    }

    private func fetchPlaceInfo(location: CLLocation) {
        let url = URL(string: serverAddress)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let coordinates: [String: Any] = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "mode": "new",  // Optional mode parameter
                "clientId": clientId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: coordinates)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print("Failed to fetch place info: \(error?.localizedDescription ?? "error fetching")")
                    DispatchQueue.main.async {
                        self?.currentPlace = "Failed to fetch location"
                    }
                    return
                }

                // Debug print raw response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                do {
                    // let fullResponse = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                    
                    // DispatchQueue.main.async {
                    //     // Update location display
                    //     if fullResponse.location.isInPlace, let place = fullResponse.location.place {
                    //         let distance = place.distance >= 1000 ?
                    //             String(format: "%.1fkm", Double(place.distance)/1000) :
                    //             "\(place.distance)m"
                            
                    //         self?.currentPlace = "\(place.name) (\(distance))"
                    //     } else {
                    //         self?.currentPlace = fullResponse.location.message ?? "Not in any known location"
                    //     }
                        
                    //     // Handle phrases
                    //     self?.currentPlace = fullResponse.location.place?.name ?? "Unknown"
                    //     if !fullResponse.phrases.isEmpty {
                    //         self?.currentPhrases = fullResponse.phrases
                    //     } else {
                    //         print("No phrases found")
                    //         return
                    //     }
                    // }
                    // Try first to decode as full response
                    if let fullResponse = try? JSONDecoder().decode(GeocodeResponse.self, from: data) {
                        print("Decoding full response: \(fullResponse)")
                        DispatchQueue.main.async {
                            if fullResponse.location.isInPlace, let place = fullResponse.location.place {
                                print("Updating current place from full: \(place)")
                                let distance = place.distance >= 1000 ?
                                    String(format: "%.1fkm", Double(place.distance)/1000) :
                                    "\(place.distance)m"
                                self?.currentPlace = "\(place.name) (\(distance))"
                            }
                            self?.currentPhrases = fullResponse.phrases
                        }
                        return
                    }

                    // Fallback to location-only response
                    let locationResponse = try JSONDecoder().decode(LocationOnlyResponse.self, from: data)
                    print("Decoding location-only response: \(locationResponse)")
                    DispatchQueue.main.async {
                        if locationResponse.location.isInPlace, let place = locationResponse.location.place {
                            print("Updating current place from location: \(place)")
                            let distance = place.distance >= 1000 ?
                                String(format: "%.1fkm", Double(place.distance)/1000) :
                                "\(place.distance)m"
                            self?.currentPlace = "\(place.name) (\(distance))"
                        } else {
                            self?.currentPlace = locationResponse.location.message ?? "Unknown location"
                        }
                    }

                } catch {
                    print("Decoding error: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Failed to decode JSON: \(jsonString)")
                    }
                    DispatchQueue.main.async {
                        self?.currentPlace = "Error decoding location"
                    }
                }
            }
            task.resume()
    }
}

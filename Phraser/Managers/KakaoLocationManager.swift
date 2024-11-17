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


class KakaoLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    @Published var address: String = "Fetching location..."
    @Published var currentPlace: String = "Fetching location..."
    private var serverAddress: String

    override init() {
        // Decode server address from Base64 encoding
        if let encodedAddress = Bundle.main.object(forInfoDictionaryKey: "SERVER_ADDRESS") as? String,
           let data = Data(base64Encoded: encodedAddress),
           let serverAddress = String(data: data, encoding: .utf8) {
            print("Decoded Server Address: \(serverAddress)")
            self.serverAddress = serverAddress
        } else {
            print("Failed to decode server address")
            self.serverAddress = "undefined"
        }
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
        //fetchAddressFromServer(location: location)
        fetchPlaceInfo(location: location)
    }

    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
        address = "Unable to fetch location"
        currentPlace = "Unable to fetch location"
    }

    private func fetchAddressFromServer(location: CLLocation) {
        let url = URL(string: serverAddress)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Double] = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Failed to fetch address: \(error)")
                return
            }

            guard let data = data else { return }
            if let response = try? JSONDecoder().decode([String: String].self, from: data),
               let address = response["address"] {
                DispatchQueue.main.async {
                    self?.address = address
                }
            }
        }
        task.resume()
    }
    private func fetchPlaceInfo(location: CLLocation) {
        let url = URL(string: serverAddress)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let coordinates: [String: Double] = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        request.httpBody = try? JSONSerialization.data(withJSONObject: coordinates)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Failed to fetch place info: \(error)")
                DispatchQueue.main.async {
                    self?.currentPlace = "Failed to fetch location"
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(LocationResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.isInPlace, let place = response.place {
                        // Format the place information
                        let distance = place.distance >= 1000 ?
                            String(format: "%.1fkm", Double(place.distance)/1000) :
                            "\(place.distance)m"
                            
                        self?.currentPlace = "\(place.name) (\(distance))"
                    } else {
                        self?.currentPlace = response.message ?? "Not in any known location"
                    }
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    self?.currentPlace = "Error processing location data"
                }
            }
        }
        task.resume()
    }
}

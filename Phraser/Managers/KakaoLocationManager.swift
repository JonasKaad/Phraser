//
//  KakaoLocationManager.swift
//  Phraser
//
//  Created by Jonas Kaad on 17/11/2024.
//

import Foundation
import CoreLocation

class KakaoLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    @Published var address: String = "Fetching location..."
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
        fetchAddressFromServer(location: location)
    }

    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
        address = "Unable to fetch location"
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
}

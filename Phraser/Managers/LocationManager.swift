//
//  LocationManager.swift
//  Phraser
//
//  Created by Jonas Kaad on 17/11/2024.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var address: String = "Fetching location..."

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation() // Fetch location once
    }
    
    private var lastLocation: CLLocation?


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Check if the new location is significantly different from the last location
       if let lastLocation = lastLocation,
          location.distance(from: lastLocation) < 20 { // Only update if moved > 20 meters
           return
       }

       lastLocation = location
       currentLocation = location
       fetchAddress(from: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error)")
        address = "Unable to fetch location"
    }
    private var lastGeocodeTime: Date?

    private func fetchAddress(from location: CLLocation) {
        let currentTime = Date()
        
        if let lastTime = lastGeocodeTime, currentTime.timeIntervalSince(lastTime) < 2 {
            print("Throttling geocoding request")
            return
        }

        lastGeocodeTime = currentTime

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    self.address = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                } else if let error = error {
                    print("Failed to fetch address: \(error)")
                    self.address = "Unable to fetch address"
                }
            }
        }
    }
}


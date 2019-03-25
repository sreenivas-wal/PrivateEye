//
//  LocationService.swift
//  MyMobileED
//
//  Created by Admin on 2/10/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import CoreLocation

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()
    var location: CLLocation?
    
    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("status = \(status.rawValue)")
        self.location = nil
        
        switch (status) {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            locationManager.requestAlwaysAuthorization()
            break
        default:
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!

        self.location = currentLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.location = nil
        
        print("FAIL location")
    }
    
    // MARK: LocationServiceProtocol
    
    func currentLocation() -> CLLocationCoordinate2D? {
        if let validLocation = location {
            return validLocation.coordinate
        }
        
        return nil
    }
    
    func currentLocationDescription() -> String? {
        
        guard let currentLocation = self.currentLocation() else { return nil }
        return String.init(format: "%f, %f", currentLocation.latitude, currentLocation.longitude)
    }
}

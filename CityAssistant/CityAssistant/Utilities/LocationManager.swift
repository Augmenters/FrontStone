//
//  LocationManager.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/24/23.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    var locationChangedAction: ((Coordinate) -> Void)?
    @Published var locationStatus: CLAuthorizationStatus?

    override init() {
        locationChangedAction = nil
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    init(locationChangedAction: @escaping (Coordinate) -> Void) {
        self.locationChangedAction = locationChangedAction
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
            case .notDetermined: return "notDetermined"
            case .authorizedWhenInUse: return "authorizedWhenInUse"
            case .authorizedAlways: return "authorizedAlways"
            case .restricted: return "restricted"
            case .denied: return "denied"
            default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print(#function, location)
        
        if(locationChangedAction != nil)
        {
            let userLocation = Coordinate(location.coordinate.latitude, location.coordinate.longitude)
            locationChangedAction!(userLocation)
        }
    }
}

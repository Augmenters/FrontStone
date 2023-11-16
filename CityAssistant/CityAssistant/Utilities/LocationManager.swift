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
    var failureAction: ((Error) -> Void)?
    @Published var locationStatus: CLAuthorizationStatus?

    override init() {
        locationChangedAction = nil
        failureAction = nil

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    init(locationChangedAction: @escaping (Coordinate) -> Void,
         failureAction: ((Error) -> Void)?) {
        self.locationChangedAction = locationChangedAction
        self.failureAction = failureAction

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
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

        switch status {
            case .authorizedWhenInUse, .authorizedAlways: break
            case .restricted, .denied: locationFailed(LoadingError.internalError(message: "Location permissions not granted"))
            default: locationFailed(LoadingError.internalError(message: "Unable to retrieve location permissions"))
        }

        print(#function, statusString)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationFailed(error)
    }

    func locationFailed(_ error: Error) {
        print(error)

        if(failureAction != nil) {
            failureAction!(error)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print(#function, location)

        if(locationChangedAction != nil) {
            let userLocation = Coordinate(location.coordinate.latitude, location.coordinate.longitude)
            locationChangedAction!(userLocation)
        }
    }
}

//
//  Coordinate.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/14/23.
//

import Foundation
import MapKit

public class Coordinate : Codable, ObservableObject
{
    public var Latitude : Double
    public var Longitude : Double
    
    public init() {
        self.Latitude = 0
        self.Longitude = 0
    }
    
    public init(_ latitude: Double, _ longitude: Double) {
        self.Latitude = latitude
        self.Longitude = longitude
    }
    
    public enum CodingKeys: CodingKey {
        case Latitude
        case Longitude
    }
}

public extension Coordinate {
    // this isn't ideal, would be open to a better solution
    // CLLocation is not serializable though so its cleaner and simpler to just do this
    func Distance(from: Coordinate) -> Double {
        return CLLocation(latitude: self.Latitude, longitude: self.Longitude).distance(from: CLLocation(latitude: from.Latitude, longitude: from.Longitude))
    }
    
    func Angle(relativeTo: Coordinate) -> Double {
        return atan2(Double(self.Longitude) - relativeTo.Longitude,
                     Double(self.Latitude) - relativeTo.Latitude)
    }
    
    func AsCLLocationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.Latitude, longitude: self.Longitude)
    }
}

//
//  Crime.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/25/23.
//

import Foundation
import MapKit

public class Crime
{
    public var CrimeDensity : Double
    public var Overlay : MKPolygon
    
    public init(coordinates: [Coordinate], crimeDensity: Double) {
        CrimeDensity = crimeDensity
        
        let coordinates = coordinates.map { $0.AsCLLocationCoordinate() }
        Overlay = MKPolygon(coordinates: coordinates, count: coordinates.count)
    }
}

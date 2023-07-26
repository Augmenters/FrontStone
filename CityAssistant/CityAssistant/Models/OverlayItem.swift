//
//  OverlayItem.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/25/23.
//

import Foundation
import MapKit

public class OverlayItem : Identifiable {
    public let id = UUID()
    public var Coordinates: [CLLocationCoordinate2D]

    init(coordinates: [Coordinate]) {
        self.Coordinates = []
        coordinates.forEach( { (coordinate) in self.Coordinates.append( coordinate.AsCLLocationCoordinate() ) } )
    }
}

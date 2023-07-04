//
//  AnnotationItem.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/4/23.
//

import Foundation
import MapKit

public class AnnotationItem : Identifiable {
    public let id = UUID()
    public var Coordinate: CLLocationCoordinate2D
    
    init(coordinate: Coordinate) {
        self.Coordinate = coordinate.AsCLLocationCoordinate()
    }
}

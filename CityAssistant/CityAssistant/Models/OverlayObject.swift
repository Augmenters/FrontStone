//
//  OverlayObject.swift
//  CityAssistant
//
//  Created by Jules Maslak on 9/24/23.
//

import Foundation
import MapKit

public class OverlayObject : Identifiable
{
    public let id = UUID()
    public var Overlay : MKPolygon
    public var Color : UIColor
    
    public init(coordinates: [Coordinate], color: UIColor)
    {
        self.Color = color
        let coordinates = coordinates.map { $0.AsCLLocationCoordinate() }
        Overlay = MKPolygon(coordinates: coordinates, count: coordinates.count)
    }
}

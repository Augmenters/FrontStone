//
//  Coordinate.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/14/23.
//

import Foundation

public class Coordinate : Codable, ObservableObject
{
    public var Latitude : Double
    public var Longitude : Double
    
    public init()
    {
        self.Latitude = 0
        self.Longitude = 0
    }
    
    public init(_ latitude: Double, _ longitude: Double)
    {
        self.Latitude = latitude
        self.Longitude = longitude
    }
}

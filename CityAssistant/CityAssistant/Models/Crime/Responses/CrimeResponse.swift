//
//  CrimeResponse.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation
import MapKit

public class CrimeResponse : Codable
{
    public var GridHash : String
    public var CrimeDensity : Double
    public var Coordinates : [Coordinate]
    
    public init() {
        GridHash = ""
        CrimeDensity = 0
        Coordinates = []
    }
    
    public enum CodingKeys : String, CodingKey {
        case GridHash
        case CrimeDensity
        case Coordinates
    }
}

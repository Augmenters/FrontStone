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
    public var CrimeCount : Int
    public var Coordinates : [Coordinate]
    
    public init() {
        GridHash = ""
        CrimeCount = 0
        Coordinates = []
    }
    
    public enum CodingKeys : String, CodingKey {
        case GridHash
        case CrimeCount
        case Coordinates
    }
}

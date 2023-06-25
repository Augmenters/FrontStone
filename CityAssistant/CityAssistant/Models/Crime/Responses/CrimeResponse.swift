//
//  CrimeResponse.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class CrimeResponse : Codable
{
    public var GridHash : String
    public var CrimeDensity : Double
    
    public init()
    {
        GridHash = ""
        CrimeDensity = 0
    }
    
    public enum CodingKeys : String, CodingKey
    {
        case GridHash
        case CrimeDensity
    }
}

//
//  CrimeTimeResponse.swift
//  CityAssistant
//
//  Created by Jules Maslak on 11/19/23.
//

import Foundation

public class CrimeTimeResponse : Codable
{
    public var Id : Int
    public var Crimes : [CrimeResponse]
    
    public init() {
        Id = 0
        Crimes = []
    }
    
    public enum CodingKeys : String, CodingKey {
        case Id
        case Crimes
    }
}

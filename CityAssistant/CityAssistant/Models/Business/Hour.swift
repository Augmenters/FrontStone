//
//  Hour.swift
//  CityAssistant
//
//  Created by Jules Maslak on 11/19/23.
//

import Foundation

public class Hour: Codable
{
    public var Open : Int
    public var Close : Int
    public var Day : Int
    
    public init() {
        Open = 0
        Close = 0
        Day = 0
    }
    
    public enum CodingKeys: String, CodingKey {
        case Open
        case Close
        case Day
    }
}

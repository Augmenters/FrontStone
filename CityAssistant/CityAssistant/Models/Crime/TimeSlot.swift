//
//  TimeSlot.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class TimeSlot : Codable
{
    public var DayOfWeek : Int
    public var StartHour : Int
    public var EndHour : Int
    public var Id : Int
    
    public init() {
        DayOfWeek = 0
        StartHour = 0
        EndHour = 0
        Id = 0
    }
    
    public enum CodingKeys : String, CodingKey {
        case DayOfWeek
        case StartHour
        case EndHour
        case Id
    }
}

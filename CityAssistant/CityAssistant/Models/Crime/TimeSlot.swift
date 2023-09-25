//
//  TimeSlot.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class TimeSlot : Codable, ObservableObject
{
    public var DayOfWeek : String
    public var TimeOfDay : Int
    public var Id : Int
    
    public init() {
        DayOfWeek = ""
        TimeOfDay = 0
        Id = 0
    }
    
    public init(dayOfWeek: String, timeOfDay: Int, id: Int)
    {
        self.DayOfWeek = dayOfWeek
        self.TimeOfDay = timeOfDay
        self.Id = id
    }
    
    public enum CodingKeys : String, CodingKey {
        case DayOfWeek
        case TimeOfDay
        case Id
    }
}

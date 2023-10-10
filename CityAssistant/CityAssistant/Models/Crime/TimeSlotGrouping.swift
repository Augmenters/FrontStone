//
//  TimeSlotGrouping.swift
//  CityAssistant
//
//  Created by Jules Maslak on 9/24/23.
//

import Foundation

public class TimeSlotGrouping: Hashable, Identifiable
{
    public let id = UUID()
    public var Key: String
    public var TimeSlots: [TimeSlot]
    
    public init(Key: String, TimeSlots: [TimeSlot])
    {
        self.Key = Key
        self.TimeSlots = TimeSlots
    }
    
    public static func == (lhs: TimeSlotGrouping, rhs: TimeSlotGrouping) -> Bool
    {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
    }
}

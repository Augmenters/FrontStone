//
//  POI.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/14/23.
//

import Foundation

public class POI : Codable, Identifiable
{
    public let id = UUID()
    public var Id : String?
    public var BusinessName : String
    public var Phone : String?
    public var Rating : Decimal?
    public var ReviewCount : Int
    public var Price : String?
    public var Coordinates : Coordinate
    public var Address : Address
    public var Info : String?
    public var Hours : [Hour]?
    public var CurrentHours : String {
        
        
        let currentDate = Date()
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: currentDate)
        var actualDay = weekdayNumber - 2
        if (actualDay == -1) {
            actualDay = 6
        }
        var lastDay = actualDay - 1

        if (lastDay == -1) {
            lastDay = 6
        }

        let hour = String(calendar.component(.hour, from: currentDate))
        let minute = String(calendar.component(.minute, from: currentDate))

        var currTime : String = hour
        currTime += minute

        let currTimeint = Int(currTime)

        let close = 100

    /*if (currTimeint! < close) { //last day
            actualDay = actualDay - 1
            if (actualDay == -1) {
                actualDay = 6
            }
        }
        */
        //Add in actual hours value here
        for day in Hours! {
            if (day.Day == actualDay) {
                return "\(day.Open) to \(day.Close)"
            }
        }
        return ""
    }
    
    public init() {
        self.Id = ""
        self.BusinessName = ""
        self.Phone = ""
        self.Rating = 0
        self.ReviewCount = 0
        self.Price = ""
        self.Coordinates = Coordinate()
        self.Address = CityAssistant.Address()
        self.Info = ""
        self.Hours = nil
    }
    
    public init(_ name: String, _ phone: String, _ rating: Decimal, _ price: String, _ address: Address, _ reviewCount: Int) {
        self.Id = ""
        self.BusinessName = name
        self.Phone = phone
        self.Rating = rating
        self.ReviewCount = reviewCount
        self.Price = price
        self.Coordinates = Coordinate()
        self.Address = address
        self.Info = ""
        self.Hours = nil
    }
    
    public enum CodingKeys: String, CodingKey {
        case Id
        case BusinessName
        case Phone
        case Rating
        case ReviewCount
        case Price
        case Coordinates
        case Address
        case Info
        case Hours
    }
}

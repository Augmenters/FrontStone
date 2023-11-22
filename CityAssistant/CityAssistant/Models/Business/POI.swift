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

        let currHour = String(calendar.component(.hour, from: currentDate))
        var currMinute = String(calendar.component(.minute, from: currentDate))

        if (Int(currMinute)! < 10) {
            currMinute = "0" + currMinute
        }

        var currTime : String = currHour
        currTime += currMinute

        let currTimeint = Int(currTime)
        
        var lastDayClose = 100

        for day in Hours ?? [] {
            if (day.Day == lastDay) {
                lastDayClose = day.Close
            }
        }

        if (currTimeint! < lastDayClose) { //last day
            actualDay = actualDay - 1
            if (actualDay == -1) {
                actualDay = 6
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        var hours = 10
        var minutes = 30
        
        var open = "1:00 AM"
        var close = "1:00 PM"
        
        //Add in actual hours value here
        for currday in Hours ?? [] {
            if (currday.Day == actualDay) {
                //Open time conversion
                hours = currday.Open / 100
                minutes = currday.Open % 100
                
                var dateComponents = DateComponents()
                dateComponents.hour = hours
                dateComponents.minute = minutes
                
                let calendar = Calendar.current
                if let date = calendar.date(from: dateComponents) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    open = dateFormatter.string(from: date)
                }
                
                //Close time conversion
                hours = currday.Close / 100
                minutes = currday.Close % 100
                
                dateComponents = DateComponents()
                dateComponents.hour = hours
                dateComponents.minute = minutes
                
                if let date = calendar.date(from: dateComponents) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    close = dateFormatter.string(from: date)
                }
                
                return "\(open) to \(close)"
            }
        }
        return "Closed Today"
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

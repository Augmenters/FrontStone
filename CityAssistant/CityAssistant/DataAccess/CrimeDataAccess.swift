//
//  CrimeDataAccess.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class CrimeDataAccess
{
    private let backstoneUrl : String
    
    public init()
    {
        do {
            self.backstoneUrl = try Configuration.value(for: "BackstoneUrl")
        }
        catch {
            self.backstoneUrl = ""
        }
    }
    
    public func CrimeSearch(timeSlotId: Int) -> Result<[CrimeResponse]?>
    {
        var result : Result<[CrimeResponse]?> = HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Crime/\(timeSlotId)")
        
        return result
    }
    
    public func GetTimeSlots() -> Result<[TimeSlot]?>
    {
        var result : Result<[TimeSlot]?> = HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Crime/TimeSlots")
        
        return result
    }
}

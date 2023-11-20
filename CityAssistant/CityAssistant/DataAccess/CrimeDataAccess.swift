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
    
    public init() {
        do {
            self.backstoneUrl = try Configuration.value(for: "BackstoneUrl")
        }
        catch {
            self.backstoneUrl = ""
        }
    }
    
    public func CrimeSearch(timeSlotId: Int) async -> Result<[CrimeResponse]?> {
        let result : Result<[CrimeResponse]?> = await HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Crime/\(timeSlotId)")
        
        return result
    }
    
    public func GetAllCrimes() async -> Result<[CrimeTimeResponse]?> {
        let result : Result<[CrimeTimeResponse]?> = await HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Crime/All")
        
        return result
    }
    
    public func GetTimeSlots() async -> Result<[TimeSlot]?> {
        let result : Result<[TimeSlot]?> = await HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Crime/TimeSlots")
        
        return result
    }
}

//
//  CrimeViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/4/23.
//

import Foundation
import UIKit

public class CrimeViewModel : ObservableObject {

    @Published var crimeOverlays: [OverlayObject]?

    @Published var userLocation: Coordinate
    @Published var timeSlots: [TimeSlotGrouping]
    @Published var selectedTimeSlotId : Int

    private let locationManager = LocationManager()
    private let crimeDataAccess = CrimeDataAccess()
    private var lowCrimeThreshold: Int
    private var mediumCrimeThreshold: Int
    private var highCrimeThreshold: Int
    private var allCrimes: [CrimeTimeResponse]?

    public init() {
        self.timeSlots = []
        self.crimeOverlays = []
        self.userLocation = Coordinate()
        do {
            self.selectedTimeSlotId = try Configuration.value(for: "InitialCrimeTimeSlot")
            self.lowCrimeThreshold = try Configuration.value(for: "LowCrimeThreshold")
            self.mediumCrimeThreshold = try Configuration.value(for: "MediumCrimeThreshold")
            self.highCrimeThreshold = try Configuration.value(for: "HighCrimeThreshold")
        }
        catch {
            self.selectedTimeSlotId = 2 // Sunday second time slot
            self.lowCrimeThreshold = 0
            self.mediumCrimeThreshold = 1
            self.highCrimeThreshold = 2
        }
        self.userLocation.Latitude = 38.950509
        self.userLocation.Longitude = -92.331723

        locationManager.locationChangedAction = PositionChanged
        locationManager.failureAction = { error in
            print(error)
        }
        
        Task {
            await load()
        }
    }

    func load() async {
        
        await LoadTimeslots()
        await GetCrimes()
    }
    
    
    func getData(selectedId: Double) -> [OverlayObject]? {

        // logic to get timeSlotId
//        let timeSlotGroup = timeSlots?.first(where: { timeslot in timeslot.Key == selectedGroupString})
//        let timeSlotId = timeSlotGroup?.TimeSlots[selectedId]
        
        let timeSlotId = Int(selectedId)
        print("Getting overlays for id: \(timeSlotId)")
        let selectedCrimes = allCrimes?.first(where: { crime in crime.Id == timeSlotId})
        print("selected crimes count: \(selectedCrimes?.Crimes.count)")
        
        let overlays = selectedCrimes?.Crimes.map({
            GetOverlay(coordinates: $0.Coordinates, crimeCount: $0.CrimeCount)
        })
        
        return overlays
    }

    func LoadTimeslots() async
    {
        if(timeSlots.isEmpty){
            let result = await crimeDataAccess.GetTimeSlots()
            print("Loading time slots")
            if(result.Success) {
                timeSlots = GroupTimeslots(timeslots: result.Data ?? [])
                print("Time slot loading success")
            }
            else {
                print(result.Error ?? LoadingError.internalError(message: "Failed to load crimes"))
            }
        }
        else{
            print("Time slots already loaded")
        }
    }
    
    func GetCrimes() async
    {
        if(timeSlots.isEmpty)//timeslot loading failed so don't try to load the crimes b/c the error from loading timeslots will be replaced and there will be no option to retry
        {
            print("Time slot loading failed")
            return
        }
        
        if(allCrimes == nil)
        {
            let result = await crimeDataAccess.GetAllCrimes()
            print("Getting all crimes")
            if(result.Success) {
                allCrimes = result.Data ?? []
                print("Crime loading success")
   
            }
            else {
                print(result.Error ?? LoadingError.internalError(message: "Failed to load crimes"))
            }
        }

//        let selectedCrimes = allCrimes?.first(where: { crime in crime.Id == selectedTimeSlotId})
        
//        let overlays = selectedCrimes?.Crimes.map({
//            GetOverlay(coordinates: $0.Coordinates, crimeCount: $0.CrimeCount)
//        })
//        self.crimeOverlays = overlays ?? []
    }
    
//    func SelectTimeSlot(timeSlotId: Int)
//    {
//        selectedTimeSlotId = timeSlotId
//        load()
//    }

    private func GetOverlay(coordinates: [Coordinate], crimeCount: Int) -> OverlayObject
    {
        var color: UIColor
        let opacity: CGFloat = 0.5
        
        if(crimeCount > highCrimeThreshold)
        {
            color = UIColor.red.withAlphaComponent(opacity)
        }
        else if(crimeCount > mediumCrimeThreshold)
        {
            color = UIColor.orange.withAlphaComponent(opacity)
        }
        else if(crimeCount > lowCrimeThreshold)
        {
            color = UIColor.yellow.withAlphaComponent(opacity)
        }
        else
        {
            color = UIColor.green.withAlphaComponent(opacity)
        }

        return OverlayObject(coordinates: coordinates, color: color)
    }

    private func GroupTimeslots(timeslots: [TimeSlot]) -> [TimeSlotGrouping]
    {
        var groups: [TimeSlotGrouping] = []
        timeslots.forEach({
            timeslot in

            if let group = groups.first(where: {$0.Key == timeslot.DayOfWeek})
            {
                group.TimeSlots.append(timeslot)
            }
            else
            {
                groups.append(TimeSlotGrouping(Key: timeslot.DayOfWeek, TimeSlots: [timeslot]))
            }
        })

        return groups
    }

    func PositionChanged(coordinate: Coordinate)
    {
        userLocation = coordinate
    }
}

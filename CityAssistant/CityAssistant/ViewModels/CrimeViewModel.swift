//
//  CrimeViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/4/23.
//

import Foundation
import UIKit

public class CrimeViewModel : LoadableObject {

    typealias Output = [OverlayObject]?
    var state: LoadingState<[OverlayObject]?>

    @Published var userLocation: Coordinate
    @Published var timeSlots: [TimeSlotGrouping]
    @Published var selectedTimeSlotId : Int

    private let locationManager = LocationManager()
    private let crimeDataAccess = CrimeDataAccess()
    private var lowCrimeThreshold: Int
    private var mediumCrimeThreshold: Int
    private var highCrimeThreshold: Int

    public init() {
        self.userLocation = Coordinate()
        self.state = LoadingState.idle
        self.timeSlots = []

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

        locationManager.locationChangedAction = PositionChanged
        locationManager.failureAction = { error in
            self.state = .failed(error)
        }
    }

    func load() {
        self.state = LoadingState.loading

        Task.init {
            if(timeSlots.isEmpty)
            {
                await LoadTimeslots()
            }

            await LoadCrimes()
        }
    }


    func LoadTimeslots() async
    {
        let result = await crimeDataAccess.GetTimeSlots()
        if(result.Success) {
            timeSlots = GroupTimeslots(timeslots: result.Data ?? [])
        }
        else {
            self.state = .failed(result.Error ?? LoadingError.internalError(message: "Failed to load crimes"))
        }
    }

    func LoadCrimes() async
    {
        if(timeSlots.isEmpty)//timeslot loading failed so don't try to load the crimes b/c the error from loading timeslots will be replaced and there will be no option to retry
        {
            return
        }

        let result = await crimeDataAccess.CrimeSearch(timeSlotId: selectedTimeSlotId)

        if(result.Success) {
            let crimeResponses = result.Data ?? []
            let overlays = crimeResponses.map({
                GetOverlay(coordinates: $0.Coordinates, crimeCount: $0.CrimeCount)
            })

            self.state = .loaded(overlays)
        }
        else {
            self.state = .failed(result.Error ?? LoadingError.internalError(message: "Failed to load crimes"))
        }
    }

    func SelectTimeSlot(timeSlotId: Int)
    {
        selectedTimeSlotId = timeSlotId
        load()
    }

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

//
//  CrimeViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/4/23.
//

import Foundation

public class CrimeViewModel : LoadableObject {

    typealias Output = [Crime]?
    var state: LoadingState<[Crime]?>
    @Published var userLocation: Coordinate

    private let locationManager = LocationManager()


    public init() {
        self.userLocation = Coordinate()
        self.state = LoadingState.idle


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
        if(crimeCount > highCrimeThreshold)
        {
            color = UIColor.red
        }
        else if(crimeCount > mediumCrimeThreshold)
        {
            color = UIColor.orange
        }
        else if(crimeCount > lowCrimeThreshold)
        {
            color = UIColor.yellow
        }
        else
        {
            color = UIColor.green
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

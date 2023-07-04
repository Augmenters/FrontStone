//
//  CityTourViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/20/23.
//

import Foundation

public class CityTourViewModel: LoadableObject {
    typealias Output = [POI]?
    var state: LoadingState<[POI]?>
    @Published var userLocation: Coordinate

    private let businessDataAccess: BusinessDataAccess
    private let locationManager = LocationManager()
    private let reloadDistance: Double
    private var previousPosition: Coordinate?
    
    public init() {
        self.userLocation = Coordinate()
        self.businessDataAccess = BusinessDataAccess()
        self.state = LoadingState.idle
        
        do {
            self.reloadDistance = try Configuration.value(for: "ReloadDistance")
        }
        catch {
            self.reloadDistance = 5
        }

        locationManager.locationChangedAction = PositionChanged
        locationManager.failureAction = { error in
            self.state = .failed(error)
        }
    }
    
    public init(pois:[POI])
    {
        self.userLocation = Coordinate()
        self.businessDataAccess = BusinessDataAccess()
        self.state = LoadingState.loaded(pois)
        self.reloadDistance = 0
    }
    
    func load() {
        self.state = LoadingState.loading
        
        Task.init{
            await LoadPOIs()
        }
    }
    
    func LoadPOIs() async {
        let result = await businessDataAccess.GetLocations(latitude: userLocation.Latitude, longitude: userLocation.Longitude)
        
        if(result.Success) {
            self.state = .loaded(result.Data)
        }
        else {
            self.state = .failed(result.Error ?? LoadingError.internalError(message: "Failed to load"))
        }
    }
    
    func PositionChanged(coordinate: Coordinate)
    {
        userLocation = coordinate

        if(previousPosition == nil || previousPosition!.Distance(from: userLocation) > reloadDistance)
        {
            load()
            previousPosition = userLocation
        }
    }
}

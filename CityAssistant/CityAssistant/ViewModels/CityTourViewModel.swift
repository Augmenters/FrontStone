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
    
    public init() {
        self.userLocation = Coordinate()
        self.businessDataAccess = BusinessDataAccess()
        self.state = LoadingState.idle
        locationManager.locationChangedAction = PositionChanged
    }
    
    public init(pois:[POI])
    {
        self.userLocation = Coordinate()
        self.businessDataAccess = BusinessDataAccess()
        self.state = LoadingState.loaded(pois)
    }
    
    func load() {
        self.state = LoadingState.loading
        
        Task.init{
            let result = await businessDataAccess.GetLocations(latitude: userLocation.Latitude, longitude: userLocation.Longitude)
            
            if(result.Success) {
                self.state = .loaded(result.Data)
            }
            else {
                self.state = .failed(result.Error ?? LoadingError.internalError(message: "Failed to load"))
            }
        }
    }
    
    func PositionChanged(coordinate: Coordinate)
    {
        self.userLocation = coordinate
        self.load()
    }
}

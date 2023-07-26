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
    private var loadedPOIs: [POI]
    
    public init() {
        self.userLocation = Coordinate()
        self.businessDataAccess = BusinessDataAccess()
        self.state = LoadingState.idle
        self.loadedPOIs = []
        
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
        self.loadedPOIs = pois
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
            // yelp isn't really returning enough POIs for us to have consistent results at the moment especially because location in the simulator is so buggy
            // since we are using the result from the service, at every update we are forcing a reload
            // this is happening way too often, and causing POIs to be garbage collected while they are active in child views
            // we do not want to actually be keeping this array in the final version of the app but this is a good hacky fix for the time being
            for poi in result.Data ?? []  {
                if(!loadedPOIs.contains(where: { (loadedPOI) -> Bool in return loadedPOI.Id == poi.Id })) {
                    loadedPOIs.append(poi)
                }
            }
            
            self.state = .loaded(loadedPOIs)
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

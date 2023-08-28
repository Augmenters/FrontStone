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
        self.state = .loaded([])
    }
    
    func PositionChanged(coordinate: Coordinate)
    {
        userLocation = coordinate
    }
}

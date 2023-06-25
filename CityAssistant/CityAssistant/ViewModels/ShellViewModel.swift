//
//  ShellViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/22/23.
//

import Foundation

public class ShellViewModel {
    public let businessDataAccess: BusinessDataAccess
    public let crimeDataAccess: CrimeDataAccess
    
    public init() {
        self.businessDataAccess = BusinessDataAccess()
        self.crimeDataAccess = CrimeDataAccess()
    }
}

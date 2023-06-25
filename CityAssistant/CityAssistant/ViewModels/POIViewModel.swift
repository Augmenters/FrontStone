//
//  ViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation

public class POIViewModel: LoadableObject {
    typealias Output = [Review]?
    var state: LoadingState<[Review]?>
    
    private let businessDataAccess: BusinessDataAccess
    
    public let SelectedBusiness: POI
    
    //preview helper
    public init(selectedBusiness: POI, reviews: [Review]) {
        self.SelectedBusiness = selectedBusiness
        self.state = LoadingState.loaded(reviews)
        self.businessDataAccess = BusinessDataAccess()
    }
    
    public init(business: POI)
    {
        self.businessDataAccess = BusinessDataAccess()
        self.SelectedBusiness = business
        self.state = LoadingState.idle
    }
    
    func load() {
        self.state = LoadingState.loading
        
        var result = businessDataAccess.GetReviews(businessId: SelectedBusiness.Id)
        
        if(result.Success) {
            self.state = .loaded(result.Data?.Reviews)
        }
        else {
            self.state = .failed(result.Error ?? LoadingError.internalError(message: "Failed to load"))
        }
    }
}

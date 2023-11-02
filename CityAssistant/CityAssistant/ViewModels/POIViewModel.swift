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
    
    public var SelectedBusiness: POI
        
    public init(selectedBusiness: POI, reviews: [Review]) {
        self.SelectedBusiness = selectedBusiness
        self.state = LoadingState.loaded(reviews)
        self.businessDataAccess = BusinessDataAccess()
    }
    
    public init(business: POI)
    {
        self.businessDataAccess = BusinessDataAccess()
        self.SelectedBusiness = business
        self.state = LoadingState.ignored
    }
    
    public init()
    {
        self.businessDataAccess = BusinessDataAccess()
        self.SelectedBusiness = POI()
        self.state = LoadingState.ignored
    }
    
    func load() {
        load(business: SelectedBusiness)
    }
    
    func load(business: POI) {
        self.state = LoadingState.loading
        self.SelectedBusiness = business
        
        Task.init {
            let result = await businessDataAccess.GetReviews(businessId: SelectedBusiness.Id ?? "0")
            if(result.Success) {
                self.state = .loaded(result.Data?.Reviews)
            }
            else {
                self.state = .failed(result.Error ?? LoadingError.internalError(message: "Failed to load"))
            }
        }
    }
}

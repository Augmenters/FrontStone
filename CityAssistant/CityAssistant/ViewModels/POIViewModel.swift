//
//  ViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation

public class POIViewModel: ObservableObject {
    
    private let businessDataAccess: BusinessDataAccess
    
    public var SelectedBusiness: POI
    @Published var Reviews: [Review]
        
    public init(selectedBusiness: POI, reviews: [Review]) {
        self.SelectedBusiness = selectedBusiness
        self.businessDataAccess = BusinessDataAccess()
        self.Reviews = []
    }
    
    public init(business: POI)
    {
        self.businessDataAccess = BusinessDataAccess()
        self.SelectedBusiness = business
        self.Reviews = []
    }
    
    public init()
    {
        self.businessDataAccess = BusinessDataAccess()
        self.SelectedBusiness = POI()
        self.Reviews = []
    }
    
    func load() {
        load(business: SelectedBusiness)
    }
    
    func load(business: POI) {
        self.SelectedBusiness = business
        
        Task.init {
            let result = await businessDataAccess.GetReviews(businessId: SelectedBusiness.Id ?? "0")
            
            await MainActor.run
            {
                if(result.Success) {
                    self.Reviews = result.Data?.Reviews ?? []
                }
                else {
                    self.Reviews = []
                }
            }
        }
    }
}

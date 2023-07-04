//
//  BusinessDataAccess.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/14/23.
//

import Foundation

public class BusinessDataAccess
{
    private let backstoneUrl : String
    
    init() {
        do {
            self.backstoneUrl = try Configuration.value(for: "BackstoneUrl")
        }
        catch {
            self.backstoneUrl = ""
        }
    }
    
    public func GetLocations(latitude: Double, longitude: Double) async -> Result<[POI]?> {
        let params = [
            URLQueryItem(name:"latitude", value: String(latitude)),
            URLQueryItem(name:"longitude", value: String(longitude))
        ]
        
        let result : Result<[POI]?> = await HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Business/Search", queryParams: params)
        
        return result
    }
    
    public func GetReviews(businessId: String) async -> Result<BusinessReviewsResponse?> {
        let result : Result<BusinessReviewsResponse?> = await HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Business/\(businessId)/Reviews")
        
        return result
    }
}

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
        
        var result : Result<[POI]?> = await HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Business/Search", queryParams: params)
        
        
        if(result.Error == LoadingError.notFound)
        {
            result = Result<[POI]?>(data: [], success: true, error: nil)
        }
        
        return result
    }
    
    public func GetReviews(businessId: String) async -> Result<BusinessReviewsResponse?> {
        var result : Result<BusinessReviewsResponse?>
        if(businessId == "null")
        {
            result = Result<BusinessReviewsResponse?>(data: nil, success: true, error: nil)
        }
        else
        {
            result = await HttpClientHelper().Get(baseUrl: backstoneUrl, resource: "Business/\(businessId)/Reviews")
        }
        
        
        return result
    }
}

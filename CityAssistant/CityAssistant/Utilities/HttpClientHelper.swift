//
//  HttpClientHelper.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class HttpClientHelper
{
    public init(){}

    public func Get<T>(baseUrl: String, resource: String, queryParams: [URLQueryItem]? = nil) async -> Result<T?> where T : Decodable
    {
        var resource = URLComponents(string: baseUrl + resource)
        if(queryParams != nil) {
            resource!.queryItems = queryParams
        }

        var request = URLRequest(url: resource!.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared

        var result : Result<T?> = Result<T?>(data: nil, success: false)
        
        do {
            let (data, _) = try await session.data(for: request)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            result = Result<T?>(data: decoded, success: true)
        } catch {
            print(error)
            result = Result<T?>(data: nil, success: false, error: LoadingError.internalError(message: error.localizedDescription))
        }
        
        return result
    }
}

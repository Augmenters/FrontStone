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

    public func Get<T>(baseUrl: String, resource: String, queryParams: [URLQueryItem]? = nil) -> Result<T?> where T : Decodable
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
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if(data != nil)
            {
                do {
                    let data = try JSONDecoder().decode(T.self, from: data!)
                    result = Result<T?>(data: data, success: true)
                } catch {
                    result = Result<T?>(data: nil, success: false, error: LoadingError.internalError(message: error.localizedDescription))
                }
            }
            else
            {
                result = Result<T?>(data: nil, success: false, error: LoadingError.internalError(message: "Failed to return data from server"))
            }
        })

        task.resume()
        return result
    }
}

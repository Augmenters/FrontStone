//
//  BusinessReviewsReponse.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class BusinessReviewsResponse : Codable
{
    public var Reviews : [Review]
    public var Total : Int
    public var PossibleLanguages : [String]
    
    public init() {
        Reviews = []
        Total = 0
        PossibleLanguages = []
    }
    
    public enum CodingKeys: String, CodingKey {
        case Reviews
        case Total
        case PossibleLanguages
    }
}

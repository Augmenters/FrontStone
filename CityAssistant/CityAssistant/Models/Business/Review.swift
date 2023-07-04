//
//  Review.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class Review : Hashable, Codable
{
    public let id = UUID()
    public var Url : String
    public var Text : String
    public var Rating : Decimal
    public var TimeCreated : String
    public var User : User
    
    public init() {
        self.Url = ""
        self.Text = ""
        self.Rating = 0
        self.TimeCreated = ""
        self.User = CityAssistant.User()
    }
    
    public init(_ text: String, _ rating: Decimal, _ username: String) {
        self.Url = ""
        self.Text = text
        self.Rating = rating
        self.TimeCreated = ""
        self.User = CityAssistant.User(username)
    }
    
    public static func == (lhs: Review, rhs: Review) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
    }
    
    public enum CodingKeys : String, CodingKey {
        case Url
        case Text
        case Rating
        case TimeCreated
        case User
    }
}

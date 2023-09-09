//
//  User.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/15/23.
//

import Foundation

public class User: Codable
{
    public var Name : String
    public var ImageUrl : String?
    
    public init() {
        Name = ""
        ImageUrl = ""
    }
    
    public init(_ name: String) {
        self.Name = name
        self.ImageUrl = ""
    }
    
    public enum CodingKeys: String, CodingKey {
        case Name
        case ImageUrl
    }
}

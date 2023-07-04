//
//  Address.swift
//  ARDemo
//
//  Created by Jules Maslak on 6/14/23.
//

import Foundation

public class Address: Codable
{
    public var Line1 : String
    public var Line2 : String?
    public var City : String
    public var State : String
    public var Zip : String
    
    public init() {
        Line1 = ""
        Line2 = ""
        City = ""
        State = ""
        Zip = ""
    }
    
    public init(_ line1: String, _ city: String, _ state: String, _ zip: String, _ line2: String = "") {
        self.Line1 = line1
        self.Line2 = line2
        self.City = city
        self.State = state
        self.Zip = zip
    }
    
    public func ToString() -> String {
        return "\(Line1)\(Line2 == nil ||  Line2!.isEmpty ? "" : " " + Line2!), \(City), \(State) \(Zip)"
    }
    
    public enum CodingKeys: CodingKey {
        case Line1
        case Line2
        case City
        case State
        case Zip
    }
}

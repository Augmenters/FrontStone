//
//  LoadingError.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/20/23.
//

import Foundation

public enum LoadingError: Error, Equatable {
    case notFound
    case unauthorized
    case internalError(message: String)
}

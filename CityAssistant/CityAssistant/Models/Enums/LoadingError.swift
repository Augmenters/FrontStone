//
//  LoadingError.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/20/23.
//

import Foundation

enum LoadingError: Error {
    case notFound
    case unauthorized
    case internalError(message: String)
}

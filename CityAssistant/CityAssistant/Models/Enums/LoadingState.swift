//
//  LoadingState.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation

enum LoadingState<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}

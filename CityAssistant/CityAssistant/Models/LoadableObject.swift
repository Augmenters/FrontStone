//
//  LoadableObject.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation

protocol LoadableObject: ObservableObject {
    associatedtype Output
    var state: LoadingState<Output> { get }
    func load()
}

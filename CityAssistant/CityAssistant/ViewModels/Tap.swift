//
//  Tap.swift
//  CityAssistant
//
//  Created by Justin Reini on 9/21/23.
//

import Foundation

// Class created to track gestures acted upon AR objects

class Tap: ObservableObject {
    @Published var tapped = false
    func clicked() {
        self.tapped.toggle()
    }
}

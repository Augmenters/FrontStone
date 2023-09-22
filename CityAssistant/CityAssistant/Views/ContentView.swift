//
//  ContentView.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI
import RealityKit

struct ContentView : View {
    
    init() {
        
    }
    
    var body: some View {
        ZStack{
            VStack(alignment: .trailing) {
                NavigationStack {
                    NavigationLink {
                        CrimeView()
                    } label: {
                        Label("2D Map", systemImage: "map")
                    }
                    NavigationLink {
                        CityTourView()
                    } label: {
                        Label("City Tour", systemImage: "camera")
                    }
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About this app", systemImage: "info")
                    }
                }
            }
        }
    }
}

struct Content_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
    @State var currentView: ViewType
    
    init() {
        currentView = ViewType.POIView
    }
    
    var body: some View {
        ZStack{
            switch currentView
            {
                case .AboutView:
                    AboutView()
                case .POIView:
                    CityTourViewWrapper()
                case .CrimeView:
                    CrimeView()
            }
            VStack()
            {
                Spacer()
                NavBar(selectedView: $currentView)
            }
        }
    }
}

struct Content_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

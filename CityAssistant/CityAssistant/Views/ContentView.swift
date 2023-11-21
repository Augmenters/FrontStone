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
    @State var crimeViewModel: CrimeViewModel
    
    init() {
        currentView = ViewType.POIView
        crimeViewModel = CrimeViewModel()
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
                    CrimeView(viewModel: crimeViewModel)
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

//
//  CityTour.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI
import RealityKit

struct CityTour:
    UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct CityTourView: View {
    @ObservedObject var viewModel: CityTourViewModel
    @ObservedObject var poiViewModel: POIViewModel

    @State var showARView = true
    
    init() {
        viewModel = CityTourViewModel()
        poiViewModel = POIViewModel() //we instantiate this here so that the context isn't lost if the view refreshes, probably a better way to do this
    }
    
    init(pois: [POI]) {
        viewModel = CityTourViewModel(pois: pois)
        poiViewModel = POIViewModel()
    }
    
    var body: some View {
        AsyncContentView(source: viewModel, content:  { pois in
            ZStack {
                if(showARView) {
                    //CityTour().edgesIgnoringSafeArea(.all)
                }
                else {
                    POIMapView(pois: pois ?? [],
                               userLocation: viewModel.userLocation,
                               poiViewModel: poiViewModel)
                }
                VStack() {
                    Spacer()
                    Button(action: {
                        showARView.toggle()
                    }) {
                        Text(showARView ? "Show Map view" : "Show AR View")
                    }
                }
            }
        },  useProgressView: false)
    }
}

struct CityTourView_Previews: PreviewProvider {
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockPOIs: [POI] = [mockPOI]
    
    static var previews: some View {
        CityTourView(pois: mockPOIs)
    }
}

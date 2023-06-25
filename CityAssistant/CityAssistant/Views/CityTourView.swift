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
    @State var showARView = true
    
    init() {
        viewModel = CityTourViewModel()
    }
    
    init(pois: [POI]) {
        viewModel = CityTourViewModel(pois: pois)
    }
    
    var body: some View {
        AsyncContentView(source: viewModel) { pois in
            ZStack {
                if(showARView) {
                    //CityTour().edgesIgnoringSafeArea(.all)
                }
                else {
                    POIMapView(pois: pois ?? [], userLocation: viewModel.userLocation)
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
        }
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

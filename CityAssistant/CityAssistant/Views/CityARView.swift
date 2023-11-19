//
//  CityARView.swift
//  CityAssistant
//
//  Created by Justin Reini on 9/11/23.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

struct CameraView: UIViewRepresentable
{
    @State var viewModel: CityTourViewModel

    init(viewModel: CityTourViewModel) {
        self.viewModel = viewModel
    }

    func makeUIView(context: Context) -> ARView {
        let arView = viewModel.arView
        context.coordinator.view = arView
        arView.session.delegate = context.coordinator
        
        viewModel.arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(POITap.handleTap(_:))))
        return viewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        //Reslot the pois whenever ios decides to reload the view, not really sure if this is what we want but I think it is
        //viewModel.slotPOIs()
    }

    func makeCoordinator() -> POITap {
        POITap(viewModel: viewModel)
    }
}

class POITap: NSObject, ARSessionDelegate {
    weak var view: ARView?
    let viewModel: CityTourViewModel

    init(viewModel: CityTourViewModel) {
        self.viewModel = viewModel
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let view = self.view else {return}

        let tapLocation = recognizer.location(in: view)
        if let entity = view.entity(at: tapLocation) as? ModelEntity
        {
            viewModel.selectPOI(entity: entity)
        }
    }
    
    // function that detects new planes
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
            
                self.viewModel.slotOntoPlane(plane: planeAnchor)
            }
        }
    }
}


struct CityARView : View
{
    @ObservedObject var cityTourViewModel: CityTourViewModel
    @ObservedObject var poiViewModel: POIViewModel

    init(cityModel: CityTourViewModel, poiModel: POIViewModel) {
        print("Creating city AR view")
        cityTourViewModel = cityModel
        poiViewModel = poiModel
    }

    var body: some View {
        if(cityTourViewModel.selectedPOI != nil) { //This will sort of work, except we have no way of knowing when the user exits out of the view
            POIView(selectedBusiness: cityTourViewModel.selectedPOI!, viewModel: poiViewModel)
        }
        else {
            CameraView(viewModel: cityTourViewModel).edgesIgnoringSafeArea(.all)
        }
    }
}

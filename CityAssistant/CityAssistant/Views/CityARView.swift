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
    //@State var viewModel: CityTourViewModel

//    init(viewModel: CityTourViewModel) {
//        self.viewModel = viewModel
//    }
    
    init() {
    }

    func makeUIView(context: Context) -> ARView {
//        context.coordinator.view = viewModel.arView
//        viewModel.arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(POITap.handleTap(_:))))
        
        let arView = ARView(frame: .zero)
       // Configure the AR session
       let config = ARWorldTrackingConfiguration()
       config.planeDetection = [.vertical]
       arView.session.run(config)
        
        context.coordinator.setupARView(arView)
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        //Reslot the pois whenever ios decides to reload the view, not really sure if this is what we want but I think it is
        //viewModel.slotPOIs()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

//    func makeCoordinator() -> POITap {
//        POITap(viewModel: viewModel)
//    }
}

class Coordinator: NSObject, ARSessionDelegate {
    var parent: CameraView

    init(_ parent: CameraView) {
        self.parent = parent
    }

    func setupARView(_ arView: ARView) {
        arView.session.delegate = self
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let arView = session.delegate as? ARView else { return }

        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
                // Load a 3D model and add it to the anchor
                if let modelEntity = try? ModelEntity.loadModel(named: "yourModelName") {
                    let anchorEntity = AnchorEntity(anchor: planeAnchor)
                    anchorEntity.addChild(modelEntity)
                    arView.scene.addAnchor(anchorEntity)
                }
                break // Remove this if you want to place models on every detected plane
            }
        }
    }
}



//class POITap: NSObject {
//    weak var view: ARView?
//    let viewModel: CityTourViewModel
//
//    init(viewModel: CityTourViewModel) {
//        self.viewModel = viewModel
//    }
//
//    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
//        guard let view = self.view else {return}
//
//        let tapLocation = recognizer.location(in: view)
//        if let entity = view.entity(at: tapLocation) as? ModelEntity
//        {
//            viewModel.selectSlottedPOI(entity: entity)
//        }
//    }
//}


//struct CityARView : View
//{
//    @ObservedObject var cityTourViewModel: CityTourViewModel
//    @ObservedObject var poiViewModel: POIViewModel
//
//    init(cityModel: CityTourViewModel, poiModel: POIViewModel) {
//        cityTourViewModel = cityModel
//        poiViewModel = poiModel
//    }
//
//    var body: some View {
//        if(cityTourViewModel.selectedPOI != nil) { //This will sort of work, except we have no way of knowing when the user exits out of the view
//            POIView(selectedBusiness: cityTourViewModel.selectedPOI!, viewModel: poiViewModel)
//        }
//        else {
//            CameraView(viewModel: cityTourViewModel).edgesIgnoringSafeArea(.all)
//        }
//    }
//}

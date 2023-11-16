//
//  CityARView.swift
//  CityAssistant
//
//  Created by Justin Reini on 9/11/23.
//

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
        print("Creating Camera View")
    }

    func makeUIView(context: Context) -> ARView {
//        context.coordinator.view = viewModel.arView
//        viewModel.arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(POITap.handleTap(_:))))
        
        print("Creating AR View")
        let arView = ARView(frame: .zero)
        setupARView(arView)
    
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        //Reslot the pois whenever ios decides to reload the view, not really sure if this is what we want but I think it is
        //viewModel.slotPOIs()
    }
    
    private func setupARView(_ arView: ARView) {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        // Add the model after a delay to ensure the session is properly started
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.addModelTo(arView: arView)
        }
    }

    private func addModelTo(arView: ARView) {
        
        let boxMesh = MeshResource.generateBox(size: 0.5)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        // Position the model 10 meters in front of the user
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -2.0 // 10 meters away
        let anchor = AnchorEntity(world: translation)
        anchor.addChild(boxEntity)

        arView.scene.addAnchor(anchor)
    }
    

//    func makeCoordinator() -> POITap {
//        POITap(viewModel: viewModel)
//    }
}
//
//class Coordinator: NSObject, ARSessionDelegate {
//    var parent: CameraView
//
//    init(_ parent: CameraView) {
//        self.parent = parent
//    }
//
//    func setupARView(_ arView: ARView) {
//        arView.session.delegate = self
//    }
//
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        //print(anchors)
//        guard let arView = session.delegate as? ARView else { return }
//
//        for anchor in anchors {
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                
//                print(planeAnchor)
//                
//                // Create a box and add it to the anchor
//                let boxMesh = MeshResource.generateBox(size: 2)
//                let material = SimpleMaterial(color: .red, isMetallic: false)
//                let boxEntity = ModelEntity(mesh: boxMesh, materials: [material])
//
//                let anchorEntity = AnchorEntity(anchor: planeAnchor)
//                anchorEntity.addChild(boxEntity)
//                arView.scene.addAnchor(anchorEntity)
//                
//                break // Remove this if you want to place models on every detected plane
//            }
//        }
//    }
//}



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

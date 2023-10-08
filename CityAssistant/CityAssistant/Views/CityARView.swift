//
//  CityARView.swift
//  CityAssistant
//
//  Created by Justin Reini on 9/11/23.
//

import Foundation
import SwiftUI
import RealityKit

struct CameraView: UIViewRepresentable {
    
    //Temporary test, will be removed when seperate files are created for AR objects
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockPOIs: [POI] = [mockPOI]
    static let mockReviews: [Review] = [
        Review("The food here was great. Would recommend bringing family.", 4.5, "Micheal Scott"),
        Review("Service was slow and waiters were rude. Not worth the price", 2, "Patrick Mahomes"),
        Review("Good food for a sunny day.", 3, "Tiger Woods")]
    static let mockViewModel: POIViewModel = POIViewModel(selectedBusiness: mockPOI, reviews: mockReviews)
    
    
    
    @ObservedObject var tap: Tap
    
    init(tap: Tap) {
        self.tap = tap
    }
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        context.coordinator.view = arView
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(CityCoordinator.handleTap(_:))))
        
        let poi = createPOI()
        
        placePOI(poi: poi, arView: arView)
        
        
        return arView
    }
        
        
    
    func createPOI() -> ModelEntity {
        // For now, this function creates the test text
        // Will be used to create POI bubbles
        let txt = ModelEntity(mesh: MeshResource.generateText("Test Text", extrusionDepth: 0.01, font: .boldSystemFont(ofSize: 0.1), containerFrame: .zero, alignment: .center,lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])
        
        txt.generateCollisionShapes(recursive: true)
        return txt
    }
    
    func placePOI(poi: ModelEntity, arView: ARView) {
        // Place individual poi in scene
        // Places test text at default coordinate for now
        let poiAnchor = AnchorEntity()
        poiAnchor.addChild(poi)
        arView.scene.addAnchor(poiAnchor)
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        //Place to unload old anchors and add new ones when the user moves
    }
    
    func makeCoordinator() -> CityCoordinator {
        CityCoordinator(tap: tap)
    }
    
    
    
}

class CityCoordinator: NSObject {
    weak var view: ARView?
    @ObservedObject var tap: Tap
    
    init(tap: Tap) {
        self.tap = tap
    }
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let view = self.view else {return}
        
        let tapLocation = recognizer.location(in: view)
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            // In the future will relay specific entity back to main view
            // Will decide what POI View to open
            tap.clicked()
        }
    }
}


struct CityARView : View {
    
    @StateObject var tap = Tap()
    
    //Temporary test, will be removed when seperate files are created for AR objects
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockPOIs: [POI] = [mockPOI]
    static let mockReviews: [Review] = [
        Review("The food here was great. Would recommend bringing family.", 4.5, "Micheal Scott"),
        Review("Service was slow and waiters were rude. Not worth the price", 2, "Patrick Mahomes"),
        Review("Good food for a sunny day.", 3, "Tiger Woods")]
    static let mockViewModel: POIViewModel = POIViewModel(selectedBusiness: mockPOI, reviews: mockReviews)
    
    //Variables to be used in the future for tracking spcific entity tapped on
    //@State var viewModel: POIViewModel
    //@State var selectedBusiness: POI
    
    init() {

    }
    var body: some View {
        if(tap.tapped) {
            POIView(selectedBusiness: CityARView.mockPOI, viewModel: CityARView.mockViewModel)
        }
        else {
            CameraView(tap: tap).edgesIgnoringSafeArea(.all)
        }
    }
}

struct CityARView_Previews: PreviewProvider {
    static var previews: some View {
        CityARView()
    }
}

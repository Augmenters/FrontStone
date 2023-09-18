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
        
        // Loads defualt box in
        // When tapped, launch the POIView screen with appropriate test information
        let arView = ARView(frame: .zero)
        context.coordinator.view = arView
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:))))
        let anchor = AnchorEntity()
        let bubbleAnchor = AnchorEntity()
        
        let plane = ModelEntity(
            mesh: MeshResource.generatePlane(width: 50, height: 70, cornerRadius: 2.5),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)],
                collisionShape: ShapeResource.generateBox(width: 50, height: 70, depth: 1),
                mass: 0
            )
        
        let txt = ModelEntity(mesh: MeshResource.generateText("Test Text", extrusionDepth: 0.01, font: .boldSystemFont(ofSize: 0.01), containerFrame: .zero, alignment: .center,lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])
        
        txt.generateCollisionShapes(recursive: true)
        
        bubbleAnchor.addChild(plane)
        anchor.addChild(txt)
        arView.scene.addAnchor(anchor)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

class Coordinator: NSObject {
    weak var view: ARView?
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let view = self.view else {return}
        let tapLocation = recognizer.location(in: view)
        
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            //POIView(selectedBusiness: CityTourView_Previews.mockPOI, viewModel: CityTourView_Previews.mockViewModel)
            
            //Navigation currently not working so for now just registering the tapped object
            print("clicked")
        }
    }
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
        poiViewModel = POIViewModel(business: CityTourView_Previews.mockPOI)
    }
    
    var body: some View {
        AsyncContentView(source: viewModel, content:  { pois in
            ZStack {
                if(showARView) {
                    CityTour().edgesIgnoringSafeArea(.all)
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
    static let mockReviews: [Review] = [
        Review("The food here was great. Would recommend bringing family.", 4.5, "Micheal Scott"),
        Review("Service was slow and waiters were rude. Not worth the price", 2, "Patrick Mahomes"),
        Review("Good food for a sunny day.", 3, "Tiger Woods")]
    static let mockViewModel: POIViewModel = POIViewModel(selectedBusiness: mockPOI, reviews: mockReviews)
    
    static var previews: some View {
        CityTourView(pois: mockPOIs)
    }
}

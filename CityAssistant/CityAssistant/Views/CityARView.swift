//
//  CityARView.swift
//  CityAssistant
//
//  Created by Justin Reini on 9/11/23.
//

import Foundation
import SwiftUI
import RealityKit

struct CameraView: UIViewRepresentable
{
    @State var viewModel: CityTourViewModel

    init(viewModel: CityTourViewModel) {
        self.viewModel = viewModel
    }

    func makeUIView(context: Context) -> ARView {
        context.coordinator.view = viewModel.arView
        viewModel.arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(POITap.handleTap(_:))))
        return viewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        //Reslot the pois whenever ios decides to reload the view, not really sure if this is what we want but I think it is
        viewModel.slotPOIs()
    }

    func makeCoordinator() -> POITap {
        POITap(viewModel: viewModel)
    }
}

class POITap: NSObject {
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
            viewModel.selectSlottedPOI(entity: entity)
        }
    }
}


struct CityARView : View
{
    @State var cityTourViewModel: CityTourViewModel
    @State var poiViewModel: POIViewModel

    init(cityModel: CityTourViewModel, poiModel: POIViewModel) {
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

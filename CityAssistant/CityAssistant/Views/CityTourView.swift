//
//  CityTour.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI
import RealityKit


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
                    CityARView()
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

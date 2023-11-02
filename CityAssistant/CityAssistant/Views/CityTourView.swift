//
//  CityTour.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI
import RealityKit


struct CityTourViewWrapper: View {
    @ObservedObject var poiMapViewModel: POIMapViewModel
    @ObservedObject var poiViewModel: POIViewModel
    @ObservedObject var cityTourViewModel: CityTourViewModel

    @State var showARView = true

    init() {
        poiMapViewModel = POIMapViewModel()
        poiViewModel = POIViewModel() //we instantiate this here so that the context isn't lost if the view refreshes, probably a better way to do this
        cityTourViewModel = CityTourViewModel() 
    }

    init(pois: [POI]) {
        poiMapViewModel = POIMapViewModel(pois: pois)
        poiViewModel = POIViewModel(business: CityTourView_Previews.mockPOI)
        cityTourViewModel = CityTourViewModel()
    }

    var body: some View {
            ZStack {
                if(showARView) {
                    CityARView(cityModel: cityTourViewModel, poiModel: poiViewModel)
                }
                else {
                    AsyncContentView(source: poiMapViewModel, content:  { pois in

                        POIMapView(pois: pois ?? [],
                                   userLocation: poiMapViewModel.userLocation,
                                   poiViewModel: poiViewModel)
                    },  useProgressView: false)
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
        CityTourViewWrapper(pois: mockPOIs)
    }
}

//
//  LoadedPOIsView.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/24/23.
//

import Foundation
import SwiftUI
import MapKit

struct POIMapView: View {
    @ObservedObject var userLocation: Coordinate
    @ObservedObject var poiViewModel: POIViewModel
    
    @State var pois: [POI]

    init(pois: [POI], userLocation: Coordinate, poiViewModel: POIViewModel) {
        self.pois = pois
        self.userLocation = userLocation
        self.poiViewModel = poiViewModel
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(userLocation: userLocation,
                    annotations: pois.map{AnnotationItem(coordinate: $0.Coordinates)}).edgesIgnoringSafeArea([.top, .leading, .trailing, .bottom])
            NavigationStack {
                List {
                    ForEach(pois, id: \.Id) { poi in
                        NavigationLink {
                            ScrollView
                            {
                                POIView(selectedBusiness: poi, viewModel: poiViewModel)
                            }
                        } label: {
                            POICard(poi: poi)
                        }
                    }
                }
            }.frame(height: 400, alignment: .bottom).opacity(0.6)
        }
    }
}

struct POIMapView_Previews: PreviewProvider {
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockPOIs: [POI] = [mockPOI]
    static let mockReviews: [Review] = [
        Review("The food here was great. Would recommend bringing family.", 4.5, "Micheal Scott"),
        Review("Service was slow and waiters were rude. Not worth the price", 2, "Patrick Mahomes"),
        Review("Good food for a sunny day.", 3, "Tiger Woods")]
    static let mockViewModel: POIViewModel = POIViewModel(selectedBusiness: mockPOI, reviews: mockReviews)
    static var previews: some View {
        POIMapView(pois: mockPOIs, userLocation: Coordinate(), poiViewModel: mockViewModel)
    }
}

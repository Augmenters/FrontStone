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

    var pois: [POI]

    init(pois: [POI], userLocation: Coordinate) {
        self.pois = pois
        self.userLocation = userLocation
    }
    
    var body: some View {
        VStack{
            MapView(userLocation: userLocation,
                    annotations: pois.map{AnnotationItem(coordinate: $0.Coordinates)} )
                .edgesIgnoringSafeArea([.top])
                .frame(width: 400, height: 500)
            NavigationStack {
                List{
                    ForEach(pois) { poi in
                        NavigationLink {
                            POIView(viewModel: POIViewModel( business: poi))
                        } label: {
                            POICard(poi: poi)
                        }
                    }
                }
            }.frame(width: 400, height: 400)
            Spacer()
        }
    }
}

struct POIMapView_Previews: PreviewProvider {
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockPOIs: [POI] = [mockPOI]

    static var previews: some View {
        POIMapView(pois: mockPOIs, userLocation: Coordinate())
    }
}

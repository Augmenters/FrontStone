//
//  MapView.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/4/23.
//

import Foundation
import SwiftUI
import MapKit

struct MapView : View {
    @ObservedObject var userLocation: Coordinate
    @State private var region: MKCoordinateRegion
    @State private var annotations: [AnnotationItem]?
    
    init(userLocation: Coordinate, annotations: [AnnotationItem]? = nil) {
        self.userLocation = userLocation
        self.annotations = annotations
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.Latitude, longitude: userLocation.Longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
        
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow),
                annotationItems: annotations ?? []) { item in
                    MapMarker(coordinate: item.Coordinate)
            }
        }
    }
}

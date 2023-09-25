//
//  MapView.swift
//  CityAssistant
//
//  Created by Jules Maslak on 7/4/23.
//

import Foundation
import SwiftUI
import MapKit
import Map

struct MapView : View {
    @ObservedObject var userLocation: Coordinate
    @State private var region: MKCoordinateRegion
    @State private var annotations: [AnnotationItem]?
    @State private var overlays: [OverlayObject]?
    @State private var userTrackingMode: UserTrackingMode
    @State private var mapType: MKMapType
    
    init(userLocation: Coordinate,
         annotations: [AnnotationItem]? = nil,
         overlays: [OverlayObject]? = nil,
         trackUser: Bool = false,
         mapType: MKMapType = .satellite) {
        self.userLocation = userLocation
        self.annotations = annotations
        self.overlays = overlays
        self.mapType = mapType
        self.userTrackingMode = trackUser ? .follow : .none
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.Latitude, longitude: userLocation.Longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
        
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                type: mapType,
                pointOfInterestFilter: MKPointOfInterestFilter.excludingAll,
                informationVisibility: .default.union(.userLocation),
                interactionModes: [.all],
                userTrackingMode: $userTrackingMode,
                annotationItems: annotations ?? [],
                annotationContent:
                { item in
                    MapMarker(coordinate: item.Coordinate)
                },
                overlays: overlays?.map { $0.Overlay } ?? [],
                overlayContent:
                { overlay in
                RendererMapOverlay(overlay: overlay)
                    { _, overlay in
                        if let polygon = overlay as? MKPolygon
                        {
                            if let overlayObject = overlays?.first(where: {$0.Overlay === overlay})
                            {
                                let renderer = MKPolygonRenderer(polygon: polygon)
                                
                                
                                renderer.fillColor = overlayObject.Color
                                return renderer
                            }
                        }

                        return MKOverlayRenderer(overlay: overlay)
                    }
                }
            )
        }
    }
}

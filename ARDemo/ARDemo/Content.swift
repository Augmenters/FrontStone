//
//  ContentView.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI
import RealityKit

struct Content : View {
    var body: some View {
        ZStack{
            CityTour().edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing) {
                NavigationStack {
                    NavigationLink {
                        Crime()
                    } label: {
//                        Label("2D Map", image: "map")
                        Label("2D Map", systemImage: "map")
                            .labelStyle(.iconOnly)
                    }
                    NavigationLink {
                        POI()
                    } label: {
//                        Label("POI Info", image: "i-letter")
                        Label("POI Info", systemImage: "pin")
                            .labelStyle(.iconOnly)
                    }
                    NavigationLink {
                        About()
                    } label: {
//                        Label("About this app", image: "i-letter")
                        Label("About this app", systemImage: "info")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct Content_Previews : PreviewProvider {
    static var previews: some View {
        Content()
    }
}
#endif

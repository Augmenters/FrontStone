//
//  ContentView.swift
//  ARDemo
//
//  Created by Justin Reini on 4/18/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ZStack{
            ARViewContainer().edgesIgnoringSafeArea(.all)
            VStack(alignment: .trailing) {
                NavigationStack {
                    NavigationLink {
                        MapView()
                    } label: {
//                        Label("2D Map", image: "map")
                        Label("2D Map", systemImage: "map")
                            .labelStyle(.iconOnly)
                    }
                    NavigationLink {
                        POI_InfoView()
                    } label: {
//                        Label("POI Info", image: "i-letter")
                        Label("POI Info", systemImage: "pin")
                            .labelStyle(.iconOnly)
                    }
                    NavigationLink {
                        AboutView()
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

struct ARViewContainer:

    UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

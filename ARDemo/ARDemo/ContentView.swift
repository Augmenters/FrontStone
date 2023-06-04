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
                        Label("2D Map", image: "map")
                            .labelStyle(.iconOnly)
                    }
                    NavigationLink {
                        POI_InfoView()
                    } label: {
                        Label("About", image: "i-letter")
                            .labelStyle(.iconOnly)
                    }.position(x:300,y:20)
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

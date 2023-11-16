//
//  CityTourViewModel.swift
//  CityAssistant
//
//  Created by Jules Maslak on 10/8/23.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit

public class CityTourViewModel : ObservableObject
{
    @Published var userLocation: Coordinate
    @Published var selectedPOI: POI?

    public var arView: ARView

    private let businessDataAccess: BusinessDataAccess
    private let locationManager = LocationManager()

    private let reloadDistance: Double
    private var previousPosition: Coordinate?

    private var visiblePOIs: [UInt64: POI] // [EntityId : POI] Contains only businesses
    private var slottedPOIs: [Int: POI] // [AngleRangeStart : POI] Contains businesses and empty addresses
    private var loadedPOIs: [POI]

    public init() {
        self.arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        self.arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        self.userLocation = Coordinate()
        self.businessDataAccess = BusinessDataAccess()
        self.slottedPOIs = [:]
        self.visiblePOIs = [:]
        self.loadedPOIs = []
        self.selectedPOI = nil

        do {
            self.reloadDistance = try Configuration.value(for: "ReloadDistance")
        }
        catch {
            self.reloadDistance = 5
        }

        locationManager.locationChangedAction = self.PositionChanged
        locationManager.failureAction = { error in
            //No real error handling in this view, need to find a way to display an error to the user
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.addModelTo(arView: self.arView)
        }
    }
    
    private func addModelTo(arView: ARView) {
        print("Placing simple object")
        let boxMesh = MeshResource.generateBox(size: 0.5)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        // Position the model 10 meters in front of the user
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -2.0 // 10 meters away
        let anchor = AnchorEntity(world: translation)
        anchor.addChild(boxEntity)

        arView.scene.addAnchor(anchor)
    }

    func load() {
        Task.init{
            await LoadPOIs()
        }

        //after loading has finished, start slotting in the main thread so that we don't run into a race condition
        slotPOIs()
    }

    func LoadPOIs() async {
        print("Loading POIS")
        let result = await businessDataAccess.GetLocations(latitude: userLocation.Latitude, longitude: userLocation.Longitude)

        if(result.Success) {
            for poi in result.Data ?? []  {
                //If the poi has not been seen, add it to the loaded pois... we should probably also be clearing the loaded poi list at some point
                //Worth noting that the Id here is returned from yelp (or in the case of an empty address the database) not the uuid or entity id
                if(!loadedPOIs.contains(where: { (loadedPOI) -> Bool in return loadedPOI.Id == poi.Id })) {
                    loadedPOIs.append(poi)
                }
            }
        }
        else {
        }
    }

    func PositionChanged(coordinate: Coordinate) {
        userLocation = coordinate

        if(previousPosition == nil || previousPosition!.Distance(from: userLocation) > reloadDistance)
        {
            load()
            previousPosition = userLocation

            //This is where we will have to remove POIs that are far away, assuming that they did not get replaced during slotting already
        }
    }
    func degreesToRadians(_ degrees: Float) -> Float {
        return degrees * (.pi / 180)
    }

    func slotPOIs() {
        print("Slotting POIS")
        let angleIncrement = Float(360) / 12
        let angleIncrementRadians = degreesToRadians(angleIncrement)
        let radius : Float = 1
        print("Loaded POIS")
        print(loadedPOIs)

        for i in 0...11
        {
            print("\n\nSlot: " + String(i))
            var currentlySlotted: (POI, AnchorEntity, Double)?
            
            //this is the width of the slot
            let slotRangeLow = Double(angleIncrementRadians) * Double(i)
            let slotRangeHigh = Double(angleIncrementRadians) * Double(i + 1)
            print(slotRangeLow)
            print(slotRangeHigh)

            for poi in loadedPOIs {
                
//                print("POI")
//                print(poi)
                //this is the real angle to the user
                let deltaY = userLocation.Latitude - poi.Coordinates.Latitude
                let deltaX = userLocation.Longitude - poi.Coordinates.Longitude
                var angleToPOI = atan2(deltaY, deltaX)
                
                if angleToPOI < 0 {
                    angleToPOI += 2 * .pi
                }

                if(angleToPOI < slotRangeLow || angleToPOI > slotRangeHigh)
                {
                    continue
                }
                
                print("POI In angle range")

                // arbitrarily high so that if the distance is null for whatever reason (it should never be)
                // we replace the slot on the next go or dont slot it
                let poiDistance = currentlySlotted?.0.Coordinates.Distance(from: userLocation) ?? 10000

                if(currentlySlotted != nil)
                {
                    if(poiDistance > currentlySlotted!.2)
                    {
                        continue;
                    }
                }
                
                print("Slotting POI")

                //this is the new position inside of the AR view coordinate space
                let cameraPos = arView.cameraTransform.translation
                let newX = cameraPos.x + (radius * sin(angleIncrementRadians * Float(i)))
                let newZ = cameraPos.z + (radius * cos(angleIncrementRadians * Float(i)))
                let newPosition = SIMD3<Float>(x: newX, y: cameraPos.y, z: newZ)

                let poiAnchor = AnchorEntity()
                let worldAnchor = AnchorEntity(world: .zero)
                let poiTransform = Transform(scale: .one, rotation: simd_quatf(), translation: newPosition)
                poiAnchor.move(to: poiTransform, relativeTo: worldAnchor)
                
                currentlySlotted = (poi, poiAnchor, poiDistance)
            }

            if(currentlySlotted != nil)
            {
                addPOIToARView(poi: currentlySlotted!.0, anchor: currentlySlotted!.1)
            }
        }
        print("POIS Slotted")
    }

    // Jules' slotting helper functions
    func selectSlottedPOI(entity: ModelEntity) {
        let poi = getSlottedPOIFromEntity(entity: entity)
        if(poi != nil)
        {
            selectedPOI = poi
        }
    }

    func getSlottedPOIFromEntity(entity: ModelEntity) -> POI? {
        guard let poi = visiblePOIs.first(where: {(key, _) -> Bool in return key == entity.id}) else {return nil}
        return poi.value
    }

    func addPOIToARView(poi: POI, anchor: AnchorEntity) {
        let model = makePOIBubble(poi: poi)
        anchor.addChild(model)
        visiblePOIs.updateValue(poi, forKey: model.id)
        arView.scene.addAnchor(anchor)
    }

    func removePOIFromArView(poi: POI) {
        guard let entityId = visiblePOIs.first(where: {(_ , value) -> Bool in return value.Id == poi.Id})?.key else {return}
        guard let entity = arView.scene.anchors.first(where: {(element) -> Bool in return element.id == entityId}) else{return}
        arView.scene.anchors.remove(entity) //This shouldn't happen now but if we use plane detection in the future, I think its possible that multiple models could be tied to a single anchor so this may need to be reevaluated
    }

    // Where the bubble needs to be built
    private func makePOIBubble(poi: POI) -> ModelEntity {
        let model = ModelEntity(mesh: MeshResource.generateText(poi.BusinessName, extrusionDepth: 0.01, font: .boldSystemFont(ofSize: 0.1), containerFrame: .zero, alignment: .center,lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])

        model.generateCollisionShapes(recursive: true)
        return model
    }

    // Creates POI bubble and returns anchor that the bubble is fixed to
    func createPOIBubble(poi: POI, newPosition: SIMD3<Float>) -> AnchorEntity {
        let leftMargin = -0.45
        let topMargin = 0.4
        let bottomMargin = -0.4
        let textSpacing = 0.1
        let bigFontSize = 0.1
        let mediumFontSize = 0.07
        let smallFontSize = 0.05

//        let poiAnchor = AnchorEntity(world: newPosition) // Bubble didn't pop up when we tried this
        let poiAnchor = AnchorEntity()
        let worldAnchor = AnchorEntity(world: .zero)
        let poiTransform = Transform(scale: .one, rotation: simd_quatf(), translation: newPosition)
        poiAnchor.move(to: poiTransform, relativeTo: worldAnchor)
        
        let bubble = createBubble() // creates plane
        poiAnchor.addChild(bubble)
        // TODO Instead of adding multiple ModelEntities to the same anchor directly, they could be grouped under a single Entity and that Entity can be added.
        //   https://developer.apple.com/documentation/realitykit/entity

        let businessNameText = create3dText(text: poi.BusinessName, x: leftMargin, y: topMargin, fontSize: bigFontSize)
        poiAnchor.addChild(businessNameText)

        let businessType = "Business Type" // do we have this?
        let businessTypeText = create3dText(text: businessType, x: leftMargin, y: topMargin - textSpacing, fontSize: mediumFontSize)
        poiAnchor.addChild(businessTypeText)

        let hours = "8 am to 9 pm" // this should be pulled from business open time
        let hoursText = create3dText(text: hours, x: leftMargin, y: topMargin - textSpacing * 2, fontSize: mediumFontSize)
        poiAnchor.addChild(hoursText)

        let ratingText = create3dText(text: "Yelp Rating: \(poi.Rating!)/5 Stars", x: leftMargin, y: topMargin - textSpacing * 3, fontSize: mediumFontSize)
        poiAnchor.addChild(ratingText)

        let promptText = create3dText(text: "Click for more information", x: leftMargin, y: bottomMargin, fontSize: smallFontSize)
        poiAnchor.addChild(promptText)

        return poiAnchor
    }

    // Create custom 3D text at specified local coordinate (x,y)
    func create3dText(text: String, x: Double = 0.0, y: Double = 0.0, fontSize: CGFloat = 0.1) -> ModelEntity {
        // Where to place the text
        let x = x
        let y = y
        let rectOrigin = CGPoint(x: x, y: y)
        let rectSize = CGSize(width: 0, height: 0)
        let textFrameRect = CGRect(origin: rectOrigin, size: rectSize)

        let myText = ModelEntity(mesh: MeshResource.generateText(text, extrusionDepth: 0.01, font: .boldSystemFont(ofSize: fontSize), containerFrame: textFrameRect, alignment: .center, lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])
        myText.generateCollisionShapes(recursive: true)
        return myText
    }

    // Creates rectangle plane for POI bubble
    func createBubble() -> ModelEntity {
        let planeWidth: Float = 1
        let planeHeight: Float = 1
        let planeCornerRadius: Float = 0.1
        let planeCollisionDepth: Float = 0.1
        let planeCollisionMass: Float = 0
        let planeColor = UIColor(red: 170, green: 166, blue: 255, alpha: 0.80)

        let plane = ModelEntity(
            mesh: MeshResource.generatePlane(width: planeWidth, height: planeHeight, cornerRadius: planeCornerRadius),
                materials: [SimpleMaterial(color: planeColor, isMetallic: false)],
            collisionShape: ShapeResource.generateBox(width: planeWidth, height: planeHeight, depth: planeCollisionDepth),
                mass: planeCollisionMass
            )
        return plane
    }

    // Creates a POI bubble and places it at given position (The specified position part doesn't work yet)
    func placePOI(poi: POI, newPosition: SIMD3<Float>) {
        let poiAnchor = createPOIBubble(poi: poi, newPosition: newPosition)
        arView.scene.addAnchor(poiAnchor)
        print("placePOI was called")
    }
}

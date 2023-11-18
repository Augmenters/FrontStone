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
        config.planeDetection = [.vertical]
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
            
//            // top left
//            self.addModelTo(arView: self.arView, zDistance: -2.0, xDistance: -2.0, color: .blue)
//            
//            // top right
//            self.addModelTo(arView: self.arView, zDistance: -2.0, xDistance: 2.0, color: .black)
//            
//            //bottom right
//            self.addModelTo(arView: self.arView, zDistance: 2.0, xDistance: 2.0, color: .red)
//            
//            // bottom left
//            self.addModelTo(arView: self.arView, zDistance: 2.0, xDistance: -2.0, color: .green)
        }
    }
    
    private func addModelTo(arView: ARView, zDistance: Float, xDistance: Float, color: UIColor) {
        print("Placing simple object")
        let boxMesh = MeshResource.generateBox(size: 0.5)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        // Position the model 10 meters in front of the user
        var translation = matrix_identity_float4x4
        translation.columns.3.z = zDistance // 10 meters away
        translation.columns.3.x = xDistance
        let anchor = AnchorEntity(world: translation)
        anchor.addChild(boxEntity)

        arView.scene.addAnchor(anchor)
    }
    
    private func addModelToPlane(arView: ARView, plane: ARPlaneAnchor) {
        print("Placing plane object")
        let boxMesh = MeshResource.generateBox(size: 0.5)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        let anchor = AnchorEntity(world: plane.transform)
        anchor.addChild(boxEntity)

        arView.scene.addAnchor(anchor)
    }

    func load() {
        Task.init{
            await LoadPOIs()
        }

        //after loading has finished, start slotting in the main thread so that we don't run into a race condition
        //slotPOIs()
    }

    func LoadPOIs() async {
        print("Loading POIS")
        let result = await businessDataAccess.GetLocations(latitude: userLocation.Latitude, longitude: userLocation.Longitude)

        if(result.Success) {
            loadedPOIs = []
            
            for poi in result.Data ?? []  {
                loadedPOIs.append(poi)
            }
        }
        else {
            print("Failed to load POIs: \(result.Error.debugDescription)")
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
    
    func calculateBearing(from: (latitude: Double, longitude: Double),
                          to: (latitude: Double, longitude: Double)) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x) * 180 / .pi
        
        if bearing < 0 {
            bearing += 360
        }

        return bearing // Bearing in degrees
    }
    
    func calculateBearing(from userPosition: SIMD3<Float>, to planePosition: SIMD3<Float>) -> Float {
        let dx = planePosition.x - userPosition.x
        let dz = planePosition.z - userPosition.z
        let bearingRadians = atan2(dz, dx)
        var bearingDegrees = bearingRadians * 180 / .pi
        
        if bearingDegrees < 0 {
            bearingDegrees += 360
        }
        
        return bearingDegrees
    }
    
    
    func approximateDistance(userLocation: (latitude: Double, longitude: Double),
                             poiLocation: (latitude: Double, longitude: Double)) -> Double {
        let earthRadius: Double = 6371000 // Earth's radius in meters

        let lat1 = userLocation.latitude * .pi / 180
        let lon1 = userLocation.longitude * .pi / 180
        let lat2 = poiLocation.latitude * .pi / 180
        let lon2 = poiLocation.longitude * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        let distance = earthRadius * c
        return distance // distance in meters
    }
    
    func positionForPOI(userLocation: (latitude: Double, longitude: Double),
                        poiLocation: (latitude: Double, longitude: Double)) -> SIMD3<Float> {
        
        let distance = approximateDistance(userLocation: userLocation, poiLocation: poiLocation)
        let bearing = calculateBearing(from: userLocation, to: poiLocation)

        let bearingRadians = degreesToRadians(Float(bearing))

        // Calculate x and z position using simple trigonometry
        let x = Float(distance) * sin(bearingRadians)
        let z = Float(distance) * cos(bearingRadians)
        
        return SIMD3<Float>(x: -x, y: 0, z: z) // Assuming y is 0 (no altitude difference)
    }
    
    func normalizeToUnitVector(_ vector: SIMD3<Float>) -> SIMD3<Float> {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        guard length != 0 else { return SIMD3<Float>(x: 0, y: 0, z: 0) }
        
        return SIMD3<Float>(x: vector.x / length, y: vector.y / length, z: vector.z / length)
    }
    
    func isPOIInUserDirection(userLocation: (latitude: Double, longitude: Double),
                              userHeading: CLLocationDirection,
                              poiLocation: (latitude: Double, longitude: Double)) -> Bool {
        
        let bearingToPOI = calculateBearing(from: userLocation, to: poiLocation)
        let headingDifference = abs(userHeading - bearingToPOI)
        let threshold = 20.0 // Define a threshold (in degrees) for "in direction"

        return headingDifference <= threshold || headingDifference >= 360 - threshold
    }

    
    func slotOntoPlane(plane: ARPlaneAnchor){
        
        //addModelToPlane(arView: self.arView, plane: plane)
        
        var closestValidPOI: POI? = nil
        var closestDistance: Double = Double.greatestFiniteMagnitude
        
//        Get user heading
        guard let heading = locationManager.currentHeading else { return }
        //print("User heading: \(heading)")
        
//      Get user location
        let location = locationManager.currentLocation?.coordinate
        if let userLatitude = location?.latitude, let userLongitude = location?.longitude  {
            let userGpsLocation = (latitude: userLatitude, longitude: userLongitude)
            //print("User gps location: \(userGpsLocation)")
            
            //  Loop through POIS
            for poi in loadedPOIs{
                
                let poiLatitude = poi.Coordinates.Latitude
                let poiLongitude = poi.Coordinates.Longitude
                let poiLocation = (latitude: poiLatitude, longitude: poiLongitude)
                
                let isPotentialPOI = isPOIInUserDirection(userLocation: userGpsLocation, userHeading: heading, poiLocation: poiLocation)
                if isPotentialPOI == false {
                   continue
                }
                
                let distance = approximateDistance(userLocation: userGpsLocation, poiLocation: poiLocation)
                if distance < closestDistance {
                    closestValidPOI = poi
                    closestDistance = distance
                }
//                print("\(poi.BusinessName) Distance: \(distance)")
            }
            if let poi = closestValidPOI {
                addPoiToPlane(poi: poi, plane: plane)
            } else {
                print("No POIs in view")
            }
        }
        
        

        

        
    
//        //print("\n\nSlot onto plane")
//        let planeLocation = plane.center
//        let desiredBearing = calculateBearing(from: userLocation, to: planeLocation)
//        //print("Desired Bearing: \(desiredBearing)")
//
//        
//        let location = locationManager.currentLocation?.coordinate
//        if let userLatitude = location?.latitude, let userLongitude = location?.longitude  {
//            let userGpsLocation = (latitude: userLatitude, longitude: userLongitude)
//            print(userGpsLocation)
//            
//            for poi in loadedPOIs{
//                
//                let poiLatitude = poi.Coordinates.Latitude
//                let poiLongitude = poi.Coordinates.Longitude
//                let poiLocation = (latitude: poiLatitude, longitude: poiLongitude)
//                
//                let poiBearing = calculateBearing(userLocation: userGpsLocation, poiLocation: poiLocation)
//                //print("\(poi.BusinessName) Bearing: \(poiBearing)")
//            }
//            
//        }
    }
    
    
    
    func slotPOIs() {
        print("Slotting POIS")
        if loadedPOIs.isEmpty {
            print("No POIs found")
            return
        }

        let angleIncrement = Float(360) / 12
        //let angleIncrementRadians = degreesToRadians(angleIncrement)
        //let radius : Float = 1
    
        
        print("Loaded POIS")
        for poi in loadedPOIs {
            print(poi.BusinessName)
        }

        for i in 0...11
        {
            
            var currentlySlotted: (POI, AnchorEntity, Double)?
            
            //this is the width of the slot
            let slotRangeLow = Double(angleIncrement) * Double(i)
            let slotRangeHigh = Double(angleIncrement) * Double(i + 1)
            
            print("\n\nSlot: \(i) (\(slotRangeLow), \(slotRangeHigh))")

            for poi in loadedPOIs {
                
                let businessName = poi.BusinessName
                
                
                let poiLatitude = poi.Coordinates.Latitude
                let poiLongitude = poi.Coordinates.Longitude
                let poiLocation = (latitude: poiLatitude, longitude: poiLongitude)
                
                let userLatitude = userLocation.Latitude
                let userLongitude = userLocation.Longitude
                let userLocation = (latitude: userLatitude, longitude: userLongitude)
                
                let distance = approximateDistance(userLocation: userLocation, poiLocation: poiLocation)
                let bearing = calculateBearing(from: userLocation, to: poiLocation)
                

                if(bearing < slotRangeLow || bearing > slotRangeHigh)
                {
                    continue
                }
                
                if let currentlySlottedPOI = currentlySlotted, distance > currentlySlottedPOI.2 {
                    continue
                }
                
                
                let position = positionForPOI(userLocation: userLocation, poiLocation: poiLocation)
                
                print("Slotting \(businessName) at \(position)")

                let poiAnchor = AnchorEntity(world: position)
                currentlySlotted = (poi, poiAnchor, distance)
            }

            if(currentlySlotted != nil)
            {
                //addPOIToARView(poi: currentlySlotted!.0, anchor: currentlySlotted!.1)
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

    func addPoiToPlane(poi: POI, plane: ARPlaneAnchor) {
        
        print("Placing \(poi.BusinessName) on plane")
        let model = makePOIBubble(poi: poi)
        let anchor = AnchorEntity(world: plane.transform)
        anchor.addChild(model)
        self.arView.scene.addAnchor(anchor)
        
        //visiblePOIs.updateValue(poi, forKey: model.id)
        
        

    }

    func removePOIFromArView(poi: POI) {
        guard let entityId = visiblePOIs.first(where: {(_ , value) -> Bool in return value.Id == poi.Id})?.key else {return}
        guard let entity = arView.scene.anchors.first(where: {(element) -> Bool in return element.id == entityId}) else{return}
        arView.scene.anchors.remove(entity) //This shouldn't happen now but if we use plane detection in the future, I think its possible that multiple models could be tied to a single anchor so this may need to be reevaluated
    }

    // Where the bubble needs to be built
    private func makePOIBubble(poi: POI) -> ModelEntity {
        //let model = ModelEntity(mesh: MeshResource.generateText(poi.BusinessName, extrusionDepth: 0.01, font: .boldSystemFont(ofSize: 0.1), containerFrame: .zero, alignment: .center,lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])
        let model = createPOIBubble(poi: poi)
        
       // First, rotate to make it flat
        model.transform.rotation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
       
       // Then, flip it backwards and upside down
        model.transform.rotation *= simd_quatf(angle: .pi, axis: [0, 1, 0]) // Flip backwards
        model.transform.rotation *= simd_quatf(angle: .pi, axis: [0, 0, 1]) // Flip upside down
//        model.position = [0, 0, 0]
        model.generateCollisionShapes(recursive: true)
        return model
    }

    // Creates POI bubble and returns anchor that the bubble is fixed to
    func createPOIBubble(poi: POI) -> ModelEntity {
        let leftMargin = -0.45
        let topMargin = 0.4
        let bottomMargin = -0.4
        let textSpacing = 0.1
        let bigFontSize = 0.1
        let mediumFontSize = 0.07
        let smallFontSize = 0.05
        
        let bubble = createBubble() // creates plane
        // TODO Instead of adding multiple ModelEntities to the same anchor directly, they could be grouped under a single Entity and that Entity can be added.
        //   https://developer.apple.com/documentation/realitykit/entity

        let businessNameText = create3dText(text: poi.BusinessName, x: leftMargin, y: topMargin, fontSize: bigFontSize)
        bubble.addChild(businessNameText)

        let businessType = "Business Type" // do we have this?
        let businessTypeText = create3dText(text: businessType, x: leftMargin, y: topMargin - textSpacing, fontSize: mediumFontSize)
        bubble.addChild(businessTypeText)

        let hours = "8 am to 9 pm" // this should be pulled from business open time
        let hoursText = create3dText(text: hours, x: leftMargin, y: topMargin - textSpacing * 2, fontSize: mediumFontSize)
        bubble.addChild(hoursText)

        let ratingText = create3dText(text: "Yelp Rating: \(poi.Rating!)/5 Stars", x: leftMargin, y: topMargin - textSpacing * 3, fontSize: mediumFontSize)
        bubble.addChild(ratingText)

        let promptText = create3dText(text: "Click for more information", x: leftMargin, y: bottomMargin, fontSize: smallFontSize)
        bubble.addChild(promptText)

        return bubble
    }
    
    func createTextEntity(text: String, fontSize: CGFloat = 0.1, color: UIColor = .black) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .boldSystemFont(ofSize: fontSize),
            containerFrame: CGRect.zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let material = SimpleMaterial(color: color, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
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
        let planeColor = UIColor(red: 170/255.0, green: 166/255.0, blue: 255/255.0, alpha: 0.80)

        let plane = ModelEntity(
            mesh: MeshResource.generatePlane(width: planeWidth, height: planeHeight, cornerRadius: planeCornerRadius),
                materials: [SimpleMaterial(color: planeColor, isMetallic: false)],
            collisionShape: ShapeResource.generateBox(width: planeWidth, height: planeHeight, depth: planeCollisionDepth),
                mass: planeCollisionMass
            )

        return plane
    }

    // Creates a POI bubble and places it at given position (The specified position part doesn't work yet)
//    func placePOI(poi: POI) {
//        let poiAnchor = createPOIBubble(poi: poi)
//        arView.scene.addAnchor(poiAnchor)
//        print("placePOI was called")
//    }
}

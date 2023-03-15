//
//  ViewController.swift
//  CapstoneARTestBed
//
//  Created by Jules Maslak on 2/2/23.
//

import UIKit
import RealityKit
import ARKit
import MapKit

class ViewController: UIViewController
{
    @IBOutlet var arView: ARView!
    let locationManager = CLLocationManager()
    var places: [MKMapItem] = []
    var currentLocation: CLLocation? = nil
    var currentHeading: CLHeading? = nil
    var initialLocation: CLLocation? = nil
    let viewOffset: Double = 30;
    let raycastAngleAccuracy: Double = 5;
    let raycastDistanceOffset: Double = 10;
    let findLocationsWithin: Double = 1000;
    
    override func viewDidLoad()
    {
        // Request auth for location use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        // get the orientation of the phone
        self.locationManager.startUpdatingHeading()
        
//        arView.debugOptions = [
//            //ARView.DebugOptions.showWorldOrigin,
//            //ARView.DebugOptions.showFeaturePoints,
//            //ARView.DebugOptions.showAnchorOrigins,
//            //ARView.DebugOptions.showSceneUnderstanding,
//            //ARView.DebugOptions.showAnchorGeometry
//          ]
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                           action: #selector(handleTap(recognizer:))))
        
//        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
//
//        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
    }
    
    func setupARView()
    {
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [//.horizontal,
                                 .vertical]
        
        // adds reflections and shadows IOS 12 + feature
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
    }
    
    // Object Placement
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer)
    {
        if currentLocation == nil || currentHeading == nil { return }
        
        let tapLocation = recognizer.location(in: arView)
        
        // Could also try existing plane inifinite
        let results = arView.raycast(from: tapLocation,
                                     allowing: .estimatedPlane,
                                     alignment: .vertical)
        
        
        for place in places
        {
            let itemPos = place.placemark.coordinate
            
            // get relative angle from phone to object
            let itemAngle = atan2(Double(itemPos.longitude) - currentLocation!.coordinate.longitude,
                                  Double(itemPos.latitude) - currentLocation!.coordinate.latitude)
            
            var currHeading = currentHeading!.trueHeading
            
            print("Heading: \(currHeading)")
            print("To Object: \(itemAngle)")
            
            // make sure the object is in view
            if itemAngle > currentHeading!.trueHeading + viewOffset
            || itemAngle < currentHeading!.trueHeading - viewOffset
            {
                continue
            }
            
            let distanceToItem = sqrt(pow(Double(itemPos.longitude) - currentLocation!.coordinate.longitude, 2)
                                    + pow(Double(itemPos.latitude) - currentLocation!.coordinate.latitude, 2))
            print("Distance to item: \(distanceToItem)")
            
            for plane in results
            {
//                 ┌               ┐
//                 |  1  0  0  tx  |
//                 |  0  1  0  ty  |
//                 |  0  0  1  tz  |
//                 |  0  0  0  1   |
//                 └               ┘
//               AR Kit World Transform location in matrix
                var planePos = plane.worldTransform.columns.3
                
                // Translate the arkit world transform space to the gps coordinate space based off the initial location
                planePos.x += Float(initialLocation!.coordinate.latitude)
                planePos.y += Float(initialLocation!.coordinate.longitude)
                
                let distanceToPlane = sqrt(pow(Double(planePos.y) - currentLocation!.coordinate.longitude, 2)
                                           + pow(Double(planePos.x) - currentLocation!.coordinate.latitude, 2))
                
                print("Dist to Plane: \(distanceToPlane)")
                
                if distanceToPlane > distanceToItem + raycastDistanceOffset
                    || distanceToPlane < distanceToItem - raycastDistanceOffset
                {
                    continue
                }
                
                let anchor = ARAnchor(name: "Generic", transform: plane.worldTransform)
                
                // add anchor to session
                arView.session.add(anchor: anchor)
                
                placeSphere(at: anchor)
                
                break
            }
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor)
    {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        // allow rotation and translation
        entity.generateCollisionShapes(recursive: true)
        
        arView.installGestures([.rotation, .translation],for: entity)
        
        // this might be wrong
        let anchorEntity = AnchorEntity(world: anchor.transform)
        
        anchorEntity.addChild(entity)
        
        // will probably need some method to dispose of unused anchors later
        
        arView.scene.addAnchor(anchorEntity)
    }
    
    func placeSphere(at anchor: ARAnchor)
    {
        let model = ModelEntity.init(mesh: MeshResource.generateSphere(radius: 0.2))
        
        let entity = AnchorEntity(world: anchor.transform)
        entity.addChild(model)
        
        arView.scene.addAnchor(entity)
    }
    
    // Map Stuff
    
    func search(around currentLocation: CLLocationCoordinate2D)
    {
        let searchRequest = MKLocalSearch.Request()
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = MKCoordinateRegion(center: currentLocation,
                                                  latitudinalMeters: findLocationsWithin,
                                                  longitudinalMeters: findLocationsWithin)
        
        searchRequest.resultTypes = [.address, .pointOfInterest]
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { [unowned self] (response, error) in
            guard error == nil
            else
            {
                print("failed to get locations")
                // need something here to sleep and try again in 30 ish seconds
                return
            }
            print("Found places")
            self.places = response?.mapItems ?? []
        }
    }
}

extension ViewController: ARSessionDelegate
{
    func session( _ session: ARSession, didAdd anchors: [ARAnchor])
    {
//        for anchor in anchors
//        {
//            placeSphere(at: anchor)
//            //placeObject(named: anchor.name ?? "anchor", for: anchor)
//        }
    }
}

extension ViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocation = manager.location else { return }
        print("location = \(locValue.coordinate.longitude) \(locValue.coordinate.latitude)")
        // search(around: locValue.coordinate) disabled to minimize requests in dev, need to limit this
        // more than 15 requests in 1 min and we get rate limited
        currentLocation = locValue
        
        if(initialLocation == nil)
        {
            initialLocation = locValue
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let heading = manager.heading else { return }
        currentHeading = heading
    }
}

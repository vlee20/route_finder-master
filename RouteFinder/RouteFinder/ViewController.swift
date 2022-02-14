//
//  ViewController.swift
//  RouteFinder
//
//  Created by Vincent Lee on 9/16/20.
//  Copyright © 2020 cpsc362. All rights reserved.
//
//Import all libraries
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate{
    //MARK: - IBOutlets
    //Link the map
    @IBOutlet weak var mapView: MKMapView!
    //Link the text fields
    @IBOutlet weak var latitudeTxtField: UITextField!
    
    @IBOutlet weak var longitudeTxtField: UITextField!
    
    @IBOutlet weak var bBtn: UIButton!
    
    @IBOutlet weak var rndNum: UITextField!
    @IBOutlet weak var randomRoute: UIButton!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var latText: UITextField!
    @IBOutlet weak var longText: UITextField!
    
    //MARK: - Variables
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    
    var myLocation: CLLocation!
    var movedToUserLocation = false
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func clearMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    


    
    @IBAction func randomRoute(_ sender: Any) {
        navgateRandom()
    }
    
    //Get Address function on button click
    @IBAction func getAddress(_ sender: Any) {
        dismissKeyboard()
        clearMap()
        getAdd()
        
    }
    
    //Gets longitude and latitude from address
    func getAdd()
    {
        if addressText.text != "" {
        let geocode = CLGeocoder();
        geocode.geocodeAddressString(addressText.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location
                else{
                    print("No location found.")
                let alert = UIAlertController(title: "Error!", message: "no location found", preferredStyle: .alert)

                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(ok)
                self.present(alert, animated: true)
                    return
                }
            print(location)
            
            //add destination pin w/ address
            let annotationView: MKAnnotationView!
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = location.coordinate
            pointAnnotation.title = "\(self.addressText.text!)"
            annotationView = MKAnnotationView(annotation: pointAnnotation, reuseIdentifier: "annotation2")
            self.mapView.addAnnotation(annotationView.annotation!)
            self.mapThis(destinationCord: location.coordinate)
        }
        } else {
            let alert = UIAlertController(title: "Error!", message: "Please enter in a valid address.", preferredStyle: .alert)

            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
        
        
        /*let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)))
        source.name = "Source"

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:)))
        destination.name = "Destination"

       */
    }
    
    
    func mapThis(destinationCord : CLLocationCoordinate2D){
        let sourceCoordinate = (locationManager.location?.coordinate)!;
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destPlacemark = MKPlacemark(coordinate: destinationCord)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let destinationReq = MKDirections.Request()
        
        destinationReq.source = sourceItem
        destinationReq.destination = destItem
        destinationReq.transportType = .automobile
        
        destinationReq.requestsAlternateRoutes = true
        
        
        let directions = MKDirections(request: destinationReq)
       
        directions.calculate{(response, error) in
            guard let response = response   else {
                if let error = error {
                    print(error)
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
            /*self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            */}
        
        
    }
    //Navigate to longitude and latitude function
    //new
    @objc func dropAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.clearMap()
            let holdLocation = gestureRecognizer.location(in: mapView)
            let coord = mapView.convert(holdLocation, toCoordinateFrom: mapView)

            let annotationView: MKAnnotationView!
            let pointAnnotation = MKPointAnnotation()

            pointAnnotation.coordinate = coord
            pointAnnotation.title = "\(coord.latitude), \(coord.longitude)"

            annotationView = MKAnnotationView(annotation: pointAnnotation, reuseIdentifier: "annotation2")
            mapView.addAnnotation(annotationView.annotation!)

            //turn to string
            latitudeTxtField.text = "\(coord.latitude)"
            longitudeTxtField.text = "\(coord.longitude)"
        }
    }
    

    @IBAction func navgate(_ sender: Any) {
        dismissKeyboard()
        print("testing navigate")
        if let latitudeTxt = latitudeTxtField.text, let longitudeTxt = longitudeTxtField.text {
            if latitudeTxt != "" && longitudeTxt != "" {
                if let lat = Double(latitudeTxt), let lon = Double(longitudeTxt) {
                    self.clearMap()
                    let coor = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                    let annotationView: MKPinAnnotationView!
                    let annotationPoint = MKPointAnnotation()
                    annotationPoint.coordinate = coor
                    annotationPoint.title = "\(lat), \(lon)"
                    annotationView = MKPinAnnotationView(annotation: annotationPoint, reuseIdentifier: "Annotation")
                    mapView.addAnnotation(annotationView.annotation!)
                    let directionsRequest = MKDirections.Request()
                    directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
                    directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: coor))
                    directionsRequest.requestsAlternateRoutes = false
                    directionsRequest.transportType = .any
                    let directions = MKDirections(request: directionsRequest)
                    directions.calculate {
                        response, error in
                        if let res = response {
                            //self.clearMap()
                            if let route = res.routes.first
                            {
                                self.mapView.addOverlay(route.polyline)
                                //mapView.add(route.polyline)
                                self.mapView.region.center = coor
                            }
                        } else {
                            print("error")
                            let alert = UIAlertController(title: "Error!", message: "not valid.", preferredStyle: .alert)

                            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            
                            alert.addAction(ok)
                            self.present(alert, animated: true)
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error!", message: "Please enter in a valid longitude and latitude.", preferredStyle: .alert)

                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
        }
    }
    //MARK: - UIViewController life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpMapView()
    
        let keyboardDiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(keyboardDiss)
        

        let pinDropper = UILongPressGestureRecognizer(target: self, action: #selector(self.dropAnnotation(gestureRecognizer:)))
        pinDropper.minimumPressDuration = CFTimeInterval(1.0)
        mapView.addGestureRecognizer(pinDropper)

        

        
        
    }
    
    //Navigate to a random route
    @IBAction func navgateRandom() {
        dismissKeyboard()
        print("testing navigate")
       
        if let latitudeTxt = latText.text,
           let longitudeTxt = longText.text {
            print(latitudeTxt, longitudeTxt)
            if latitudeTxt != "" && longitudeTxt != "" {
                

                let randomLat = (Double(rndNum.text!)! / 69.0);
                let randomLong = (Double(rndNum.text!)! / 69.0);
                
                if var lat = Double(latitudeTxt), var lon = Double(longitudeTxt) {
                    let coord = [ "n", "nw", "ne", "nnw", "nww", "nne", "nee", "w", "e", "s" , "sw" , "se", "ssw", "sww", "sse", "see" ]
                    //randomizes the coord
                    let randCoord = coord.randomElement()
                    switch randCoord {
                    case "n":
                        lat += randomLat
                        lon += 0
                    case "w":
                        lat += 0
                        lon -= randomLong
                    case "nw":
                        lat -= (randomLat * (sqrt(2)/2))
                        lon += (randomLong * (sqrt(2)/2))
                    case "ne":
                        lat += (randomLat * (sqrt(2)/2))
                        lon += (randomLong * (sqrt(2)/2))
                    case "nnw":
                        lat -= (randomLat * (1/2))
                        lon += (randomLong * (sqrt(3)/2))
                    case "nww":
                        lat -= (randomLat * (sqrt(3)/2))
                        lon += (randomLong * (1/2))
                    case "nne":
                        lat += (randomLat * (1/2))
                        lon += (randomLong * (sqrt(3)/2))
                    case "nee":
                        lat += (randomLat * (sqrt(3)/2))
                        lon += (randomLong * (1/2))
                    case "e":
                        lat += 0
                        lon += randomLong
                    case "s":
                        lat -= randomLat
                        lon += 0
                    case "sw":
                        lat -= (randomLat * (sqrt(2)/2))
                        lon -= (randomLong * (sqrt(2)/2))
                    case "se":
                        lat += (randomLat * (sqrt(2)/2))
                        lon -= (randomLong * (sqrt(2)/2))
                    case "ssw":
                        lat -= (randomLat * (1/2))
                        lon -= (randomLong * (sqrt(3)/2))
                    case "sww":
                        lat -= (randomLat * (sqrt(3)/2))
                        lon -= (randomLong * (1/2))
                    case "sse":
                        lat += (randomLat * (1/2))
                        lon -= (randomLong * (sqrt(3)/2))
                    case "see":
                        lat += (randomLat * (sqrt(3)/2))
                        lon -= (randomLong * (1/2))
                    default:
                        print("error")
                        
                    }
//                    lat += randomLat
//                    lon += randomLong
                    print(lat, lon)
                    self.clearMap()
                    let coor = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                    let annotationView: MKPinAnnotationView!
                    let annotationPoint = MKPointAnnotation()
                    annotationPoint.coordinate = coor
                    annotationPoint.title = "\(lat), \(lon)"
                    annotationView = MKPinAnnotationView(annotation: annotationPoint, reuseIdentifier: "Annotation")
                    mapView.addAnnotation(annotationView.annotation!)
                    let directionsRequest = MKDirections.Request()
                    directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
                    directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: coor))
                    directionsRequest.requestsAlternateRoutes = false
                    directionsRequest.transportType = .any
                    let directions = MKDirections(request: directionsRequest)
                    directions.calculate {
                        response, error in
                        if let res = response {
                            //self.clearMap()
                            if let route = res.routes.first
                            {
                                self.mapView.addOverlay(route.polyline)
                                //mapView.add(route.polyline)
                                self.mapView.region.center = coor
                            }
                        } else {
                            print("error")
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error!", message: "Please enter in a valid longitude and latitude.", preferredStyle: .alert)

                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
        }
    }
    
    //MARK: - Setup Methods
    func setUpMapView() {
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        
        currentLocation()
    }
    
    //MARK: - Helper Method
    func currentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
    }
    
    
}
//MARK: - CLLocationManagerDelegate Methods
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
        
        //Can probably be cleaned up a lot
        //Sets the textboxes to lat/long
        myLocation = locationManager.location;
        //myLocation = locationManager.location;
        
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse  || CLLocationManager.authorizationStatus() == .authorizedAlways){
        
        var longitude: String = String(myLocation!.coordinate.longitude)
        
        var latitude: String = String(myLocation!.coordinate.latitude)
        
        longText.text = longitude
        latText.text = latitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.strokeColor = .green
        renderer.lineWidth = 4.0
        return renderer
    }
    
}



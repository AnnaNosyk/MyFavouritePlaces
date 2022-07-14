//
//  MapVC.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 13/07/2022.
//

import UIKit
import MapKit
import CoreLocation


// for passed address  to the detail view controller
protocol MapVCDelegate {
    func getAddress(_ address: String?)
}

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPin: UIImageView!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var dirrectionOptionsLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var getDirectionButton: UIButton!
    
    
    var mapVCDelegate: MapVCDelegate?
    var place = MyPlace()
    let annotationIdentifier = "annotationIdentifier"
    var segueIdentifier = ""
    let locationManager = CLLocationManager()
    var coordinateofPlace: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previousLocation: CLLocation? {
        didSet {
            updateUserLocation()
        }
    }
    
    private let alert = Alert()
    private let constants = Constants()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        adressLabel.text = ""
        dirrectionOptionsLabel.text = ""
        setupMapView()
        checkUserLocation()
    }
    
    //chek from wchich segue
    private func setupMapView() {
        dirrectionOptionsLabel.isHidden = true
        getDirectionButton.isHidden = true
        if segueIdentifier == "onMapSegue" {
            setupPlacemark()
            getDirectionButton.isHidden = false
            dirrectionOptionsLabel.isHidden = false
            mapPin.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    //update directions, delete old direction from the array
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    private func setupPlacemark() {
        
        // take adress of the place
        guard let location = place.location else { return }
        
        //core location transform from adress to cootdimate
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            //detail for the placemark
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.comment
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            //coordinate of the place
            self.coordinateofPlace = placemarkLocation.coordinate

            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // get location on the center of the screen
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //cheking if location of user able or not
    
    private func checkUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alert.showAlert(
                    viewController: self, title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
                )
            }
        }
    }
    //create direction from user location to the place
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else {
            alert.showAlert(viewController: self, title: "Error", message: "Current location is not found")
            return
        }
        
        //update user location
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        // request for the direction
        guard let request = createRequest(from: location) else {
            alert.showAlert(viewController: self, title: "Error", message: "Destination is not found")
            return
        }
        
        //create direction by data location
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.alert.showAlert(viewController: self, title: "Error", message: "Directions is not available")
                return
            }
             
            //make direction on the map
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 500)
                let timeInterval = Int(route.expectedTravelTime / 60)
                
                self.dirrectionOptionsLabel.text = "Расстояние до места: \(distance) км. Время в пути составит: \(timeInterval) мин."
            }
        }
    }
    
    //setup request
    private func createRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = coordinateofPlace else { return nil }
        // start point of user coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        // destination of the direction
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        //request for the direction from start poin to finish
        let request = MKDirections.Request()
        //start point
        request.source = MKMapItem(placemark: startingLocation)
        //destination
        request.destination = MKMapItem(placemark: destination)
        //transport
        request.transportType = .walking
        //alternative directions
        request.requestsAlternateRoutes = true
        
        return request
    }

    
    private func setupLocationManager() {
        // location accuracy
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func checkLocationAuthorization() {
        //status of autorization
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getFromMapSegue" { showUserLocation() }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alert.showAlert(
                    viewController: self, title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location"
                )
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    
    private func showUserLocation() {
        // cheking user coordinate
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: constants.metersForLocation,
                                            longitudinalMeters: constants.metersForLocation)
            mapView.setRegion(region, animated: true)
    }
    
    }
    
    private func updateUserLocation() {
        //det user location
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        //update when distance more than 50 m
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }

    

    @IBAction func userLocationAction(_ sender: UIButton) {
        showUserLocation()
    }

    @IBAction func doneButtonAction(_ sender: UIButton) {
        mapVCDelegate?.getAddress(adressLabel.text)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func getDirectionAction(_ sender: UIButton) {
        getDirections()
    }
    
}

//MARK: - MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // placemark no location of user
        guard !(annotation is MKUserLocation) else { return nil }
        
        //view for annotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        //guard let imageData = place.imageData else {return nil}
        
       if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
        annotationView?.leftCalloutAccessoryView = imageView
       }
        
        return annotationView
    }
    
    // get adress for the label under the pin(crnter of the screen)
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        //center user location on the screen
        if segueIdentifier == "onMapSegue" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        // coordinate to adress
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.adressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.adressLabel.text = "\(streetName!)"
                } else {
                    self.adressLabel.text = ""
                }
            }
        }
    }
    
    // set overline on the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        renderer.lineWidth = 3
    
        
        return renderer
    }
}

//MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {

    // for user location in real time
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}



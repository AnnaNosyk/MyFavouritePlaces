//
//  MapKitManager.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 14/07/2022.
//

import UIKit
import MapKit


class MapKitManager {
    let locationManager = CLLocationManager()
    private let constants = Constants()
    var dirrectionOptions = ""
   private  var coordinateofPlace: CLLocationCoordinate2D?
   private var directionsArray: [MKDirections] = []
   private let metersForLocation = Double(1000)
    
   private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: constants.okStr, style: .default)
        
        alert.addAction(okAction)
       
       let alertWindow = UIWindow(frame: UIScreen.main.bounds)
       alertWindow.rootViewController = UIViewController()
       alertWindow.windowLevel = UIWindow.Level.alert + 1
       alertWindow.makeKeyAndVisible()
       alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func setupPlacemark(place: MyPlace, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.comment
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            //coordinate of the place
            self.coordinateofPlace = placemarkLocation.coordinate

            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //cheking if location of user able or not
     func checkUserLocation(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: self.constants.noLocationStr,
                               message: self.constants.goToSettingsStr
                )
            }
        }
    }
    
     func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        //status of autorization
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == constants.getFromMapSegue { showUserLocation(mapView: mapView) }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: self.constants.locationIsNotAvailableStr,
                               message: self.constants.givePermitionSettingsStr
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
    
    
     func showUserLocation(mapView: MKMapView) {
        // cheking user coordinate
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: metersForLocation,
                                            longitudinalMeters: metersForLocation)
            mapView.setRegion(region, animated: true)
    }
    
    }
    
    //create direction from user location to the place
     func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: constants.errorStr, message: constants.locationNotFoundStr)
            return
        }
        
        //update user location
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        // request for the direction
         guard let request = createRequest(from: location) else { showAlert(title: constants.errorStr, message: constants.destinationNotFoundStr)
            return
        }
        
        //create direction by data location
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
         directions.calculate { [self] (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: self.constants.errorStr, message: self.constants.directionsnotAvailableStr)
                return
            }
             
            //make direction on the map
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 500)
                let timeInterval = Int(route.expectedTravelTime / 60)
                
                self.dirrectionOptions = "\(constants.distanceToStr) \(distance) \(constants.kmStr) \(constants.travelTimeStr) \(timeInterval) \(constants.minStr)"
                
            }
        }
    }
    
    
    //setup request
     func createRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    
     func updateUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        //get user location
         guard let location = location else { return }
         let center = getCenterLocation(for: mapView)
         guard center.distance(from: location) > 50 else { return }
         
         closure(center)
    }
    
    
    //update directions, delete old direction from the array
     func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    // get location on the center of the screen
     func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }

}


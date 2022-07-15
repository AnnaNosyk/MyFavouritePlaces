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
    
    let mapManager = MapKitManager()
    var mapVCDelegate: MapVCDelegate?
    
    var place = MyPlace()
    let annotationIdentifier = "annotationIdentifier"
    var segueIdentifier = ""
   
   
    var previousLocation: CLLocation? {
        didSet {
            mapManager.updateUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                    self.previousLocation = currentLocation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.showUserLocation(mapView: self.mapView)
                    }
            }
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
    }
    
    //chek from wchich segue
    private func setupMapView() {
        dirrectionOptionsLabel.isHidden = true
        getDirectionButton.isHidden = true
        mapManager.checkUserLocation(mapView: mapView, segueIdentifier: segueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        if segueIdentifier == constants.showPlaceLocationSegue {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            getDirectionButton.isHidden = false
            dirrectionOptionsLabel.isHidden = false
            mapPin.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    @IBAction func userLocationAction(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
    }

    @IBAction func doneButtonAction(_ sender: UIButton) {
        mapVCDelegate?.getAddress(adressLabel.text)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func getDirectionAction(_ sender: UIButton) {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.dirrectionOptionsLabel.text =  self.mapManager.dirrectionOptions
        }
       
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
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        //center user location on the screen
        if segueIdentifier == constants.showPlaceLocationSegue && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
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
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
    }
}



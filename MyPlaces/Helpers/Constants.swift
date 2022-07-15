//
//  Constants.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 08/07/2022.
//

import UIKit

class Constants {
    
    let heightForRows = CGFloat(85)
    let heightForImages = CGFloat(65)
    
    //segue identifiers
    let showPlaceLocationSegue = "onMapSegue"
    let getFromMapSegue = "getFromMapSegue"
    let showEditScreenSegue = "EditSegue"
    
    //keys
     let keyPathDate = "date"
    let keyPathName = "name"
    let alertImageKey = "image"
    let alertTitleKey = "titleTextAlignment"
    
    //image names
    let sortDownImage = "arrow.down.square"
    let sortUpImage = "arrow.up.square"
    let temporaryImageOfItem = "building.2.crop.circle"
    let cameraImage = "camera"
    let galleryImage = "photo"
    let emptyStarRating = "star"
    let fullStarRating = "star.fill"
    
    
    // string constants
    let errorStr = "Error".localized()
    let okStr = "Ok".localized()
    let cameraStr = "Camera".localized()
    let gakkeryStr = "Gallery".localized()
    let cancelStr = "Cancel".localized()
    let noLocationStr = "Location Services are Disabled".localized()
    let goToSettingsStr = "To enable it go: Settings -> Privacy -> Location Services and turn On".localized()
    let locationIsNotAvailableStr = "Your Location is not Available".localized()
    let givePermitionSettingsStr = "To give permission Go to: Setting -> MyPlaces -> Location".localized()
    let locationNotFoundStr = "Current location is not found".localized()
    let destinationNotFoundStr = "Destination is not found".localized()
    let directionsnotAvailableStr =  "Directions is not available".localized()
    let distanceToStr = "Distance to place: ".localized()
    let travelTimeStr = "Travel time will be: ".localized()
    let kmStr = "km.".localized()
    let minStr = "min.".localized()

}

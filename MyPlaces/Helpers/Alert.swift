//
//  Alert.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 10/07/2022.
//

import UIKit

class Alert {
    private let constants = Constants()
    
    func alert(viewController: UIViewController, cameraComplitionHandler:@escaping (UIAlertAction)->Void, galleryComplitionHandler:@escaping (UIAlertAction)->Void) {
        let cameraIcon = UIImage(systemName: constants.cameraImage)
        let galleryIcon = UIImage(systemName: constants.galleryImage)
        let alert = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: constants.cameraStr, style: .default, handler: cameraComplitionHandler)
        camera.setValue(cameraIcon, forKey: constants.alertImageKey)
        camera.setValue(CATextLayerAlignmentMode.left, forKey: constants.alertTitleKey)
    
        
        let gallery = UIAlertAction(title: constants.gakkeryStr, style: .default, handler: galleryComplitionHandler)
        gallery.setValue(galleryIcon, forKey: constants.alertImageKey)
        gallery.setValue(CATextLayerAlignmentMode.right, forKey: constants.alertTitleKey)
    
        
        let cancel = UIAlertAction(title: constants.cancelStr, style: .cancel)
        
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        
        viewController.present(alert, animated: true)
    }
}

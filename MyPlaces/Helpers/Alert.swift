//
//  Alert.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 10/07/2022.
//

import UIKit

class Alert {
    func alert(viewController: UIViewController, cameraComplitionHandler:@escaping (UIAlertAction)->Void, galleryComplitionHandler:@escaping (UIAlertAction)->Void) {
        let cameraIcon = UIImage(systemName: "camera")
        let galleryIcon = UIImage(systemName: "photo")
        let alert = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: cameraComplitionHandler)
        camera.setValue(cameraIcon, forKey: "image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
    
        
        let gallery = UIAlertAction(title: "Gallery", style: .default, handler: galleryComplitionHandler)
        gallery.setValue(galleryIcon, forKey: "image")
        gallery.setValue(CATextLayerAlignmentMode.right, forKey: "titleTextAlignment")
    
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        
        viewController.present(alert, animated: true)
    }
}

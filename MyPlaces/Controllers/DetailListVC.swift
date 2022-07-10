//
//  DetailListVC.swift
//  MyFavouritePlaces
//
//  Created by Anna Nosyk on 10/07/2022.
//

import UIKit

class DetailListVC: UITableViewController {
    
    @IBOutlet weak var imageOfItem: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
   
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let alert = Alert()

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        locationTextField.delegate = self
        commentTextField.delegate = self

    }
    
    // MARK:-  Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //hide keyboard when tap on the screen, exept 0 row
        if indexPath.row == 0 {
            alert.alert(viewController: self) { _ in
                self.chooseImagePicker(source: .camera)
            } galleryComplitionHandler: { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }

        } else {
            view.endEditing(true)
        }
    }

}

// MARK:- UITextFieldDelegate
extension DetailListVC: UITextFieldDelegate {
    
    //hide keyboard on return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

    // MARK: - UIImagePickerControllerDelegate

extension DetailListVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // chose source of image
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    // change image from camera or gallery
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageOfItem.image = info[.editedImage] as? UIImage
        imageOfItem.contentMode = .scaleAspectFill
        imageOfItem.clipsToBounds = true
        dismiss(animated: true)
    }
}


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

    
    @IBOutlet weak var ratingStars: RatingStars!
    
    
    
    var currentPlace: MyPlace!
    var imageIsChanged = false
    let alert = Alert()

    override func viewDidLoad() {
        super.viewDidLoad()
      
        nameTextField.delegate = self
        locationTextField.delegate = self
        commentTextField.delegate = self
        saveButton.isEnabled = false
        
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        editPlace()

    }
    
    // edit navigation bar
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }

    
    // saving places
    func saveItem() {
        
        let image = imageIsChanged ? imageOfItem.image : UIImage(systemName: "building.2.crop.circle")
     
        let imageData = image?.pngData()
        
        let newPlace = MyPlace(name: nameTextField.text!, location: locationTextField.text, comment: commentTextField.text, imageData: imageData, rating: ratingStars.rating)
        
        //edit place
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.comment = newPlace.comment
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            //save new place
            StorageManager.saveObject(newPlace)
        }
        
    }
        
    //for editing items
    private func editPlace() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            imageOfItem.image = image
            imageOfItem.contentMode = .scaleAspectFill
            nameTextField.text = currentPlace?.name
            locationTextField.text = currentPlace?.location
            commentTextField.text = currentPlace?.comment
            ratingStars.rating = currentPlace.rating
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "mapVCSegue" { return }
        
        let mapVC = segue.destination as! MapVC
        mapVC.place.name = nameTextField.text!
        mapVC.place.comment = commentTextField.text
        mapVC.place.imageData = imageOfItem.image?.pngData()
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
    
    // go to main list
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension DetailListVC: UITextFieldDelegate {
    
    //hide keyboard on return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if nameTextField.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
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
        imageIsChanged = true
        dismiss(animated: true)
    }
}


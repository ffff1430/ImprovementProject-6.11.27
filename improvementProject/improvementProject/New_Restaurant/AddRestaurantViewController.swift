//
//  AddRestaurantViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/28.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit
import CoreData

protocol GetNewRestaurantData: AnyObject{
    func didSetNewRestaurant(newRestaurantData: ArrangeRestaurantBaseInfo)
}

class AddRestaurantViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    weak var delegate: GetNewRestaurantData?
    
    let presetImage = UIImage(systemName: "photo")
    
    var restaurant: RestaurantMO?
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    
    @IBOutlet weak var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet weak var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 5.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var photoImage: UIImageView! {
        didSet {
            photoImage.image = presetImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTap(#selector(self.dismissKeyboard))
        saveButton.isEnabled = true
    }
    
    func hideKeyboardOnTap(_ selector: Selector) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let presetImage = presetImage else { return }
        if nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == "" ||
            photoImage.image?.isEqual(to: presetImage) ?? false{
            let alertController = UIAlertController(title: "錯誤", message: "還有空格沒輸入，沒有空格才能進行儲存", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        } else {
            saveButton.isEnabled = false
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
                restaurant?.name = nameTextField.text
                restaurant?.type = typeTextField.text
                restaurant?.location = addressTextField.text
                restaurant?.phone = phoneTextField.text
                restaurant?.summary = descriptionTextView.text
                restaurant?.isVisited = false
                
                if let restaurantImage = photoImage.image {
                    restaurant?.image = restaurantImage.pngData()
                }
                
                appDelegate.saveContext()
            }
            
            delegate?.didSetNewRestaurant(newRestaurantData: ArrangeRestaurantBaseInfo (
                image: photoImage.image?.pngData(),
                isVisited: false,
                name: nameTextField.text ?? "",
                type: typeTextField.text ?? "",
                location: addressTextField.text ?? "",
                phone: phoneTextField.text ?? "",
                description: descriptionTextView.text ?? ""))
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionImageButton(_ sender: Any) {
        let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        photoSourceRequestController.addAction(cancelAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        
        present(photoSourceRequestController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
               photoImage.image = selectedImage
               photoImage.contentMode = .scaleAspectFill
               photoImage.clipsToBounds = true
           }
           
           dismiss(animated: true, completion: nil)
       }
}

extension AddRestaurantViewController: UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
}


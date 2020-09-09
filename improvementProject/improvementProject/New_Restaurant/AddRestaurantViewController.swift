//
//  AddRestaurantViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/28.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit
import CoreData

//修改CodingStyle
protocol GetNewRestaurantData: AnyObject {
    func didSetNewRestaurant(newRestaurantData: ArrangeRestaurantBaseInfo)
}

class AddRestaurantViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    weak var delegate: GetNewRestaurantData?
    
    private let presetImage = UIImage(systemName: "photo")
    
    private var restaurant: RestaurantMO?
    
    @IBOutlet weak var saveButton: UIButton!
    
    private var urlstr: URL?
    
    @IBOutlet weak var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.becomeFirstResponder()
        }
    }
    
    @IBOutlet weak var typeTextField: RoundedTextField!
    
    @IBOutlet weak var addressTextField: RoundedTextField!
    
    @IBOutlet weak var phoneTextField: RoundedTextField!
    
    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
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
        setTextField()
    }
    
    func setTextField() {
        setSettingInTextField(textfield: nameTextField, tag: 1)
        setSettingInTextField(textfield: typeTextField, tag: 2)
        setSettingInTextField(textfield: addressTextField, tag: 3)
        setSettingInTextField(textfield: phoneTextField, tag: 4)
        descriptionTextView.tag = 5
    }
    
    //把delegate指定給TextField
    func setSettingInTextField(textfield: UITextField, tag: Int) {
        textfield.delegate = self
        textfield.tag = tag
    }
    
    private func hideKeyboardOnTap(_ selector: Selector) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //已作修正改成用func去判斷TextField是否為空值
    func checkTextFieldisEmpty() -> Bool {
        if nameTextField.text?.isEmpty ?? true || typeTextField.text?.isEmpty ?? true || phoneTextField.text?.isEmpty ?? true || addressTextField.text?.isEmpty ?? true || descriptionTextView.text.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let presetImage = presetImage else { return }
        if checkTextFieldisEmpty() {
            alertAction(message: "還有空格沒輸入，沒有空格才能進行儲存")
            //已作修正直接使用 isEqual(Any)就可以了，之前做法是多餘的
        } else if photoImage.image?.isEqual(presetImage) ?? false {
            alertAction(message: "還有圖片沒放，圖片要有才能進行儲存")
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
                restaurant?.image = urlstr
                
                appDelegate.saveContext()
            }
            
            delegate?.didSetNewRestaurant(newRestaurantData: ArrangeRestaurantBaseInfo (
                image: urlstr,
                isVisited: false,
                name: nameTextField.text ?? "",
                type: typeTextField.text ?? "",
                location: addressTextField.text ?? "",
                phone: phoneTextField.text ?? "",
                description: descriptionTextView.text ?? ""))
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    //alert改成在func做
    func alertAction(message: String) {
        let alertController = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
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
        
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            urlstr = imgUrl
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


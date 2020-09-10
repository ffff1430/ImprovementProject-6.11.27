//
//  AddRestaurantViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/28.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit
import CoreData

class AddRestaurantViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    @IBOutlet weak var photoImage: UIImageView!
    
    //判斷有無照片
    private var notUpdateImage: Bool = true
    
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
    
    //修改這個方法
    func checkTextFieldisEmpty() -> Bool {
        let name = nameTextField.text ?? ""
        let type = typeTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        let address = addressTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        guard !name.isEmpty, !type.isEmpty, !phone.isEmpty, !address.isEmpty, !description.isEmpty else {
            return true
        }
        return false
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if checkTextFieldisEmpty(){
            alertAction(message: "還有空格沒輸入，沒有空格才能進行儲存")
            //已作修正直接使用 isEqual(Any)就可以了，之前做法是多餘的
        } else if notUpdateImage {
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
                restaurant?.updateAt = NSDate() as Date
                
                appDelegate.saveContext()
            }
            
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
            //更換照片時更新這個變數
            notUpdateImage = false
            
            //得到圖片的URL
            if picker.sourceType == .camera {
                let imgName = UUID().uuidString
                let documentDirectory = NSTemporaryDirectory()
                let localPath = documentDirectory.appending(imgName)
                
                guard let data = selectedImage.jpegData(compressionQuality: 0.3) as NSData? else {return}
                data.write(toFile: localPath, atomically: true)
                urlstr = URL.init(fileURLWithPath: localPath)
            } else {
                if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    urlstr = imgUrl
                    print(imgUrl)
                }
            }
            
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


//
//  UserSettingsViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 11/3/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UserSettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var phone:String!
    let userD = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    var edit = false
    var keyboardHigth:CGFloat = 0.0
    var activeField:UITextField? = nil
    var code = "+52"
    var mail:String!
        
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var Salir: UIBarButtonItem!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var editaguarda: UIBarButtonItem!
    @IBOutlet weak var inicioCam: UIButton!
    @IBOutlet weak var galeria: UIButton!
    @IBOutlet weak var flagZone: UIImageView!
    
        
    let workingView = UIActivityIndicatorView()
    let backView = UIView()
        
    @IBOutlet var changeArea: UITapGestureRecognizer!
    
    @IBAction func areaZoneFree(_ sender: Any) {
        if code == "+52"{
            code = "+1"
            flagZone.image = UIImage(named: "flag_usa.png")
        }else{
            code = "+52"
            flagZone.image = UIImage(named: "flag_mexico.png")
        }
    }
    
    @IBAction func guarda(_ sender: Any) {
            backView.frame = view.frame
            backView.frame.origin = view.frame.origin
            backView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
            workingView.activityIndicatorViewStyle = .whiteLarge
            workingView.hidesWhenStopped = true
            workingView.center = backView.center
            backView.addSubview(workingView)
            workingView.startAnimating()
            
            if edit {
                if (self.nameText.text == "" || self.phoneText.text == "")
                {
                    self.alert(message: "Por favor llena los datos necesarios")
                    return
                }
                else{
                    
                    self.view.addSubview(backView)
                    firebaseManager.init().saveUserPhotoFB(photo: userPhoto.image!, phone: (self.code + self.phoneText.text!), completion:{
                        firebaseManager.init().setUserSetting(phone: (self.code + self.phoneText.text!),
                                                              name: self.nameText.text!,
                                                              mail: self.mail)
                        self.edit = false
                        self.editaguarda.tintColor = UIColor.yellow
                        self.editaguarda.title = "Editar"
                        self.workingView.stopAnimating()
                        self.backView.removeFromSuperview()
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }else{
                nameText.isEnabled = true
                inicioCam.isEnabled = true
                galeria.isEnabled = true
                editaguarda.tintColor = UIColor.red
                editaguarda.title = "Guardar"
                edit = true
            }
        }
        
        @IBAction func Salir(_ sender: Any) {
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
        override func viewDidAppear(_ animated: Bool) {
            let status = PHPhotoLibrary.authorizationStatus()
            if status != .authorized {
                PHPhotoLibrary.requestAuthorization() {
                    status in
                }
            }
        }
        
        override func viewDidLoad() {
            
            imagePicker.delegate = self
            nameText.delegate = self
            phoneText.delegate = self
            
            nameText.layer.cornerRadius = 4
            nameText.layer.borderColor = UIColor.white.cgColor
            nameText.layer.borderWidth = 1.0
            
            phoneText.layer.cornerRadius = 4
            phoneText.layer.borderWidth = 1.0
            phoneText.layer.borderColor = UIColor.white.cgColor
            
            
            self.nameText.text = self.userD.string(forKey: "OwnerName") ?? ""
            self.phone = self.userD.string(forKey: "OwnerPhone") ?? ""
            self.mail = self.userD.string(forKey: "OwnerMail") ?? ""
            
            self.userPhoto.image = firebaseManager.init().getMemberPhoto(phone: self.phone)
            
            if (self.nameText.text == ""){
                self.Salir.isEnabled = false
                nameText.isEnabled = true
                phoneText.isEnabled = true
                inicioCam.isEnabled = true
                galeria.isEnabled = true
                editaguarda.tintColor = UIColor.red
                editaguarda.title = "Guardar"
                edit = true
            }else{
                nameText.isEnabled = false
                phoneText.isEnabled = false
                inicioCam.isEnabled = false
                galeria.isEnabled = false
            }
            
            registerForKeyboardNotifications()
        }
        
        @IBAction func inicioGaleria(_ sender: Any) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true,completion: nil)
            }
        }
        
        @IBAction func inicioCamView(_ sender: Any) {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
                imagePicker.cameraCaptureMode = .photo
                self.present(imagePicker, animated: true,completion: nil)
            }
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            self.dismiss(animated: true, completion: nil)
            
            if mediaType.isEqual(to: kUTTypeImage as String) {
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                if(image.size.width > image.size.height){
                    let imagenRec:UIImage =  cropToBounds(image: image, width: Double(image.size.width), height: Double(image.size.width))
                    self.userPhoto.image = resizeImage(image: imagenRec, newSize: CGSize(width: 130, height: 130))
                }
                if(image.size.width < image.size.height){
                    let imagenRec:UIImage =  cropToBounds(image: image, width: Double(image.size.height), height: Double(image.size.height))
                    self.userPhoto.image =  imageRotatedByDegrees(oldImage: resizeImage(image: imagenRec, newSize: CGSize(width: 130, height: 130)), deg: 90.0)
                }
                else{
                    self.userPhoto.image = resizeImage(image: image, newSize: CGSize(width: 130, height: 130))
                }
            }
        }
        
        func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
            
            if error != nil {
                let alert = UIAlertController(title: "Ups...",
                                              message: "Algo Fallo...",
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Listo",
                                                 style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                self.present(alert, animated: true,
                             completion: nil)
            }
        }
        
        func registerForKeyboardNotifications(){
            //Adding notifies on keyboard appearing
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWasShown(notification:)),
                                                   name: NSNotification.Name.UIKeyboardWillShow,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWillBeHidden(notification:)),
                                                   name: NSNotification.Name.UIKeyboardWillHide,
                                                   object: nil)
        }
        
        func deregisterFromKeyboardNotifications(){
            //Removing notifies on keyboard appearing
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        
        @objc func keyboardWasShown(notification: NSNotification){
            //Need to calculate keyboard exact size due to Apple suggestions
            var info = notification.userInfo!
            if keyboardHigth == 0.0 {
                let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
                keyboardHigth = keyboardSize!.height / 4
            }
            self.view.frame.origin.y -= keyboardHigth
        }
        
        @objc func keyboardWillBeHidden(notification: NSNotification){
            //Once keyboard disappears, restore original positions
            self.view.frame.origin.y += keyboardHigth
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField){
            activeField = textField
        }
        
        func textFieldDidEndEditing(_ textField: UITextField){
            activeField = nil
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            deregisterFromKeyboardNotifications()
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true) //This will hide the keyboard
        }
}

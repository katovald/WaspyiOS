//
//  userSettings.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

class userSettings: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var userPhoto: UIImageView!
    
    @IBOutlet weak var mailText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var editaguarda: UIBarButtonItem!
    
    var media: Bool?
    
    @IBAction func guarda(_ sender: Any) {
        if (inicioCam.isEnabled == false)
        {
            self.editaguarda.title = "Guarda"
            self.editaguarda.tintColor = UIColor.red
            self.mailText.isEnabled = true
            self.nameText.isEnabled = true
            self.inicioCam.isEnabled = true
        }
        else{
            self.editaguarda.title = "Edita"
            self.editaguarda.tintColor = UIColor.white
            self.mailText.isEnabled = false
            self.nameText.isEnabled = false
            self.inicioCam.isEnabled = false
        }
    }
    override func viewDidLoad() {
        self.title = "Cuenta"
        self.inicioCam.isEnabled = false
        self.editaguarda.title = "Edita"
        self.mailText.isEnabled = false
        self.nameText.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    @IBAction func inicioCamView(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true,completion: nil)
            media = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            userPhoto.image = image
            
            if (media == true) {
                UIImageWriteToSavedPhotosAlbum(image, self,
                                               #selector(userSettings.image(image:didFinishSavingWithError:contextInfo:)), nil)
            } else if mediaType.isEqual(to: kUTTypeMovie as String) {
                // Code to support video here
            }
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                         completion: nil)
        }
    }
    
    @IBOutlet weak var inicioCam: UIButton!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
}

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
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class userSettings: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    let almacen = Storage.storage()
    
    @IBOutlet weak var Salir: UIBarButtonItem!
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
            self.editaguarda.title = "Editar"
            self.editaguarda.tintColor = UIColor(colorLiteralRed: 244, green: 203, blue: 28, alpha: 100)
            self.mailText.isEnabled = false
            self.nameText.isEnabled = false
            self.inicioCam.isEnabled = false
            enviaDatosFB()
            
        }
    }
    override func viewDidLoad() {
        if (UserDefaults.standard.string(forKey: "Nombre") == nil){
            self.Salir.isEnabled = false
        }
        var datosPic:Data? = nil
        let userPictureLocation = almacen.reference(forURL: "gs://camasacontigo.appspot.com")
        let userPicture = userPictureLocation.child("/CAMUserPhotos/" + "+525530127033")
        userPicture.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                datosPic = data
            }
        }
        if (datosPic != nil)
        {
            let imageData = UIImage(data: datosPic!)
            let variable = UIImagePNGRepresentation(imageData!)
            let docDir = try! FileManager.default.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageURL = docDir.appendingPathComponent("waspyUser.png")
            try! variable?.write(to: imageURL)
        }
        
        self.inicioCam.isEnabled = false
        self.editaguarda.title = "Editar"
        self.mailText.isEnabled = false
        self.mailText.setBottomBorder(color: .white)
        self.nameText.isEnabled = false
        self.nameText.setBottomBorder(color: .white)
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
            let image = resizeImage(image: info[UIImagePickerControllerOriginalImage]
                as! UIImage, newSize: CGSize(width: 130, height: 130))
            
            userPhoto.image = image
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
    
    @IBOutlet weak var inicioCam: UIButton!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
    
    func enviaDatosFB()
    {
        showActivityIndicatory(uiView: self.view)
        
        let reference = almacen.reference(forURL: "gs://camasacontigo.appspot.com/CAMUserPhotos/")
        
        let imageData: Data = UIImagePNGRepresentation(userPhoto.image!)!
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        reference.child("+525547666122" + ".png").putData(imageData, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                print(error ?? "")
                self.stopActivityIndicator()
                return
            }
            self.stopActivityIndicator()
        }
    }
    
    func showActivityIndicatory(uiView: UIView) {
        let container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: self.view.center.x - 20, y: self.view.center.y - 20, width: 40.0, height: 40.0)
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2);
        
        
        uiView.addSubview(container)
        uiView.addSubview(actInd)
        actInd.startAnimating()
    }
    
    func stopActivityIndicator() {
        for view in self.view.subviews {
            if (view.accessibilityIdentifier == "actInd")
            {
                view as! UIActivityIndicatorView
                //view.stopAnimating()
            }
        }
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        context!.interpolationQuality = CGInterpolationQuality.default
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        
        context!.concatenate(flipVertical)
        // Draw into the context; this scales the image
        context?.draw(image.cgImage!, in: CGRect(x: 0.0,y: 0.0, width: newRect.width, height: newRect.height))
        
        let newImageRef = context!.makeImage()! as CGImage
        let newImage = UIImage(cgImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }

}

extension UITextField
{
    func setBottomBorder(color:UIColor)
    {
        self.borderStyle = UITextBorderStyle.bezel;
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}

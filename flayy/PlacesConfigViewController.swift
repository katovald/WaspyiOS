//
//  PlacesConfigViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class PlacesConfigViewController: UIViewController {
    @IBOutlet weak var eliminar: UIButton!
    @IBOutlet weak var radio: UISlider!
    @IBOutlet weak var vistaMapa: UIView!
    @IBOutlet weak var texto: UITextField!
    @IBOutlet weak var tipo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tipo.image = resizeImage(image: UIImage(named: "ic28_casita.jpg")!, newSize: CGSize(width: 35, height: 35))
        tipo.layer.borderWidth = 1
        tipo.layer.masksToBounds = false
        tipo.clipsToBounds = true
        radio.isEnabled=false
        vistaMapa.isUserInteractionEnabled = false
        texto.isEnabled = false
        eliminar.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

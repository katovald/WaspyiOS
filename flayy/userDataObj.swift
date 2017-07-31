//
//  userDataObj.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/14/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class imageMan {
    
    
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage{
        
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
    
    func roundPict(image: UIImage) -> UIImageView{
        let fotoview = UIImageView()
        fotoview.image = image
        fotoview.layer.borderWidth = 1
        fotoview.layer.masksToBounds = false
        fotoview.backgroundColor = UIColor.blue
        fotoview.layer.cornerRadius = fotoview.frame.height/2
        fotoview.clipsToBounds = true
        
        return fotoview
    }
}

class tableCell: UITableViewCell {
    
    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var ditintivo: UIImageView!
}



//
//  utils.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 8/30/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import Foundation
import AVKit

func delay(_ delay: Double, block:@escaping ()->())
{
    let nSecDispatchTime = DispatchTime.now() + delay;
    let queue = DispatchQueue.main
    
    queue.asyncAfter(deadline: nSecDispatchTime, execute: block)
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

func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
    
    let contextSize: CGSize = image.size
    
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(width)
    var cgheight: CGFloat = CGFloat(height)
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    
    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImage = image.cgImage!.cropping(to: rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let result:UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    
    return result
}

func blurEffect(foto: UIImage, contexto: CIContext) -> UIImage{
    
    let currentFilter = CIFilter(name: "CIGaussianBlur")
    let beginImage = CIImage(image: foto)
    currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
    currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
    
    let cropFilter = CIFilter(name: "CICrop")
    cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
    cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
    
    let output = cropFilter!.outputImage
    let cgimg = contexto.createCGImage(output!, from: output!.extent)
    let processedImage = UIImage(cgImage: cgimg!)
    return processedImage
}

func randomAlphaNumericString(length: Int) -> String {
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.characters.count)
    var randomString = ""
    
    for _ in 0..<length {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        randomString += String(newCharacter)
    }
    
    return randomString
}

//
//  PicMemberCollectionViewCell.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/20/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class PicMemberTableViewCell: UITableViewCell, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var battery: UIImageView!
    @IBOutlet weak var roundPic: UIImageView!
    @IBOutlet weak var markerPic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var adress: UILabel!
    @IBOutlet weak var battPercent: UILabel!
    @IBOutlet weak var plusBtn: UIButton!
    
    var visible:Bool!
    var phoneNumber:String!
    let userPhone: String = {
        return UserDefaults.standard.string(forKey: "OwnerPhone")!
    }()
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
    
    func membersInit (pic: UIImage, adress: String, nombre: String, battery: Int, speed: Int, visible: Bool, telefono: String)
    {
        self.name.text = nombre
        self.name.textColor = UIColor.init(hex: 0x3871B4)
        self.adress.text = adress
        self.adress.textColor = UIColor.init(hex: 0x3871B4)
        self.visible = visible
        self.phoneNumber = telefono
        
        if phoneNumber == userPhone {
            plusBtn.isHidden = true
        }
        roundPic.layer.borderWidth = 2
        roundPic.layer.masksToBounds = false
        roundPic.layer.cornerRadius = roundPic.frame.height/2
        roundPic.clipsToBounds = true
        if self.visible {
            self.roundPic.image = pic
            roundPic.layer.borderColor = UIColor.green.cgColor
        }else{
            self.roundPic.image = blurEffect(foto: pic, contexto: CIContext.init())
            roundPic.layer.borderColor = UIColor.red.cgColor
        }
        
        self.battPercent.text = String(battery) + "%"
        self.battPercent.textColor = UIColor.init(hex: 0x3871B4)
        
        if battery == 0
        {
            self.battery.image = UIImage(named: "ic_battery_0.png")?.maskWithColor(color: UIColor.red)
        }
        
        if battery > 0 && battery <= 10
        {
            self.battery.image = UIImage(named: "ic_battery_10.png")?.maskWithColor(color: UIColor.red)
        }
        
        if battery > 10 && battery <= 30
        {
            self.battery.image = UIImage(named: "ic_battery_30.png")?.maskWithColor(color: UIColor.yellow)
        }
        
        if battery > 30 && battery <= 50
        {
            self.battery.image = UIImage(named: "ic_battery_50.png")?.maskWithColor(color: UIColor.yellow)
        }
        
        if battery > 50 && battery <= 70
        {
            self.battery.image = UIImage(named: "ic_battery_70.png")?.maskWithColor(color: UIColor.green)
        }
        
        if battery > 70
        {
            self.battery.image = UIImage(named: "ic_battery_100.png")?.maskWithColor(color: UIColor.green)
        }
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}

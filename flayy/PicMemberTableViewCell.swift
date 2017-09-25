//
//  PicMemberCollectionViewCell.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/20/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class PicMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var battery: UIImageView!
    @IBOutlet weak var roundPic: UIImageView!
    @IBOutlet weak var markerPic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var adress: UILabel!
    
    
    func membersInit (pic: UIImage, adress: String, nombre: String, battery: Int, speed: Int)
    {
        self.name.text = nombre
        self.adress.text = adress
        self.roundPic.image = pic
        roundPic.layer.borderWidth = 1
        roundPic.layer.masksToBounds = false
        roundPic.backgroundColor = UIColor.blue
        roundPic.layer.cornerRadius = roundPic.frame.height/2
        roundPic.clipsToBounds = true
        
        if battery == 0
        {
            self.battery.image = UIImage(named: "ic_battery_0.png")
        }
        
        if battery > 0 && battery <= 10
        {
            self.battery.image = UIImage(named: "ic_battery_10.png")
        }
        
        if battery > 10 && battery <= 30
        {
            self.battery.image = UIImage(named: "ic_battery_30.png")
        }
        
        if battery > 30 && battery <= 50
        {
            self.battery.image = UIImage(named: "ic_battery_50.png")
        }
        
        if battery > 50 && battery <= 70
        {
            self.battery.image = UIImage(named: "ic_battery_70.png")
        }
        
        if battery > 70
        {
            self.battery.image = UIImage(named: "ic_battery_100.png")
        }
    }
    
}

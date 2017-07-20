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
    
    
    func membersInit (pic: UIImage, datos: String, nombre: String)
    {
        self.name.text = nombre
        self.adress.text = datos
        self.roundPic.image = pic
        roundPic.layer.borderWidth = 1
        roundPic.layer.masksToBounds = false
        roundPic.backgroundColor = UIColor.blue
        roundPic.layer.cornerRadius = roundPic.frame.height/2
        roundPic.clipsToBounds = true
        self.markerPic.image = UIImage(named: "ic_place_black_24dp")
    }
    
}

//
//  MemberDataTableViewCell.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/18/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class MemberDataTableViewCell: UITableViewCell {
    @IBOutlet weak var admin: UISwitch!
    @IBOutlet weak var Data: UILabel!
    @IBOutlet weak var roundedPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func membersInit (pic: UIImage, datos: String, admin: Bool)
    {
        self.admin.isOn = admin
        self.Data.text = datos
        self.roundedPic.image = pic
        roundedPic.layer.borderWidth = 1
        roundedPic.layer.masksToBounds = false
        roundedPic.backgroundColor = UIColor.blue
        roundedPic.layer.cornerRadius = roundedPic.frame.height/2
        roundedPic.clipsToBounds = true
    }

}

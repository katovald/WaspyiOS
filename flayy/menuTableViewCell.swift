//
//  TableViewCell.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 8/25/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class menuTableViewCell: UITableViewCell {

    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    func menuInit (pic: UIImage, nombre: String)
    {
        self.title.text = nombre
        self.title.textColor = UIColor.init(hex: 0x3871B4)
        self.pic.image = pic
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

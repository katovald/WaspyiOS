//
//  corersRounded.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 11/16/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class corersRounded: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0.0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    override func layoutSubviews() {
        layer.masksToBounds = true
    }
}

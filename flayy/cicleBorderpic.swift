//
//  cicleBorderpic.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/27/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

@IBDesignable
class cicleBorderpic: UIImageView {
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    
    @IBInspectable var bkGroudColor: UIColor? {
        didSet {
            backgroundColor = bkGroudColor
        }
    }
    
    //Normal state bg and border
    @IBInspectable var normalBorderColor: UIColor? {
        didSet {
            layer.borderColor = normalBorderColor?.cgColor
        }
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = layer.frame.height/2
        clipsToBounds = true
        
        if borderWidth > 0 {
            if layer.borderColor == normalBorderColor?.cgColor {
                layer.borderColor = normalBorderColor?.cgColor
            }
        }
    }
}

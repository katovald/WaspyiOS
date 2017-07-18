//
//  orderModel.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/14/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class orderModel: NSObject {
        var name = "None"
        var price = 0.00
        var special = false
        override init(){}
        init(name:String,price:Double,special:Bool){
            self.name = name
            self.price = price
            self.special = special
        }
    }

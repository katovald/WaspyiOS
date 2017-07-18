//
//  menuItems.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/14/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class menuItems: NSObject {
    var sections:[String] = []
    var items:[[orderModel]] = []
    
    func addSection(section: String, item:[orderModel]){
        sections = sections + [section]
        items = items + [item]
    }
}

class PizzaMenuItems: menuItems {
    override init() {
        super.init()
        
        addSection(section:"Pizza", item: [
            orderModel(name:"Margherita",price:7.95,special:false),
            orderModel(name:"BBQ Chicken",price:11.49,special:false),
            orderModel(name:"Pepperoni",price:8.45,special:false),
            orderModel(name:"Sausage",price:8.45,special:false),
            orderModel(name:"Seafood",price:12.75,special:false),
            orderModel(name:"Special",price:13.50,special:true)
            ])
        addSection(section:"Deep Dish Pizza", item: [
            orderModel(name:"Sausage",price:10.65,special:false),
            orderModel(name:"Meat Lover's",price:12.35,special:false),
            orderModel(name:"Veggie Lover's",price:10.00,special:false),
            orderModel(name:"BBQ Chicken",price:16.60,special:true),
            orderModel(name:"Mushroom",price:11.25,special:false),
            orderModel(name:"Special",price:15.45,special:true)
            ])
        addSection(section:"Calzone", item: [
            orderModel(name:"Sausage",price:8.00,special:false),
            orderModel(name:"Chicken Pesto",price:8.00,special:false),
            orderModel(name:"Prawns and Mushrooms",price:8.00,special:false),
            orderModel(name:"Primavera",price:8.00,special:false),
            orderModel(name:"Meatball",price:8.00,special:false)
            ])
    }
    
}

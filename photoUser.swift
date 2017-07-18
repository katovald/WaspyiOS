//
//  photoUser.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/14/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class photoUser: NSObject {
    
    var nombre = ""
    var foto = ""
    
    init(nombre: String, foto: String) {
        self.nombre = nombre
        self.foto = foto
    }
}

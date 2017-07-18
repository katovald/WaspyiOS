//
//  three.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/10/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//
import UIKit

class Three: UIViewController{
    @IBOutlet weak var animated: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animated.loadGif(name: "slide3")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

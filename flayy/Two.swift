//
//  Two.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/10/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//
import UIKit

class Two: UIViewController{
    @IBOutlet weak var animado: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        animado.loadGif(name: "slide2")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

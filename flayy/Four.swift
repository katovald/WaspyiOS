//
//  Four.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/10/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class Four: UIViewController{
    @IBOutlet weak var animated: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        animated.loadGif(name: "slide4b")
    }
    @IBAction func loginInicio(_ sender: Any) {
        performSegue(withIdentifier: "omitir5", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

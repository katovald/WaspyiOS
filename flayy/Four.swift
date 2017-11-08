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
        animated.loadGif(name: "slide-4-last-interface")
    }
    @IBAction func loginInicio(_ sender: Any) {
        performSegue(withIdentifier: "omitir4", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

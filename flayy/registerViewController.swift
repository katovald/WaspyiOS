//
//  registerViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 11/14/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class registerViewController: UIViewController {

    @IBOutlet weak var telefono: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var paswordChallenge: UITextField!
    @IBOutlet weak var instructions: Rounded!
    
    var action = 0 // 0 = siguiente, 1 = login, 2 = registro
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func acciones(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

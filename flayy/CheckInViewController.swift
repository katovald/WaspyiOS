//
//  CheckInViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 11/28/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class CheckInViewController: UIViewController {

    let userD :UserDefaults = UserDefaults.standard
    var address:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        direccion.adjustsFontSizeToFitWidth = true
        aviso.adjustsFontSizeToFitWidth = true
        direccion.text = address
        aviso.text = "Todos los integrantes del grupo " + userD.string(forKey: "ActualGroupTitle")! + " verán tu checkIn"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func triggerCheckIn(_ sender: Any) {
        FCmNotifications.init().chechIn(address: address)
        dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var direccion: UILabel!
    @IBOutlet weak var aviso: UILabel!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  PlacesConfigViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class PlacesConfigViewController: UIViewController {
    @IBOutlet weak var eliminar: UIButton!
    @IBOutlet weak var radio: UISlider!
    @IBOutlet weak var vistaMapa: UIView!
    @IBOutlet weak var texto: UITextField!
    @IBOutlet weak var tipo: UIImageView!
    @IBOutlet weak var editarGuardar: UIBarButtonItem!
    
    var icono:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vistaMapa.layer.borderWidth = 2
        vistaMapa.layer.borderColor = UIColor.green.cgColor
        tipo.image = resizeImage(image: UIImage(named: "ic28_casita.jpg")!, newSize: CGSize(width: 35, height: 35))
        tipo.layer.borderWidth = 1
        tipo.layer.masksToBounds = false
        tipo.clipsToBounds = true
        radio.isEnabled=false
        vistaMapa.isUserInteractionEnabled = false
        texto.isEnabled = false
        eliminar.isHidden = true
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

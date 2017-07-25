//
//  membersSelectViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class membersSelectViewController: UIViewController{

    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var pruebas = ["kato":["bateria":70, "direccion":"Lejos", "picture":UIImage()],
                   "haza":["bateria":70, "direccion":"Lejos", "picture":UIImage()],
                   "Otros":["bateria":70, "direccion":"Lejos", "picture":UIImage()]]
    
    var keys = ["kato","haza","Otros"]
    
    let interactor: Interactor? = nil
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func delay(segundos: Double, completion:@escaping()->()){
        let tiempoVista = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * segundos)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: tiempoVista, execute: {completion()
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismiss(animated: true, completion: {
            self.delay(segundos: 0.5, completion: {
                self.menuActionDelegate?.reopenMenu()
            })
        })
    }

}

extension membersSelectViewController: UITableViewDataSource{
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        context!.interpolationQuality = CGInterpolationQuality.default
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        
        context!.concatenate(flipVertical)
        // Draw into the context; this scales the image
        context?.draw(image.cgImage!, in: CGRect(x: 0.0,y: 0.0, width: newRect.width, height: newRect.height))
        
        let newImageRef = context!.makeImage()! as CGImage
        let newImage = UIImage(cgImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pruebas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PicMemberTableViewCell
        let aux = pruebas[keys[indexPath.row]]
        var imagenR = UIImage()
        imagenR = resizeImage(image: UIImage(named: "foto")!, newSize: CGSize(width: 70, height: 70))
        cell.membersInit(pic: imagenR, datos: aux?["direccion"] as! String, nombre: keys[indexPath.row])
        return cell
    }
}

extension membersSelectViewController: UITableViewDelegate{
    
}


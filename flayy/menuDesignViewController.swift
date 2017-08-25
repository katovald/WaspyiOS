//
//  menuDesignViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseAuth

class menuDesignViewController: UIViewController {
    
    let menu = [["Mis lugares","lugares.png"],["Configuracion","config.png"],["CAMSA FAQ", "faq.png"],["Salir","exit.png"]]
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    @IBOutlet weak var round: UIImageView!
    @IBOutlet weak var blur: UIImageView!
    
    @IBAction func closeMenu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var context = CIContext(options: nil)
    
    func blurEffect(foto: UIImage) -> UIImage{
        
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: foto)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        return processedImage
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
    
    override func viewDidLoad() {
        self.round.image = UIImage(named: "kato.jpg")
        self.blur.image = blurEffect(foto: UIImage(named: "kato.jpg")!)
    }
    
    

}

extension menuDesignViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! menuTableViewCell
        
        let aux = menu[indexPath.row]
        var imagenR = UIImage()
        imagenR = UIImage(named: aux[1])!
        cell.menuInit(pic: imagenR, nombre: aux[0])
        return cell
    }
}

extension menuDesignViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            menuActionDelegate?.openSegue("configLugares", sender: nil)
        case 1:
            menuActionDelegate?.openSegue("datosUsuario", sender: nil)
        case 2:
            menuActionDelegate?.openSegue("datosUsuario", sender: nil)
        case 3:
            let authApp = Auth.auth()
            do {
                try authApp.signOut()
            }catch let singOutError as NSError{
                print(singOutError)
            }
            menuActionDelegate?.exitAuth()
        default:
            break
        }
    }
}

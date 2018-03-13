//
//  menuDesignViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseAuth

class mainMenuViewController: UIViewController {
    
    let menu = [["Mis Grupos","menu-i1.png"],
                ["Mis lugares","menu-i2.png"],
                ["Botón de pánico","menu-i3.png"],
                ["Mapa de alertas","menu-i4.png"],
                ["Configuraciones","menu-i5.png"],
                ["Waspy FAQ","menu-i6.png"],
                ["Compartir Waspy", "menu-i7.png"],
                ["Salir","menu-i8.png"]]
    let fileMan = FileManager()
    let userD = UserDefaults.standard
    var menuActionDelegate: MenuActionDelegate? = nil
    
    @IBOutlet weak var round: UIImageView!
    @IBOutlet weak var blur: UIImageView!
    
    @IBOutlet weak var nombre: UILabel!
    
    @IBAction func closeMenu(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: "ExitMenu")
        dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet var close: UISwipeGestureRecognizer!
    
    @IBAction func coseSwiping(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: "ExitMenu")
        dismiss(animated: false, completion: nil)
    }
    
    func delay(segundos: Double, completion:@escaping()->()){
        let tiempoVista = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * segundos)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: tiempoVista, execute: {completion()
        })
    }
    
    override func viewDidLoad() {
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(userD.string(forKey: "OwnerPhone")! + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            self.round.image = UIImage(contentsOfFile: photoURl.path)
            self.nombre.text = userD.string(forKey: "OwnerName") ?? ""
        }else{
            self.round.image = UIImage(named: "default.png")
            self.nombre.text = userD.string(forKey: "OwnerName") ?? ""
        }
    }

}

extension mainMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! menuTableViewCell
        
        let aux = menu[indexPath.row]
        var imagenR = UIImage()
        imagenR = UIImage(named: aux[1])!
        cell.menuInit(pic: imagenR, nombre: aux[0])
        return cell
    }
}

extension mainMenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            menuActionDelegate?.openSegue("confiGrupos", sender: nil)
        case 1:
            menuActionDelegate?.openSegue("configLugares", sender: nil)
        case 2:
            menuActionDelegate?.openSegue("panicButton", sender: nil)
        case 3:
            menuActionDelegate?.trigger()
        case 4:
            menuActionDelegate?.openSegue("datosUsuario", sender: nil)
        case 5:
            menuActionDelegate?.openSegue("FAQsegue", sender: nil)
        case 6:
            menuActionDelegate?.shareAPP()
        case 7:
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

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
    
    let menu = [["Mis Grupos","menu-i1.png"], ["Mis lugares","menu-i2.png"],["Configuracion","menu-i3v.png"],["CAMSA FAQ", "menu-i4.png"],["Salir","menu-i5.png"]]
    let fileMan = FileManager()
    let userD = UserDefaults.standard
    var menuActionDelegate: MenuActionDelegate? = nil
    
    @IBOutlet weak var round: UIImageView!
    @IBOutlet weak var blur: UIImageView!
    
    @IBOutlet weak var nombre: UILabel!
    @IBAction func closeMenu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(userD.string(forKey: "OwnerPhone")! + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            self.round.image = UIImage(contentsOfFile: photoURl.path)
            self.nombre.text = userD.string(forKey: "OwnerName")!
        }else{
            self.round.image = UIImage(named: "kato.jpg")
            self.nombre.text = userD.string(forKey: "OwnerName")!
        }
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
            menuActionDelegate?.openSegue("confiGrupos", sender: nil)
        case 1:
            menuActionDelegate?.openSegue("configLugares", sender: nil)
        case 2:
            menuActionDelegate?.openSegue("datosUsuario", sender: nil)
        case 3:
            menuActionDelegate?.openSegue("datosUsuario", sender: nil)
        case 4:
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

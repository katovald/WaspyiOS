//
//  menuDesignViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class menuDesignViewController: UIViewController {
    
    let menu = ["Mis grupos","Mis lugares", "Configuraion", "CAMSA FAQ", "Salir"]
    
    var interactor: Interactor? = nil
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    @IBOutlet weak var round: UIImageView!
    @IBOutlet weak var blur: UIImageView!
    
    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

extension menuDesignViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = menu[indexPath.row]
        return cell
    }
}

extension menuDesignViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            menuActionDelegate?.openSegue("listaGrupos", sender: nil)
        case 1:
            menuActionDelegate?.openSegue("configLugares", sender: nil)
        case 2:
            menuActionDelegate?.openSegue("datosUsuario", sender: nil)
        default:
            break
        }
    }
}

//
//  MapViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func reopenMenu()
}

class MapViewController: UIViewController {
    
    var interactor = Interactor()
    var handle:AuthStateDidChangeListenerHandle?
    
    // los elementos usados
    @IBOutlet weak var center: UIButton!                //boton para centrar el mapa en tu posicion original
    @IBOutlet weak var dron: UIButton!                  //modalidad de dron
    @IBOutlet weak var gmapView: UIView!                //muestra el mapa en el fondo de la vista
    
    @IBAction func localiza(_ sender: Any) {        //envia coordenadas y las centra en el mapa
    }
    
    @IBAction func dronInicio(_ sender: Any) {      //modo dron
    }
    
    @IBAction func openGroups(_ sender: Any) {      //popup para elegir grupo
        performSegue(withIdentifier: "grupos", sender: nil)
    }
    
    @IBAction func members(_ sender: Any) {
        performSegue(withIdentifier: "miembros", sender: nil)
    }
    
    @IBAction func openMenu(_ sender: Any) {        //muestra y oculta el menu
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? menuDesignViewController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
            destinationViewController.menuActionDelegate = self
        }
    }
    
    override func viewDidLoad() {
        if let usuario = Auth.auth().currentUser {
            super.viewDidLoad()
        }else{
            performSegue(withIdentifier: "sesion", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimacionPresentar()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimacionOcultar()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.triggerInicio ? interactor: nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.triggerInicio ? interactor: nil
    }
}

extension MapViewController: MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: segueName, sender: sender)
        })
    }
    
    func reopenMenu() {
        performSegue(withIdentifier: "menu", sender: nil)
    }
}


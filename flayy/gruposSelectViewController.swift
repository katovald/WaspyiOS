//
//  gruposSelectViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class gruposSelectViewController: UIViewController {
    var grupos = ["Grupo 1","Grupo 2","Grupo 3","Grupo 1","Grupo 1"]
    
     var menuActionDelegate: MenuActionDelegate? = nil
    
    @IBAction func sendSettings(_ sender: Any) {
        menuActionDelegate?.openSegue("confiGrupos", sender: nil)
    }
    
    @IBOutlet weak var settingsGroup: UIButton!
    
    
    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
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

extension gruposSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grupos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = grupos[indexPath.row]
        return cell
    }
}

extension gruposSelectViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        menuActionDelegate?.openSegue("miembros", sender: nil)
    }
}

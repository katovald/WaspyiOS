//
//  GroupSelectorViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/18/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class GroupSelectorViewController: UIViewController {

    @IBAction func create(_ sender: Any) {
        let alertController = UIAlertController(title: "Grupo Nuevo", message: "Introduce el nombre de tu grupo", preferredStyle: .alert)
        let confirmation = UIAlertAction(title: "Listo", style: .default, handler: {(_) in
            if let field = alertController.textFields![0] as? UITextField {
                
            }else{
                
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler:{(_) in
        })
    }
    @IBOutlet weak var newGroup: UIBarButtonItem!
    let userD: UserDefaults = UserDefaults.standard
    
    @IBOutlet weak var titulo: UINavigationItem!
    
    @IBAction func dismissSelector(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var gruposLista: [[String:String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gruposLista = userD.array(forKey: "OwnerGroups") as! [[String:String]]
        titulo.title = userD.string(forKey: "ActualGroupTitle") ?? ""
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

extension GroupSelectorViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gruposLista.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = gruposLista[indexPath.row].first?.value
        return cell
    }
}

extension GroupSelectorViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "configuracionGrupo", sender: nil)
    }
}

//
//  PlacesViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class PlacesViewController: UIViewController {
    
    @IBAction func newGeofence(_ sender: Any) {
    }
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    var places = ["Casa","Escuela","Trabajo","Gimnasio"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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

extension PlacesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = places[indexPath.row]
        return cell
    }
}

extension PlacesViewController: UITableViewDelegate{
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "configuracionLugares", sender: nil)
    }
}


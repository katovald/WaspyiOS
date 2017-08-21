//
//  helpViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class helpViewController: UIViewController {

    @IBOutlet weak var puntitos: UIPageControl!
    @IBOutlet weak var paginas: UIView!
    
    var controladorAyuda: HelpController? {
        didSet {
            controladorAyuda?.helpDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        puntitos.addTarget(self, action: #selector(helpViewController.didChangePageControlValue), for: .valueChanged)
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? HelpController{
            self.controladorAyuda = pageViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didChangePageControlValue() {
        controladorAyuda?.scrollToViewController(index: puntitos.currentPage)
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

extension helpViewController: HelpViewControllerDelegate {
    func  helpPageViewController(_ helpPageViewController: HelpController, didUpdatePageCount count: Int) {
        puntitos.numberOfPages = count
    }
    
    func helpPageViewController(_ helpPageViewController: HelpController, didUpdatePageIndex index: Int) {
        puntitos.currentPage = index
    }
}

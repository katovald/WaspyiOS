//
//  Groups.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 8/25/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class GroupsMenu: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let firstVCView = self.source.view as UIView?
        let secondVCView = self.destination.view as UIView?
        
        // Get the screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Specify the initial position of the destination view.
        secondVCView?.frame = CGRect(origin: CGPoint(x: screenWidth,y: 0), size: CGSize(width: screenWidth, height: screenHeight))
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        
        // Animate the transition.
        UIView.animate(withDuration: 0.6, animations: {
            secondVCView?.frame = (secondVCView?.frame.offsetBy(dx: -screenWidth, dy: 0.0))!
        }, completion: { (fisished: Bool) in
            self.source.present(self.destination as UIViewController, animated: false, completion: nil)
        })
    }
}

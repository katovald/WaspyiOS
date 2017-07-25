//
//  AnimacionOcultar.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/24/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class AnimacionOcultar: NSObject {

}

extension AnimacionOcultar: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else{
                return
        }
        
        let vistaInicial = transitionContext.containerView
        let imagenVista = vistaInicial.viewWithTag(MenuHelper.snapshotNumber)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        imagenVista?.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        }, completion: {_ in
            let acaboTransicion = !transitionContext.transitionWasCancelled
            if acaboTransicion {
                vistaInicial.insertSubview(toVC.view, aboveSubview: fromVC.view)
                imagenVista?.removeFromSuperview()
            }
            transitionContext.completeTransition(acaboTransicion)
        })
    }
}

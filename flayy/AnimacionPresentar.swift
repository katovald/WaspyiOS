//
//  AnimacionPresentar.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/24/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class AnimacionPresentar: NSObject {
}

extension AnimacionPresentar: UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        else
        {
            return
        }
        let vistaInicial = transitionContext.containerView
        vistaInicial.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        //reemplazamos main con una imagen
        
        if let imagenMain = fromVC.view.snapshotView(afterScreenUpdates: false){
            imagenMain.tag = MenuHelper.snapshotNumber
            imagenMain.isUserInteractionEnabled = false
            imagenMain.layer.opacity = 0.7
            
            vistaInicial.insertSubview(imagenMain, aboveSubview: toVC.view)
            fromVC.view.isHidden = true
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: {
                            imagenMain.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidth
            },
                           completion: {_ in
                            fromVC.view.isHidden = false
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            )
        }
    }
}

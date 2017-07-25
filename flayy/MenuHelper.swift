//
//  MenuHelper.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/24/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import Foundation
import UIKit

enum Direccion {
    case up
    case down
    case left
    case rigth
}

struct  MenuHelper {
    static let menuWidth: CGFloat = 0.8
    
    static let percentThreshold:CGFloat = 0.3
    
    static let snapshotNumber = 12345
    
    static func calcularProgreso(_ translationInView:CGPoint, viewBounds:CGRect, direccion: Direccion) -> CGFloat {
        let eje:CGFloat
        let radioEje:CGFloat
        switch direccion {
        case .up, .down:
            eje = translationInView.y
            radioEje = viewBounds.height
        case .left,.rigth:
            eje = translationInView.x
            radioEje = viewBounds.width
        }
        
        let movimientoEn = eje / radioEje
        let movimientoPositivo:Float
        let movimientoPositivoPorcentaje:Float
        
        switch direccion {
        case .rigth,.down:
            movimientoPositivo = fmaxf(Float(movimientoEn), 0.0)
            movimientoPositivoPorcentaje = fminf(movimientoPositivo, 1.0)
            return CGFloat(movimientoPositivoPorcentaje)
        case .left,.up:
            movimientoPositivo = fminf(Float(movimientoEn), 0.0)
            movimientoPositivoPorcentaje = fmaxf(movimientoPositivo, -1.0)
            return CGFloat(-movimientoPositivoPorcentaje)
        }
    }
    
    static func mapGestureStateToInteractor(_ gestureState:UIGestureRecognizerState, progress:CGFloat, interactor: Interactor?, triggerSegue: () -> ()){
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            interactor.triggerInicio = true
            triggerSegue()
        case .changed:
            interactor.triggerTerminar = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.triggerInicio = false
            interactor.cancel()
        case .ended:
            interactor.triggerInicio = false
            interactor.triggerTerminar
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
}

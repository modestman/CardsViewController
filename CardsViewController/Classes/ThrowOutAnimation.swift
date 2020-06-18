//
//  ThrowOutAnimationParameters.swift
//  CardsControl
//
//  Created by Anton Glezman on 15.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

/// Animation for throwing the card out of the visible frame
struct ThrowOutAnimation {
    
    enum DurationType {
        case dependentOfLength
        case `default`
    }
    
    let initialVelocity: CGPoint
    let containerFrame: CGRect
    let duration: DurationType
    let card: CardsViewController.Card
    
    private var view: UIView { card.containerView }

    var animator: UIViewPropertyAnimator {
        // Calculate the translation
        let totalMovement = AnimationHelpers.translationOut(of: containerFrame, velocity: initialVelocity)
        let movement = CGPoint(x: totalMovement.x - view.transform.tx, y: totalMovement.y - view.transform.ty)
        var duration = AnimationHelpers.fastAnimationDuration
        if self.duration == .dependentOfLength {
            duration = TimeInterval(movement.length / totalMovement.length) * AnimationHelpers.fastAnimationDuration
        }
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            self.view.transform = self.view.transform.translatedBy(x: movement.x, y: movement.y)
        }
        return animator
    }
}

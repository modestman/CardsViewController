//
//  CancelAnimation.swift
//  CardsControl
//
//  Created by Anton Glezman on 15.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

/// Animation for placing the card in its original position when cancel the swipe gesture
struct CancelAnimation {
    
    let view: UIView
    let velocity: CGPoint
    
    var animator: UIViewPropertyAnimator {
        let timing = UISpringTimingParameters(dampingRatio: 0.8)
        let animator = UIViewPropertyAnimator(
            duration: AnimationHelpers.longAnimationDuration,
            timingParameters: timing)
        animator.addAnimations {
            self.view.transform = .identity
        }
        return animator
    }
}

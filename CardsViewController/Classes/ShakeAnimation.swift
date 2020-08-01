//
//  ShakeAnimation.swift
//  CardsViewController
//
//  Created by Anton Glezman on 01.08.2020.
//

import UIKit

/// Animation for shake the card to the left and right
struct ShakeAnimation {
    
    let view: UIView
    let width: CGFloat
    let completion: () -> Void
    
    var animator: UIViewPropertyAnimator {
        let dx = width / 8
        let angle = CGFloat.pi / 8 * dx / width
        
        let p1 = UIViewPropertyAnimator(duration: 0.12, curve: .easeOut) {
            let translation = CGPoint(x: dx, y: 0)
            let rotation = CGAffineTransform(rotationAngle: angle)
            self.view.transform = rotation.translatedBy(x: translation.x, y: translation.y)
        }
        
        let p2 = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
            let translation = CGPoint(x: -dx, y: 0)
            let rotation = CGAffineTransform(rotationAngle: -angle)
            self.view.transform = rotation.translatedBy(x: translation.x, y: translation.y)
        }

        let timing = UISpringTimingParameters(dampingRatio: 0.6)
        let p3 = UIViewPropertyAnimator(duration: 0.4, timingParameters: timing)
        p3.addAnimations {
            self.view.transform = .identity
        }
        
        p3.addCompletion { _ in
            self.completion()
        }
        p2.addCompletion { _ in
            p3.startAnimation()
        }
        p1.addCompletion { _ in
            p2.startAnimation()
        }
        
        return p1
    }
}

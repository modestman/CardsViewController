//
//  AppendCardAnimation.swift
//  CardsControl
//
//  Created by Anton Glezman on 15.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

/// Animation for adding a next card at the back of the stack
struct AppendCardAnimation {
    
    let allCards: [CardsViewController.Card]
    let newCard: CardsViewController.Card?
    let transform: (Int) -> CGAffineTransform
    
    var animator: UIViewPropertyAnimator {
        newCard?.containerView.alpha = 0
        let animator = UIViewPropertyAnimator(
            duration: AnimationHelpers.fastAnimationDuration,
            curve: .easeIn) {
                for card in self.allCards.dropFirst() {
                    card.containerView.transform = self.transform(card.visibleIndex) //AnimationHelpers.transform(for: card.visibleIndex)
                    card.containerView.gestureRecognizers?.forEach {
                        // disable PanGestureRecognizer for all cards except the topmost one
                        if $0 is UIPanGestureRecognizer {
                            $0.isEnabled = card.visibleIndex == 0
                        }
                    }
                }
                self.newCard?.containerView.alpha = 1.0
            }
        return animator
    }
    
}

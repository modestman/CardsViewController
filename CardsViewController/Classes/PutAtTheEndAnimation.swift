//
//  PutAtTheEndAnimation.swift
//  CardsControl
//
//  Created by Anton Glezman on 15.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

/// Animation for placing the first card at the end of the stack and adding a next card
struct PutAtTheEndAnimation {
    
    let allCards: [CardsViewController.Card]
    let newCard: CardsViewController.Card?
    let transform: (UIView, Int) -> Void
    
    var animator: UIViewPropertyAnimator {
        newCard?.containerView.alpha = 0
        let animator = UIViewPropertyAnimator(
            duration: AnimationHelpers.fastAnimationDuration,
            curve: .easeIn) {
                for card in self.allCards {
                    self.transform(card.containerView, card.visibleIndex)
                    card.containerView.gestureRecognizers?.forEach {
                        // disable PanGestureRecognizer for all cards except the topmost one
                        if $0 is UIPanGestureRecognizer {
                            $0.isEnabled = card.visibleIndex == 0
                        }
                    }
                }
                self.allCards.last?.containerView.alpha = 0.2
            }
        
        return animator
    }
}

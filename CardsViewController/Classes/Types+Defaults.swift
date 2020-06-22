//
//  CardsControl+Defaults.swift
//  CardsControl
//
//  Created by Anton Glezman on 16.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

/// Default datasource implementation
extension CardsViewControllerDatasource {
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        decorationViewForCardAt index: Int) -> UIView? {
        return nil
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        applyTransformFor card: UIView,
        at position: Int) {}
}


/// Default delegate implementation
extension CardsViewControllerDelegate {
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        swipeAnimationAtIndex index: Int,
        direction: SwipeDirection) -> SwipeAnimation {
        
        return .throwOut
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        tapAnimationAtIndex index: Int) -> TapAnimation {
        
        return .none
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        finishMoveCardAtIndex: Int,
        direction: SwipeDirection,
        animation: SwipeAnimation) {}
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        didMoveCardAtIndex: Int,
        direction: SwipeDirection,
        progress: Float) {}
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        cancelMoveCardAtIndex: Int) {}
}

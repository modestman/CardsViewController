//
//  CardsControl.swift
//  CardsControl
//
//  Created by Anton Glezman on 01.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

public enum SwipeDirection: String {
    case up
    case down
    case right
    case left
}

/// The animation after swipe the card
public enum SwipeAnimation {
    /// Do nothing, cancel the swipe
    case none
    /// Put the card at the end of the stack
    case putAtTheEnd
    /// Throw the card out of the stack
    case throwOut
}

/// The animation after tap on the card
public enum TapAnimation {
    /// Do nothing
    case none
    /// Flip the card
    case flip
}


/// Datasource
public protocol CardsViewControllerDatasource: AnyObject {
    
    /// Total number of cards
    ///
    /// Required method.
    func numberOfItemsInCardsViewController(_ controller: CardsViewController) -> Int
    
    /// Get a view controller that contains the main content of the card
    ///
    /// Required method.
    ///
    /// - Parameters:
    ///   - index: index of a card
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        viewControllerAtIndex index: Int) -> UIViewController
    
    /// Get a view that will be a container for a card. You can decorate this view with a shadow or a border.
    ///
    /// Optional method. By default used `UIView()` as a container.
    ///
    /// - Parameters:
    ///   - index: index of a card
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        decorationViewForCardAt index: Int) -> UIView?
    
    /// Make an Affine Transform for each card accordingly with their position.
    ///
    /// Optional method. By default used `.identity` as a transform.
    ///
    /// - Parameters:
    ///   - card: The view 
    ///   - position: Position is a z-order of card on screen. Topmost card has position = 0.
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        applyTransformFor card: UIView,
        at position: Int)
}


/// Delegate
public protocol CardsViewControllerDelegate: AnyObject {
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        swipeAnimationAtIndex index: Int,
        direction: SwipeDirection) -> SwipeAnimation
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        tapAnimationAtIndex index: Int) -> TapAnimation
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        finishMoveCardAtIndex: Int,
        direction: SwipeDirection,
        animation: SwipeAnimation)
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        didMoveCardAtIndex: Int,
        direction: SwipeDirection,
        progress: Float)
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        cancelMoveCardAtIndex: Int)
}

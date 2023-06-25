//
//  CardsControl.swift
//  CardsControl
//
//  Created by Anton Glezman on 01.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

/// Each card should conform this protocol
public protocol CardViewController: UIViewController {
    
    /// The default visible card view
    var frontView: UIView { get }
    
    /// The backside of the card. Displayed when the card is flipped
    var backView: UIView? { get }
    
    /// The action performed before flip animation
    func willFlipCard()
    
    /// The action performed after flip animation
    func didFlipCard()
}

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
        viewControllerAt index: Int) -> CardViewController
    
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
        swipeAnimationAt index: Int,
        direction: SwipeDirection) -> SwipeAnimation
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        tapAnimationAt index: Int) -> TapAnimation
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        moveToTheEndCardAt index: Int) -> Int
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        finishMoveCardAt index: Int,
        direction: SwipeDirection,
        animation: SwipeAnimation)
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        didMoveCardAt index: Int,
        direction: SwipeDirection,
        progress: Float)
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        cancelMoveCardAt index: Int)
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        didShowCardAt index: Int)
}


// MARK: - Internal types

internal enum CardSate {
    case inStack
    case dragging
    case cancelAnimation
    case removingAnimation
    case transformAnimation
}

internal class Card {
    var absoluteIndex: Int
    var visibleIndex: Int
    let containerView: UIView
    let viewController: CardViewController
    var state: CardSate
    var isFlipped: Bool
    var animator: UIViewPropertyAnimator?
    var willBeDeleted: Bool = false
    
    init(
        absoluteIndex: Int,
        visibleIndex: Int,
        containerView: UIView,
        viewController: CardViewController,
        state: CardSate,
        isFlipped: Bool = false) {
        self.absoluteIndex = absoluteIndex
        self.visibleIndex = visibleIndex
        self.containerView = containerView
        self.viewController = viewController
        self.state = state
        self.isFlipped = isFlipped
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer? {
        return containerView.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer }) as? UIPanGestureRecognizer
    }
    
    var tapGestureRecognizer: UITapGestureRecognizer? {
        return containerView.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer }) as? UITapGestureRecognizer
    }
}

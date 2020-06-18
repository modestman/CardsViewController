//
//  CardsViewController.swift
//  CardsControl
//
//  Created by Anton Glezman on 16.05.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

///
public final class CardsViewController: UIViewController {
    
    // MARK: - Types
    
    internal struct Card {
        var absoluteIndex: Int
        var visibleIndex: Int
        let containerView: UIView
        let viewController: UIViewController
    }
    
    
    // MARK: - Public properties
    
    public weak var dataSource: CardsViewControllerDatasource?
    public weak var delegate: CardsViewControllerDelegate?
    
    /// The number of cards simultaneously visible on screen
    public var visibleCardsCount: Int = 3
    
    /// Edge insets between controller view and topmost card view
    public var cardEdgeInsets = UIEdgeInsets(top: 60, left: 40, bottom: 40, right: 40)
    
    
    // MARK: - Private properties
    
    private var cards: [Card] = [] // Contains only visible cards
    
    private var minTranslationDistance: CGFloat {
        view.frame.width / 3.0
    }
    
    
    // MARK: - View Controller Life Cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Public methods
    
    public func reloadCards() {
        removeAllCards()
        guard
            let dataSource = dataSource,
            dataSource.numberOfItemsInCardsViewController(self) > 0
        else { return }
        
        let count = min(dataSource.numberOfItemsInCardsViewController(self), visibleCardsCount)
        for i in 0..<count {
            addCard(index: i)
        }
    }
    
    
    // MARK: - Private methods
    
    @discardableResult
    private func addCard(index: Int) -> Card? {
        guard let dataSource = dataSource else { return nil }
        let childVC = dataSource.cardsViewController(self, viewControllerAtIndex: index)
        let childView = decorateView(nestedView: childVC.view, index: index)
        childView.tag = index
        
        let card = Card(
            absoluteIndex: index,
            visibleIndex: (cards.last?.visibleIndex ?? -1) + 1,
            containerView: childView,
            viewController: childVC)
        
        let safeArea = view.safeAreaLayoutGuide
        addChild(childVC)
        view.addSubview(childView, activate: [
            childView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: cardEdgeInsets.top),
            childView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -cardEdgeInsets.bottom),
            childView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: cardEdgeInsets.left),
            childView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -cardEdgeInsets.right)
        ])
        view.sendSubviewToBack(childView)
        childView.transform = cardTransform(card.visibleIndex)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        childView.addGestureRecognizer(pan)
        pan.isEnabled = card.visibleIndex == 0
            
        cards.append(card)
        return card
    }
    
    private func addNextCard() -> Card? {
        guard
            let dataSource = dataSource,
            let lastCard = cards.last
        else { return nil }
        if lastCard.absoluteIndex < dataSource.numberOfItemsInCardsViewController(self) - 1 {
            return addCard(index: lastCard.absoluteIndex + 1)
        }
        return nil
    }
    
    private func deleteCard(index: Int) {
        guard let card = cards.first(where: { $0.absoluteIndex == index }) else { return }
        removeChild(card.viewController)
        card.containerView.removeFromSuperview()
        cards.removeAll { $0.absoluteIndex == index }
    }
    
    private func removeAllCards() {
        cards.forEach {
            self.removeChild($0.viewController)
            $0.containerView.removeFromSuperview()
        }
        cards = []
    }
    
    private func decorateView(nestedView: UIView, index: Int) -> UIView {
        let shadowView = dataSource?.cardsViewController(self, decorationViewForCardAt: index) ?? UIView()
        shadowView.addSubview(nestedView, with: shadowView)
        nestedView.layer.cornerRadius = shadowView.layer.cornerRadius
        return shadowView
    }

}

extension CardsViewController: UIGestureRecognizerDelegate {
    
    @objc func panGesture(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard let piece = gestureRecognizer.view else {return}
        
        let translation = gestureRecognizer.translation(in: piece.superview)
        let velocity = gestureRecognizer.velocity(in: piece)
        let direction = AnimationHelpers.direction(with: velocity, in: view.frame)
        
        switch gestureRecognizer.state {
        case .possible:
            break
            
        case .began, .changed:
            let dx = translation.x
            let angle = CGFloat.pi / 8 * dx / view.bounds.width
            let rotation = CGAffineTransform(rotationAngle: angle)
            piece.transform = rotation.translatedBy(x: translation.x, y: translation.y)
            
            let progress = self.progress(translation: translation, direction: direction)
            delegate?.cardsViewController(self, didMoveCardAtIndex: piece.tag, direction: direction, progress: progress)
            
        case .ended:
            if canFinishSwipe(cardIndex: piece.tag, translation: translation, velocity: velocity) {
                finishSwipe(view: piece, velocity: velocity, direction: direction)
            } else {
                cancelSwipe(view: piece, velocity: velocity)
            }
            
        case .cancelled, .failed:
            cancelSwipe(view: piece, velocity: velocity)

        @unknown default:
            break
        }
    }
    
    private func finishSwipe(view: UIView, velocity: CGPoint, direction: SwipeDirection) {
        let animation = swipeAnimation(at: view.tag, direction: direction)
        switch animation {
        case .throwOut:
            throwOutAnimation(view: view, velocity: velocity, direction: direction)
        case .putAtTheEnd:
            putAtTheEndAnimation(view: view, velocity: velocity, direction: direction)
        case .none:
            break
        }
    }
    
    private func throwOutAnimation(view: UIView, velocity: CGPoint, direction: SwipeDirection) {
        guard let card = cards.first(where: { $0.absoluteIndex == view.tag }) else { return }
        
        // First animation - throw out the card
        let firstAnimator = ThrowOutAnimation(
            initialVelocity: velocity,
            containerFrame: self.view.frame,
            duration: .default,
            card: card).animator
        firstAnimator.addCompletion { [weak self] _ in
            self?.deleteCard(index: view.tag)
        }
        firstAnimator.startAnimation()
        
        // Second animation - add new card at the back
        let newCard = addNextCard()
        for i in 1..<cards.count {
            cards[i].visibleIndex = i - 1
        }
        let secondAnimator = AppendCardAnimation(allCards: cards, newCard: newCard, transform: cardTransform).animator
        secondAnimator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.cardsViewController(
                self,
                finishMoveCardAtIndex: view.tag,
                direction: direction,
                animation: .throwOut)
        }
        secondAnimator.startAnimation()
    }
    
    private func putAtTheEndAnimation(view: UIView, velocity: CGPoint, direction: SwipeDirection) {
        guard let card = cards.first(where: { $0.absoluteIndex == view.tag }) else { return }
        
        // First animation - throw out the card
        let firstAnimator = ThrowOutAnimation(
            initialVelocity: velocity,
            containerFrame: view.frame,
            duration: .dependentOfLength,
            card: card).animator
        
        // Second animation - put the card at the end of stack and add a new card at the back
        let newCard = addNextCard()
        cards.append(cards.removeFirst()) // reorder
        for i in 0..<cards.count {
            cards[i].visibleIndex = i
        }
        let secondAnimator = PutAtTheEndAnimation(allCards: cards, newCard: newCard, transform: cardTransform).animator
        secondAnimator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.deleteCard(index: view.tag)
            self.delegate?.cardsViewController(
                self,
                finishMoveCardAtIndex: view.tag,
                direction: direction,
                animation: .putAtTheEnd)
        }
        
        firstAnimator.addCompletion { [weak self] _ in
            self?.view.sendSubviewToBack(view)
            secondAnimator.startAnimation()
        }
        
        firstAnimator.startAnimation()
    }
    
    private func cancelSwipe(view: UIView, velocity: CGPoint) {
        let animator = CancelAnimation(view: view, velocity: velocity).animator
        animator.startAnimation()
        delegate?.cardsViewController(self, cancelMoveCardAtIndex: view.tag)
    }

    private func canFinishSwipe(cardIndex: Int, translation: CGPoint, velocity: CGPoint) -> Bool {
        let direction = AnimationHelpers.direction(with: velocity, in: view.frame)
        let animation = swipeAnimation(at: cardIndex, direction: direction)
        guard animation != .none  else { return false }
        
        let progress = self.progress(translation: translation, direction: direction)
        let finishCondition: Bool
        switch direction {
        case .up, .down:
            finishCondition = (abs(velocity.y) > 300 && abs(translation.y) > 50) || progress >= 1.0
        case .right, .left:
            finishCondition = (abs(velocity.x) > 300 && abs(translation.x) > 50) || progress >= 1.0
        }
        return finishCondition
    }
    
    private func progress(translation: CGPoint, direction: SwipeDirection) -> Float {
        let progress: Float
        switch direction {
        case .up, .down:
            progress = Float(abs(translation.y) / minTranslationDistance)
        case .right, .left:
            progress = Float(abs(translation.x) / minTranslationDistance)
        }
        return min(progress, 1.0)
    }

}

/// Default delegate implementation

private extension CardsViewController {
    
    func swipeAnimation(at index: Int, direction: SwipeDirection) -> SwipeAnimation {
        return delegate?.cardsViewController(self, swipeAnimationAtIndex: index, direction: direction) ?? .throwOut
    }
    
    var cardTransform: (Int) -> CGAffineTransform {
        return { [weak self] (position) -> CGAffineTransform in
            guard let self = self, let dataSource = self.dataSource else { return .identity }
            return dataSource.cardsViewController(self, transformForCardAt: position)
        }
    }
}

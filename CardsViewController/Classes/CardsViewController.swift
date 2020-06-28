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
            viewController: childVC,
            state: .inStack)
        
        let safeArea = view.safeAreaLayoutGuide
        addChild(childVC)
        view.addSubview(childView, activate: [
            childView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: cardEdgeInsets.top),
            childView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -cardEdgeInsets.bottom),
            childView.leftAnchor.constraint(equalTo: safeArea.leftAnchor, constant: cardEdgeInsets.left),
            childView.rightAnchor.constraint(equalTo: safeArea.rightAnchor, constant: -cardEdgeInsets.right)
        ])
        view.sendSubviewToBack(childView)
        cardTransform(childView, card.visibleIndex)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        childView.addGestureRecognizer(pan)
        pan.isEnabled = true
            
        cards.append(card)
        return card
    }
    
    private func addNextCard() -> Card? {
        guard
            let dataSource = dataSource,
            let lastCard = cards.max(by: { $0.absoluteIndex < $1.absoluteIndex })
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
        guard
            let piece = gestureRecognizer.view,
            let card = cards.first(where: { $0.absoluteIndex == piece.tag })
        else { return }
        
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
            card.state = .dragging
            
            let progress = self.progress(translation: translation, direction: direction)
            delegate?.cardsViewController(self, didMoveCardAtIndex: piece.tag, direction: direction, progress: progress)
            
        case .ended:
            if canFinishSwipe(cardIndex: piece.tag, translation: translation, velocity: velocity) {
                finishSwipe(card: card, velocity: velocity, direction: direction)
            } else {
                cancelSwipe(card: card, velocity: velocity)
            }
            
        case .cancelled, .failed:
            cancelSwipe(card: card, velocity: velocity)

        @unknown default:
            break
        }
    }
    
    private func finishSwipe(card: Card, velocity: CGPoint, direction: SwipeDirection) {
        let animation = swipeAnimation(at: card.absoluteIndex, direction: direction)
        switch animation {
        case .throwOut:
            throwOutAnimation(card: card, velocity: velocity, direction: direction)
        case .putAtTheEnd:
            putAtTheEndAnimation(card: card, velocity: velocity, direction: direction)
        case .none:
            card.state = .inStack
        }
    }
    
    private func throwOutAnimation(card: Card, velocity: CGPoint, direction: SwipeDirection) {
        card.animator?.stopAnimation(true)
        
        // First animation - throw out the card
        card.state = .removingAnimtion
        let firstAnimator = ThrowOutAnimation(
            initialVelocity: velocity,
            containerFrame: self.view.frame,
            duration: .default,
            card: card).animator
        firstAnimator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.deleteCard(index: card.absoluteIndex)
            self.delegate?.cardsViewController(
                self,
                finishMoveCardAtIndex: card.absoluteIndex,
                direction: direction,
                animation: .throwOut)
        }
        firstAnimator.startAnimation()
        
        // Second animation - add new card at the back
        let newCard = addNextCard()
        newCard?.containerView.alpha = 0.0
        let restCards = cards.filter { $0.state != .removingAnimtion }
        for i in 0..<restCards.count {
            let card = restCards[i]
            card.visibleIndex = i
            card.state = .transformAnimation
            let animator = transformAnimator(for: card)
            card.animator = animator
            animator.addCompletion { _ in
                card.state = .inStack
                card.animator = nil
            }
            animator.startAnimation()
        }
    }
    
    private func transformAnimator(for card: Card) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(
            duration: AnimationHelpers.fastAnimationDuration,
            curve: .easeIn) { [weak self] in
                self?.cardTransform(card.containerView, card.visibleIndex)
            }
    }
    
    private func putAtTheEndAnimation(card: Card, velocity: CGPoint, direction: SwipeDirection) {
        let view = card.containerView
        
        // First animation - throw out the card
        card.state = .removingAnimtion
        let firstAnimator = ThrowOutAnimation(
            initialVelocity: velocity,
            containerFrame: view.frame,
            duration: .dependentOfLength,
            card: card).animator
        card.animator = firstAnimator
        
        firstAnimator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            card.animator = nil
            card.state = .inStack
            
            // Second animation - put the card at the end of stack and add a new card at the back
            self.finishPutAtTheEndAnimation(deletedCard: card) {
                self.delegate?.cardsViewController(
                    self,
                    finishMoveCardAtIndex: card.absoluteIndex,
                    direction: direction,
                    animation: .putAtTheEnd)
            }
        }
        
        firstAnimator.startAnimation()
    }
    
    private func finishPutAtTheEndAnimation(deletedCard: Card, completion: @escaping () -> Void) {
        
        let newCard = addNextCard()
        newCard?.containerView.alpha = 0.0
        
        let normalCards = cards
            .filter {
                $0.state != .removingAnimtion && $0.absoluteIndex != deletedCard.absoluteIndex
            }
            .sorted { $0.absoluteIndex < $1.absoluteIndex }
        
        let deletedCards = cards
            .filter {
                $0.state == .removingAnimtion || $0.absoluteIndex == deletedCard.absoluteIndex
            }
            .sorted { $0.absoluteIndex < $1.absoluteIndex }
        
        cards = normalCards + deletedCards
        deletedCards.forEach { view.sendSubviewToBack($0.containerView) }
        
        for i in 0..<cards.count {
            let card = cards[i]
            card.visibleIndex = i
            
            if card.state == .removingAnimtion { continue }
            
            if card.absoluteIndex != deletedCard.absoluteIndex {
                let animator = transformAnimator(for: card)
                card.state = .transformAnimation
                card.animator = animator
                animator.addCompletion { _ in
                    card.state = .inStack
                    card.animator = nil
                }
                animator.startAnimation()
            } else {
                let animator = transformAnimator(for: card)
                card.animator = animator
                card.state = .removingAnimtion
                animator.addAnimations {
                    card.containerView.alpha = 0.2
                }
                animator.addCompletion { [weak self] _ in
                    guard let self = self else { return }
                    card.animator = nil
                    card.state = .inStack
                    self.deleteCard(index: deletedCard.absoluteIndex)
                    completion()
                }
                animator.startAnimation()
            }
        }
    }
    
    private func cancelSwipe(card: Card, velocity: CGPoint) {
        card.state = .cancelAnimation
        let animator = CancelAnimation(view: card.containerView, velocity: velocity).animator
        animator.startAnimation()
        animator.addCompletion { _ in
            card.state = .inStack
        }
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
    
    var cardTransform: (UIView, Int) -> Void {
        return { [weak self] (view, position) -> Void in
            guard let self = self, let dataSource = self.dataSource else { return }
            dataSource.cardsViewController(self, applyTransformFor: view, at: position)
        }
    }
}

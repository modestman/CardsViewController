//
//  ViewController.swift
//  CardsViewController
//
//  Created by modestman on 06/17/2020.
//  Copyright (c) 2020 modestman. All rights reserved.
//

import UIKit
import CardsViewController

class ViewController: UIViewController {
    
    @IBOutlet private weak var stackView: UIStackView!
    let cardsController = CardsViewController()
    
    let colors: [UIColor] = [
        .systemPink,
        .systemTeal,
        .systemGreen,
        .systemBlue,
        .systemYellow,
        .systemPurple,
        .systemIndigo,
        .systemRed,
        .systemOrange
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(cardsController)
        view.addSubview(cardsController.view)
        cardsController.didMove(toParent: self)
        cardsController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardsController.view.topAnchor.constraint(equalTo: view.topAnchor),
            cardsController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cardsController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            cardsController.view.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        cardsController.cardEdgeInsets = UIEdgeInsets(top: 120, left: 30, bottom: 90, right: 30)
        cardsController.dataSource = self
        cardsController.delegate = self
        cardsController.reloadCards()
        
        view.bringSubviewToFront(stackView)
    }
    
    @IBAction private func performLeftAnimation() {
        cardsController.performCardSwipeAnimation(.putAtTheEnd, direction: .left)
    }
    
    @IBAction private func performRightAnimation() {
        cardsController.performCardSwipeAnimation(.throwOut, direction: .right)
    }
}

extension ViewController: CardsViewControllerDatasource {
    
    func numberOfItemsInCardsViewController(_ controller: CardsViewController) -> Int {
        return colors.count + 1
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        viewControllerAt index: Int) -> CardViewController {
        
        let vc: CardViewController
        if index < colors.count {
            vc = MyCardViewController()
            vc.view.backgroundColor = colors[index]
        } else {
            let reloadVC = ReloadViewController()
            reloadVC.action = { self.cardsController.reloadCards() }
            vc = reloadVC
        }
        return vc
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        decorationViewForCardAt index: Int) -> UIView? {
        
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.cornerRadius = 20
        shadowView.backgroundColor = UIColor.white
        shadowView.clipsToBounds = false
        return shadowView
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        transformForCardAt position: Int) -> CGAffineTransform {
        let transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(position) * 30.0)
        let scale = CGFloat(position) * -0.07 + 1.0
        return transform.scaledBy(x: scale, y: scale)
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        applyTransformFor card: UIView,
        at position: Int) {
        
        let transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(position) * 30.0)
        let scale = CGFloat(position) * -0.07 + 1.0
        card.transform = transform.scaledBy(x: scale, y: scale)
        card.alpha = 1
    }
}


extension ViewController: CardsViewControllerDelegate {
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        swipeAnimationAt index: Int,
        direction: SwipeDirection) -> SwipeAnimation {
        
        guard index != colors.count else { return .none }
        
        switch direction {
        case .right:
            return .throwOut
        case .left:
            return .putAtTheEnd
        case .up, .down:
            return .none
        }
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        tapAnimationAt index: Int) -> TapAnimation {
        
        return .flip
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        didMoveCardAt index: Int,
        direction: SwipeDirection,
        progress: Float) {
        
        print("Direction: \(direction.rawValue), progress: \(String(format: "%.2f", progress))")
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        finishMoveCardAt index: Int,
        direction: SwipeDirection,
        animation: SwipeAnimation) {
        print("finish")
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        cancelMoveCardAt index: Int) {
        print("cancel")
    }
}


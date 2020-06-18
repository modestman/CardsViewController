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
        
        addChildViewController(cardsController)
        view.addSubview(cardsController.view)
        cardsController.didMove(toParentViewController: self)
        cardsController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardsController.view.topAnchor.constraint(equalTo: view.topAnchor),
            cardsController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cardsController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            cardsController.view.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        cardsController.dataSource = self
        cardsController.delegate = self
        cardsController.reloadCards()
    }
}

extension ViewController: CardsViewControllerDatasource {
    
    func numberOfItemsInCardsViewController(_ controller: CardsViewController) -> Int {
        return colors.count + 1
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        viewControllerAtIndex index: Int) -> UIViewController {
        
        let vc: UIViewController
        if index < colors.count {
            vc = UIViewController()
            vc.view.backgroundColor = colors[index]
        } else {
            let reloadVC = ReloadViewController()
            reloadVC.action = { self.cardsController.reloadCards() }
            vc = reloadVC
        }
        vc.view.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        vc.view.layer.borderWidth = 1
        return vc
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        decorationViewForCardAt index: Int) -> UIView? {
        
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        shadowView.layer.shadowRadius = 6.0
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.cornerRadius = 8
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
}


extension ViewController: CardsViewControllerDelegate {
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        swipeAnimationAtIndex index: Int,
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
        tapAnimationAtIndex index: Int) -> TapAnimation {
        
        return .none
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        didMoveCardAtIndex: Int,
        direction: SwipeDirection,
        progress: Float) {
        
        print("Direction: \(direction.rawValue), progress: \(String(format: "%.2f", progress))")
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        finishMoveCardAtIndex: Int,
        direction: SwipeDirection,
        animation: SwipeAnimation) {
        print("finish")
    }
    
    func cardsViewController(
        _ cardsViewController: CardsViewController,
        cancelMoveCardAtIndex: Int) {
        print("cancel")
    }
}


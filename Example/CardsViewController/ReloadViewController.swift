//
//  ReloadViewController.swift
//  CardsControl
//
//  Created by Anton Glezman on 16.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit
import protocol CardsViewController.CardViewController

final class ReloadViewController: UIViewController, CardViewController {
    
    var frontView: UIView { view }
    var backView: UIView? = nil
    
    var action: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        
        let button = UIButton(type: .system)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        button.setTitle("Reset", for: .normal)
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
    }
    
    @objc private func reset() {
        action?()
    }
    
}

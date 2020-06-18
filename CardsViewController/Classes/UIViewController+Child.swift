//
//  UIViewController+Child.swift
//  Mnemo-Foundation
//
//  Created by Anton Glezman on 11.05.2020.
//  Copyright © 2020 Mnemo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addChild(_ childController: UIViewController, with guide: LayoutGuide) {
        addChild(childController)
        view.addSubview(childController.view, with: guide)
        childController.didMove(toParent: self)
    }
    
    func addChild(_ childController: UIViewController, into view: UIView? = nil) {
        addChild(childController)
        let containerView = view ?? self.view!
        containerView.addSubview(childController.view, with: containerView)
        childController.didMove(toParent: self)
    }
    
    func removeChild(_ childController: UIViewController) {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
    
}

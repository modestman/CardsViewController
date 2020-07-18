//
//  CardViewController.swift
//  CardsViewController_Example
//
//  Created by Anton Glezman on 18.07.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import protocol CardsViewController.CardViewController

final class MyCardViewController: UIViewController, CardViewController {
    
    var frontView: UIView { view }
    
    lazy var backView: UIView? = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "card")
        view.frame = self.view.frame
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
}

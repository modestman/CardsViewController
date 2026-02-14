//
//  LayoutGuide.swift
//  Mnemo-Foundation
//
//  Created by Anton Glezman on 11.05.2020.
//  Copyright © 2020 Mnemo. All rights reserved.
//

import UIKit

/// Обобщенный тип лайаут гайда.
///
/// - Note: Обобщение `UIView` и `UILayoutGuide`.
protocol LayoutGuide {
    /// Верхний край.
    var topAnchor: NSLayoutYAxisAnchor { get }
    /// Нижний край.
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    /// Правый край.
    var rightAnchor: NSLayoutXAxisAnchor { get }
    /// Левый край.
    var leftAnchor: NSLayoutXAxisAnchor { get }
}

extension UIView: LayoutGuide {}
extension UILayoutGuide: LayoutGuide {}

extension UIView {
    
    /// Добавить сабвью вместе с лайаут гайдом.
    /// ```
    /// final class TextCell: UICollectionViewCell {
    ///     let textLabel = UILabel()
    ///
    ///     override init(frame: CGRect) {
    ///         super.init(frame: frame)
    ///         addSubview(textLabel, with: layoutMarginsGuide)
    ///         // addSubview(textLabel, with: self)
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - subview: Сабвью.
    ///   - guide: Гайд, к краям которого будет крепиться вью.
    func addSubview(_ subview: UIView, with guide: LayoutGuide) {
        assert((guide as? UIView) != subview, "Края сабвью не могут быть привазаны к ней же")
        addSubview(subview, activate: [
            subview.topAnchor.constraint(equalTo: guide.topAnchor),
            subview.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            subview.rightAnchor.constraint(equalTo: guide.rightAnchor),
            subview.leftAnchor.constraint(equalTo: guide.leftAnchor)
        ])
    }
    
    /// Добавить сабвью и активировать констрейнты.
    ///
    /// - Parameters:
    ///   - subview: Сабвью.
    ///   - constraints: Констрейнты создаются из замыкания после, того как `subview` будет добавлена.
    func addSubview(_ subview: UIView, activate constraints: @autoclosure () -> [NSLayoutConstraint]) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate(constraints())
    }
}

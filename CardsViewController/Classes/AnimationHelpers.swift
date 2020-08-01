//
//  AnimationHelpers.swift
//  CardsControl
//
//  Created by Anton Glezman on 15.06.2020.
//  Copyright © 2020 Anton Glezman. All rights reserved.
//

import UIKit

/// Helper methods for transform calculation during the animation
struct AnimationHelpers {
    
    static let fastAnimationDuration: TimeInterval = 0.2
    static let defaultAnimationDuration: TimeInterval = 0.3
    static let longAnimationDuration: TimeInterval = 0.4
    
    
    /// Расчет направления движения с учетом пропорций экрана
    /// - Parameter velocity: вектор скорости
    /// - Parameter frame: размеры экрана
    /// - Returns: направление `SwipeDirection`
    static func direction(with velocity: CGPoint, in frame: CGRect = UIScreen.main.bounds) -> SwipeDirection {
        guard velocity.length != 0 else { fatalError() }
        
        let angle = atan2(velocity.y, velocity.x)
        let topLeftAngle = atan2(-frame.height, -frame.width)
        let topRightAngle = atan2(-frame.height, frame.width)
        let bottomRightAngle = atan2(frame.height, frame.width)
        let bottomLeftAngle = atan2(frame.height, -frame.width)
        
        if velocity.y >= 0 {
            switch angle {
            case 0...bottomRightAngle:
                return .right
            case bottomRightAngle...bottomLeftAngle:
                return .down
            case bottomLeftAngle...CGFloat.pi:
                return .left
            default:
                fatalError()
            }
        } else {
            switch angle {
            case (-CGFloat.pi)...topLeftAngle:
                return .left
            case topLeftAngle...topRightAngle:
                return .up
            case topRightAngle...0:
                return .right
            default:
                fatalError()
            }
        }
    }
    
    /// Расчет перемещения, чтобы карточка вылетела за пределы заданного фрейма
    /// - Parameters:
    ///   - frame: фрейм заданной области, например экрана
    ///   - velocity: вектор скорости, определяет направление движения
    /// - Returns: вектор перемещения
    static func translationOut(of frame: CGRect, velocity: CGPoint) -> CGPoint {
        guard velocity.length != 0 else { return .zero }
        let direction = self.direction(with: velocity)
        let e = CGVector(dx: velocity.x / velocity.length, dy: velocity.y / velocity.length)
        let destination: CGPoint
        switch direction {
        case .left, .right:
            let tan = e.dy / e.dx
            let x = frame.width * (e.dx > 0 ? 1 : -1)
            destination = CGPoint(x: x, y: x * tan)
            
        case .up, .down:
            let ctg = e.dx / e.dy
            let y = frame.height * (e.dy > 0 ? 1 : -1)
            destination = CGPoint(x: y * ctg, y: y)
        }
        return destination
    }
    
    /// Make CGAffineTransform for card
    /// - Parameter visibleIndex: index for visible views on screen
    static func transform(for visibleIndex: Int) -> CGAffineTransform {
        let transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(visibleIndex) * 30.0)
        let scale = CGFloat(visibleIndex) * -0.07 + 1.0
        return transform.scaledBy(x: scale, y: scale)
    }
    
    static func velosity(for direction: SwipeDirection) -> CGPoint {
        let const = 2000
        switch direction {
        case .right:
            return CGPoint(x: const, y: -const/2)
        case .left:
            return CGPoint(x: -const, y: const/2)
        case .up:
            return CGPoint(x: const/2, y: -const)
        case .down:
            return CGPoint(x: -const/2, y: const)
        }
    }
}

//
//  UIButton.swift
//  MyData
//
//  Created by UMCios on 2022/01/14.
//

import UIKit

extension UIButton {
    
    func setTitle(_ title: String? = "", titleColor: UIColor?, for: UIControl.State = .normal) {
        setTitle(title, for: state)
        if let color = titleColor {
            setTitleColor(color, for: state)
        }
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color?.cgColor ?? UIColor.white.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(backgroundImage, for: state)
    }
}

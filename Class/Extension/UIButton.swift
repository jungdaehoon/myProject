//
//  UIButton.swift
//  MyData
//
//  Created by UMCios on 2022/01/14.
//

import UIKit

extension UIButton {
    /**
     컬러정보를 받아 이미지로 적용 합니다. ( on/off 타입에 주로 사용 ) ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.09
     - Parameters:
        - color : 적용할 컬러 타입입니다.
        - state : 버튼 타입 입니다.
     - Throws : False
     - returns :False
     */
    func setBackgroundColorToImage(_ color: UIColor?, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color?.cgColor ?? UIColor.white.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(backgroundImage, for: state)
    }
}

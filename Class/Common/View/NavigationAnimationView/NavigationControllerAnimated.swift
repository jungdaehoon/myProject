//
//  NavigationControllerAnimated.swift
//  MyData
//
//  Created by daehoon on 2022/05/24.
//

import UIKit


/**
 내비 컨트롤러 페이지 이동시 애니 타입별 효과 지원 클래스 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2022.05.24
 */
class NavigationControllerAnimated : NSObject, UIViewControllerAnimatedTransitioning {
    /// 애니 효과 타임 정보 입니다.
    var duration        : CGFloat           = 0.35
    /// 애니 효과 타입 입니다.
    var animationType   : AnimationType?    = nil
    
    
    /**
     애니 효과 타입 받아 페이지 이동시 효과를 주는 클래스를 초기화 합니다.
     - Date : 2022.05.24
     - Parameters:
        - animationType : 페이지 이동할 효과 정보를 받습니다.
     - Throws : False
     - returns :Self
     */
    init(animationType: AnimationType?) {
        self.animationType = animationType!
    }
    
    
    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
      
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView   = transitionContext.containerView
        let toView          = transitionContext.view(forKey: .to)!
        containerView.addSubview(toView)
        /// 화면 줌 효과 입니다.
        if self.animationType == .zoom
        {
            toView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        /// 왼쪽에서 오른쪽으로 페이지 디스플레이 입니다.
        if self.animationType == .right
        {
            toView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width * -1, y: 0)
        }
        
        /// 아래에서 위로 올라오는 효과 입니다.
        if self.animationType == .up
        {
            toView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
        }
        
        /// 위에서 아래로 내려오는 효과 입니다.
        if self.animationType == .down
        {
            toView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height * -1)
        }
        
        /// 애니 효과를 추가 합니다.
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations:  {
            if self.animationType == .zoom
            {
                toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            
            if self.animationType == .up ||
               self.animationType == .down ||
               self.animationType == .right
            {
                toView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            
        }, completion: { _ in
            transitionContext.completeTransition(true)
          })
        
    }
}

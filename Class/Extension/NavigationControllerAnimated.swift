//
//  NavigationControllerAnimated.swift
//  MyData
//
//  Created by daehoon on 2022/05/24.
//

import UIKit


/**
 내비 컨트롤러 페이지 이동시 애니 타입별 효과 지원 클래스 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.04.12
 */
class NavigationControllerAnimated : NSObject, UIViewControllerAnimatedTransitioning {
    /// 애니 효과 타임 정보 입니다.
    var duration        : CGFloat           = 0.35
    /// 애니 효과 타입 입니다.
    var pushAnimation   : AnimationType?    = nil
    var popAnimation    : AnimationType?    = nil
    
    
    /**
     애니 효과 타입 받아 페이지 집인 이동시 효과를 주는 클래스를 초기화 합니다. ( J.D.H VER : 1.0.0 )
     - Date: 2023.04.12
     - Parameters:
        - animationType : 페이지 이동할 효과 정보를 받습니다.
     - Throws: False
     - Returns:Self
     */
    init( pushAnimation: AnimationType  ) {
        self.pushAnimation = pushAnimation
    }
    
    
    /**
     애니 효과 타입 받아 페이지 종료 이동시 효과를 주는 클래스를 초기화 합니다. ( J.D.H VER : 1.0.0 )
     - Date: 2023.04.12
     - Parameters:
        - animationType : 페이지 이동할 효과 정보를 받습니다.
     - Throws: False
     - Returns:Self
     */
    init( popAnimation: AnimationType  ) {
        self.popAnimation = popAnimation
    }
    
    
    
    // MARK: - UIViewControllerAnimatedTransitioning
    /// 애니 효과 동작 시간을 정의 합니다.
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return duration
    }
      
    /// 애니 효과 효과를 적용 합니다.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView          = transitionContext.containerView
        var toView      : UIView?  = nil
        var fromView    : UIView?  = nil
        /// 화면 줌 효과 입니다.
        if self.pushAnimation == .zoom
        {
            toView = transitionContext.view(forKey: .to)!
            containerView.addSubview(toView!)
            toView!.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        
        /// 왼쪽에서 오른쪽으로 페이지 디스플레이 입니다.
        if self.pushAnimation == .right
        {
            toView = transitionContext.view(forKey: .to)!
            containerView.addSubview(toView!)
            toView!.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width * -1, y: 0)
        }
        
        /// 아래에서 위로 올라오는 효과 입니다.
        if self.pushAnimation == .up
        {
            toView = transitionContext.view(forKey: .to)!
            containerView.addSubview(toView!)
            toView!.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
        }
        
        /// 아래에서 위로 올라오는 효과 입니다.
        if self.pushAnimation == .down
        {
            toView = transitionContext.view(forKey: .to)!
            containerView.addSubview(toView!)
            toView!.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height * -1)
        }
        
        
        /// 화면 줌 효과 입니다.
        if self.popAnimation == .zoom
        {
            toView              = transitionContext.view(forKey: .to)!
            containerView.insertSubview(toView!, at: containerView.subviews.count - 1)
            fromView            = containerView.subviews.last
            let transform       = CGAffineTransform(translationX: 0, y: 0)
            fromView!.transform = transform.concatenating(CGAffineTransform(translationX: 1.0, y: 1.0))
        }
        
        
        /// 위로 올라오는 효과 입니다.
        if self.popAnimation == .right
        {
            toView              = transitionContext.view(forKey: .to)!
            containerView.insertSubview(toView!, at: containerView.subviews.count - 1)
            fromView            = containerView.subviews.last
            fromView!.transform = CGAffineTransform(translationX: 0, y: 0)
            toView!.transform   = CGAffineTransform(translationX: 0 - (fromView!.frame.size.width/3), y: 0)
        }
        
        /// 위로 올라오는 효과 입니다.
        if self.popAnimation == .up
        {
            toView              = transitionContext.view(forKey: .to)!
            containerView.insertSubview(toView!, at: containerView.subviews.count - 1)
            fromView            = containerView.subviews.last
            fromView!.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        
        /// 아래로 내려오는 효과 입니다.
        if self.popAnimation == .down
        {
            toView              = transitionContext.view(forKey: .to)!
            containerView.insertSubview(toView!, at: containerView.subviews.count - 1)
            fromView            = containerView.subviews.last
            fromView!.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        
        /// 애니 효과를 추가 합니다.
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations:  {
            
            if self.pushAnimation != nil
            {
                switch self.pushAnimation
                {
                case .zoom:
                    toView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                case .up, .right, .down:
                    toView!.transform = CGAffineTransform(translationX: 0, y: 0)
                default:break
                }
                return
            }
            
            if self.popAnimation != nil
            {
                switch self.popAnimation
                {
                case .zoom:
                    let transform       = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
                    fromView!.transform = transform.concatenating(CGAffineTransform(translationX: 0.0, y: 0.0))
                case .right:
                    fromView!.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width, y: 0)
                    toView!.transform   = CGAffineTransform(translationX: 0, y: 0)
                case .up:
                    fromView!.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height * -1)
                case .down:
                    fromView!.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
                default:break
                }
                return
            }
        }, completion: { _ in
            transitionContext.completeTransition(true)
          })
        
    }
}

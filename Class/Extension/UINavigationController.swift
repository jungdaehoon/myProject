//
//  UINavigationController.swift
//  MyData
//
//  Created by UMCios on 2022/01/07.
//

import UIKit

/// 애니 효과 타입을 가집니다.
public enum AnimationType
{
    case left
    case right
    case up
    case down
    case zoom
}

class UINavigationControllerExtensionModel : NSObject
{
    /// 기본 애니 효과 정보를 가집니다.
    static var pushAnimation: AnimationType? = .left
    /// 기본 애니 효과 정보를 가집니다.
    static var popAnimation: AnimationType?  = .right
}

protocol UINavigationControllerExtension : UINavigationController{}
extension UINavigationControllerExtension where Self : UINavigationController
{
    /// 애니 효과를 받습니다.
    var pushAnimation : AnimationType? {
        get { UINavigationControllerExtensionModel.pushAnimation == nil ? .left : UINavigationControllerExtensionModel.pushAnimation! }
        set { UINavigationControllerExtensionModel.pushAnimation = newValue }
    }
    /// 애니 효과를 받습니다.
    var popAnimation : AnimationType? {
        get { UINavigationControllerExtensionModel.popAnimation == nil ? .right : UINavigationControllerExtensionModel.popAnimation! }
        set { UINavigationControllerExtensionModel.popAnimation = newValue }
    }
}

extension UINavigationController : UINavigationControllerExtension {
    
    var rootViewController: UIViewController? {
        return viewControllers.first
    }
    
    func finish() {
        if viewControllers.count == 1 {
            exit(0)
        } else {
            popViewController(animated: true)
        }
    }
    
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void)
    {
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    
    /**
     내비게이션 컨트롤로 push 이동시 타입을 받아 처리 합니다.
     - Date : 2023.04.12
     - Parameters:
        - viewController : 이동할 페이지 입니다.
        - animated : 효과 여부 입니다.
        - animationType : 페이지 이동할 효과 정보를 받습니다.
        - completion : 페이지 이동후 콜백 입니다.
     - Throws : False
     - returns :False
     */
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        animatedType: AnimationType? = .left,
        completion: @escaping () -> Void = {})
    {
        self.pushAnimation = animatedType!
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    
    /**
     내비게이션 컨트롤로 현 페이지를 종료 합니다.
     - Date : 2023.04.17
     - Parameters:
        - animated : 효과 여부 입니다.
        - animationType : 페이지 이동할 효과 정보를 받습니다.
        - completion : 페이지 이동후 콜백 입니다.
     - Throws : False
     - returns :False
     */
    func popViewController(
        animated: Bool,
        animatedType: AnimationType? = .down,
        completion: @escaping () -> Void)
    {
        self.popAnimation = animatedType!
        popViewController(animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    
    func popToRootViewController(
        animated: Bool,
        completion: @escaping () -> Void)
    {
        popToRootViewController(animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    /**
     내비게이션 컨트롤로 이동시 현 페이지를 삭제하고 추가할 페이지로 변경합니다.
     - Date : 2023.04.12
     - Parameters:
        - viewController : 이동할 페이지 입니다.
        - animated : 애니 효과 입니다.
     - Throws : False
     - returns :False
     */
    func replaceViewController( viewController:UIViewController, animated : Bool = true, completion: @escaping () -> Void ) {
        let vcs                         = self.viewControllers
        var newVcs:[UIViewController]   = vcs
        newVcs.removeLast()
        newVcs.append(viewController)
        self.setViewControllers(newVcs, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
        
    }
    
    
    /**
     내비게이션 컨트롤로 이동시 0번재 root 페이지 다음에 추가할 페이지로 변경합니다.
     - Date : 2023.04.12
     - Parameters:
        - viewController : 이동할 페이지 입니다.
     - Throws : False
     - returns :False
     */
    func rootNextViewController( viewController:UIViewController, animated: Bool = true) {
        let vcs                         = self.viewControllers
        var newVcs:[UIViewController]   = []
        newVcs.append(vcs[0])
        newVcs.append(viewController)
        self.setViewControllers(newVcs, animated: true)
    }
    
    
    /**
     내비게이션 컨트롤로 이동시 0번재 root 페이지 다음에 추가할 페이지들로 변경합니다.
     - Date : 2023.04.12
     - Parameters:
        - viewControllers : 이동할 페이지들 입니다.
     - Throws : False
     - returns :False
     */
    func rootNextViewController( viewControllers: [UIViewController], animated: Bool = true) {
        let vcs                         = self.viewControllers
        var newVcs:[UIViewController]   = []
        newVcs.append(vcs[0])
        for viewController in viewControllers
        {
            newVcs.append(viewController)
        }
        self.setViewControllers(newVcs, animated: true)
    }
    
    
    /// Given the kind of a (UIViewController subclass),
    /// returns true if self's viewControllers array contains at
    /// least one matching instance.
    func containsViewController(ofKind kind: AnyClass) -> Bool
    {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
    
}

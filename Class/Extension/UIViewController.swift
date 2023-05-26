//
//  UIViewController.swift
//  MyData
//
//  Created by UMCios on 2022/01/06.
//

import UIKit

extension UIViewController {
    func isVisible() -> Bool {
        return self.isViewLoaded && self.view.window != nil
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer (
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    /**
     컨트롤러를 받아 다음 페이지로 이동 합니다.
     - Date: 2023.04.12
     - Parameters:
        - viewController : 이동할 페이지 입니다.
        - modalPresent : 모달 타입으로 페이지 이동 경우 입니다. ( default : false )
        - animated : 효과 여부 입니다.
        - animationType : 페이지 이동할 효과 정보를 받습니다.
        - completion : 페이지 이동후 콜백 입니다.
     - Throws: False
     - Returns:False
     */
    func pushController( _ viewController: UIViewController, modalPresent : Bool = false, animated: Bool, animatedType: AnimationType? = .left, completion: @escaping () -> Void = {})
    {
        if let navigation = self.navigationController,
           modalPresent == false
        {
            navigation.pushViewController(viewController, animated: true, animatedType: animatedType,completion: completion)
        }
        else
        {
            self.present(viewController, animated: true,completion: completion)
        }
    }
    
    
    /**
     컨트롤로 현 페이지를 종료 합니다.
     - Date: 2023.04.17
     - Parameters:
        - animated : 효과 여부 입니다.
        - animationType : 페이지 이동할 효과 정보를 받습니다.
        - completion : 페이지 이동후 콜백 입니다.
     - Throws: False
     - Returns:False
     */
    func popController( animated: Bool, animatedType: AnimationType? = .down, completion: (( _ firstViewController : UIViewController? ) -> Void)? = nil) {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: animated, animatedType: .down) {
                if let viewController = navigation.viewControllers.last
                {
                    if completion != nil { completion!(viewController) }
                }
            }
        }
        else
        {
            let viewController = self.presentingViewController
            self.dismiss(animated: animated) {
                if let contollelr = viewController
                {
                    if completion != nil { completion!(contollelr) }
                }
            }
        }
    }
    
    
    /**
     이동할 컨트롤러를 받아 해당 컨트롤로러 이동합니다.
     - Date: 2023.05.19
     - Parameters:
        - viewController : 이동할 ViewController 입니다.
        - animated : 효과 여부 입니다.
        - animationType : 페이지 이동할 효과 정보를 받습니다.
        - completion : 페이지 이동후 콜백 입니다.
     - Throws: False
     - Returns:False
     */
    func popToController( _ viewController: UIViewController, animated: Bool, animatedType: AnimationType? = .down, completion: @escaping () -> Void = {}) {
        if let navigation = self.navigationController {
            navigation.popToViewController(viewController, animated: animated, animatedType:animatedType,completion: completion)
        }
    }
    
    
    /**
     컨트롤로 0번 페이지로 이동합니다.
     - Date: 2023.04.17
     - Parameters:
        - animated : 효과 여부 입니다.
        - animationType : 페이지 이동할 효과 정보를 받습니다.
        - completion : 페이지 이동후 콜백 입니다.
     - Throws: False
     - Returns:False
     */
    func popToRootController( animated: Bool, animatedType: AnimationType? = .down, completion: (( _ firstViewController : UIViewController? ) -> Void)? = nil) {
        if let navigation = self.navigationController {
            navigation.popToRootViewController(animated: animated, animatedType: .down) {
                if let viewController = navigation.viewControllers.last
                {
                    if completion != nil { completion!(viewController) }
                }
            }
        }
        else
        {
            self.dismissToRoot(animated: true) { firstViewController in
                if completion != nil { completion!(firstViewController) }
            }
        }
    }
    
    
    /**
     현 페이지를 삭제하고 추가할 페이지로 변경합니다.
     - Date: 2023.05.03
     - Parameters:
        - viewController : 이동할 페이지 입니다.
        - animated : 애니 효과 입니다.
        - animationType : 페이지 이동할 효과 정보를 받습니다.
     - Throws: False
     - Returns:False
     */
    func replaceController( viewController: UIViewController, animated : Bool = true, animatedType: AnimationType? = .down, completion: @escaping () -> Void = {}) {
        if let navigation = self.navigationController {
            navigation.replaceViewController(viewController: viewController, animated: animated, animatedType: animatedType, completion: completion)
        }
        else
        {
            if let viewcontroller = self.presentingViewController
            {
                self.dismiss(animated: false){
                    viewcontroller.present(viewController, animated: true)
                }
            }
            
        }
    }
    
    
    /**
     present로 연결된 ViewControllers 를 0번째 Root ViewController 이동 하도록 합니다.
     - Date: 2023.05.03
     - Parameters:
        - animated : 종료시 애니 효과 적용 입니다.
        - completion : 페이지 최종 이동 종료후 리턴 이벤트 입니다.
     - Throws: False
     - Returns:
        파라미터 정보를 정리하여 리턴 합니다. ([String : Any])
     */
    func dismissToRoot( animated : Bool = true, completion: (( _ firstViewController : UIViewController? ) -> Void)? = nil ){
        var presents    = [UIViewController?]()
        var ingPresent   = self.presentingViewController
        /// 현 ViewController 추가 합니다.
        presents.append(self)
        /// 이전 연결된 ViewControllers 전부 추가 합니다.
        while ingPresent != nil
        {
            presents.append(ingPresent)
            ingPresent = ingPresent!.presentingViewController
        }
        /// 0번째 ViewController 로 이동 합니다.
        for index in 0..<presents.count-1
        {
            if let pvc = presents[index]
            {
                if index == presents.count - 2
                {
                    /// 0번째 ViewController 입니다.
                    let rootViewcontroller = pvc.presentingViewController
                    pvc.dismiss(animated: animated) {
                        /// 0번째 ViewController 를 넘깁니다.
                        completion!(rootViewcontroller)
                    }
                }
                else
                {
                    pvc.dismiss(animated: false) {}
                }
            }
        }
    }
    
    
    
    
    
    
}

protocol StoryBoardInstantiable {}

extension UIViewController: StoryBoardInstantiable {}

extension StoryBoardInstantiable where Self: UIViewController {
    static func instantiate() -> Self? {
        let storyboard = UIStoryboard(name: self.className, bundle: nil)
        if let instance = storyboard.instantiateViewController(withIdentifier: self.className) as? Self {
            return instance
        }
        Slog("\(self.className) is nil")
       // Tool.debugLog("\(self.className) is nil")
        return nil
    }

    static func instantiate(withStoryboard storyboard: String) -> Self? {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        if let instance = storyboard.instantiateViewController(withIdentifier: self.className) as? Self {
            return instance
        }
        Slog("\(storyboard) is nil")
        return nil
    }
}


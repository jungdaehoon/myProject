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
     present로 연결된 ViewControllers 를 0번째 Root ViewController 이동 하도록 합니다.
     - Date : 2023.05.3
     - Parameters:
        - animated : 종료시 애니 효과 적용 입니다.
        - completion : 페이지 최종 이동 종료후 리턴 이벤트 입니다.
     - Throws : False
     - returns :
        - [String : Any]
            + 파라미터 정보를 정리하여 리턴 합니다.
     */
    func dismissToRoot( animated : Bool = true, completion: (() -> Void)? = nil ){
        var presents    = [UIViewController?]()
        var ingPresent   = self.presentingViewController
        
        /// 전체 연결된 ViewControllers 찾습니다.
        while ingPresent != nil
        {
            presents.append(ingPresent)
            ingPresent = ingPresent!.presentingViewController
        }
        
        /// 0번째 ViewController 로 이동 합니다.
        for index in 0..<presents.count
        {
            if let pvc = presents[index]
            {
                pvc.dismiss(animated: index == presents.count - 1 ? animated : false, completion: completion )
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


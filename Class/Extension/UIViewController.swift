//
//  UIViewController.swift
//  MyData
//
//  Created by UMCios on 2022/01/06.
//

import UIKit

extension UIViewController {
    
    func finish(_ animated: Bool) {
        guard let presentingViewController = presentingViewController else {
            navigationController?.popViewController(animated: animated)
            return
        }
        presentingViewController.dismiss(animated: animated)
    }
    
    func finish(_ animated: Bool, _ completion: @escaping () -> Void) {
        guard let presentingViewController = presentingViewController else {
            navigationController?.popViewController(animated: animated)
            return
        }
        presentingViewController.dismiss(animated: animated, completion: completion)
    }
    
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


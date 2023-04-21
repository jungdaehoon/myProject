//
//  LoadingBarInterface.swift
//  cereal
//
//  Created by srkang on 2018. 7. 19..
//  Copyright © 2018년 srkang. All rights reserved.
//

// LoadingBarInterface 인터페이스는 사용하지 않음.
// CerealMainWebViewController.swift 에서 구현함.
// 웹뷰의 로딩바와, 하이브리드 로딩바와 충돌이 많어 제어가 안됨. ( 하이브리드에서 너무 많이 Show,Hide 하고, Hide 를 제대로 안하는 경우도 생길수 있어서
// CerealMainWebViewController 으로 통합함.)
// CerealMainWebViewController 클래스안에 webViewHud 멤버변수로 제어 함.

import UIKit


class LoadingBarInterface : NSObject{
    
    static let COMMAND_SHOW = "showLoadingBar" // 로딩바 보여주기
    static let COMMAND_HIDE = "hideLoadingBar" // 로딩바 숨기기
    
    static var loadingBarHud : MBProgressHUD?
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        super.init()
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        //log?.debug("LoadingBarInterface")
    }
}

extension LoadingBarInterface : HybridInterface {
    
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        let action = command[1] as! String
        
        // 로딩바 보여주기
        if action == LoadingBarInterface.COMMAND_SHOW {
            
            if let loadingBarHud = LoadingBarInterface.loadingBarHud {
                loadingBarHud.show(animated: true)
            } else {
                
                LoadingBarInterface.loadingBarHud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
            }
            
            LoadingBarInterface.loadingBarHud?.layer.zPosition = 20;
            
        } else if action == LoadingBarInterface.COMMAND_HIDE {
            // 로딩바 숨기기
            if let loadingBarHud = LoadingBarInterface.loadingBarHud {
                loadingBarHud.hide(animated: true)
            }
            
            LoadingBarInterface.loadingBarHud?.layer.zPosition = 0;
            
            
        }
        
    }
}




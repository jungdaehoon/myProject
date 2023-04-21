//
//  SNSInterface.swift
//  cereal
//
//  Created by srkang on 2018. 8. 16..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit

class SNSInterface {
    
    static let COMMAND_SHARE_KAKAOTALK = "shareKakaotalk" // 카카오톡 링크 공유 
    
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        //log?.debug("SNSInterface")
    }
}

extension SNSInterface : HybridInterface {
    
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        let action = command[1] as! String
        let args = command[2] as! Array<Any>
        
        // 카카오톡 링크 공유
        if action == SNSInterface.COMMAND_SHARE_KAKAOTALK {
            sendKakaoTalk(args: args)
        }
        
    }
    
    
    func sendKakaoTalk(args : Array<Any>) {
        
        let message = args[0] as! String // 공유할 메시지
        let url = args[1] as! String  // 링크 URL
//        let param = args[2] as! String // 링크 파라미터
        
        let template = KMTTextTemplate { (textTemplateBuilder) in
            
            textTemplateBuilder.text =  message;
            
            // 네이티브 이기 때문에 mobileWebURL 은 의미는 없지만,
            // builder 의 link 속성 안 넣으면 오류가 발생함.
            textTemplateBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                // main.do 를 링크
                linkBuilder.mobileWebURL = URL(string: WebPageConstants.baseURL + "/main.do")
            })
            
            
            textTemplateBuilder.addButton(KMTButtonObject(builderBlock: { (buttonBuilder) in
                buttonBuilder.title = "앱으로 연결"
//                buttonBuilder.mobileWebURL = URL(string: NetworkInterface.MAIN_URL)
                buttonBuilder.link = KMTLinkObject(builderBlock: { (linkBuilder) in
                   linkBuilder.mobileWebURL = URL(string: url)
//                   linkBuilder.iosExecutionParams = ""
                    
                })
            }))
            
        }
        
        // 카카오링크 실행
        KLKTalkLinkCenter.shared().sendDefault(with: template, success: { (warningMsg, argumentMsg) in
            // 성공 콜백 , 하이브리드에 딱히 콜백 넘겨주지 않음
            //log?.debug("warning message: \(String(describing: warningMsg))")
            //log?.debug("argument message: \(String(describing: argumentMsg))")
            
        }, failure: { (error) in
            // 실패 콜백 , 하이브리드에 딱히 콜백 넘겨주지 않음
            
        })
    }
    
    
    
}

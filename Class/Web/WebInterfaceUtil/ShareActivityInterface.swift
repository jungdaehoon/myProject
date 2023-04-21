//
//  ShareActivityInterface.swift
//  cereal
//
//  Created by srkang on 2018. 7. 4..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit

class ShareActivityInterface {
    
    static let COMMAND_SHARE_SNS = "shareSNS" //  SNS 공유 
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        //log?.debug("ShareActivityInterface")
    }
}

extension ShareActivityInterface : HybridInterface {
    
    // UIActivityViewController 통해서 공유한다.
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        var args = command[2] as! Array<Any>
        
        let text = args[0] as! String // message : 공유하려는 문자 메시지
        
        let things : [Any] = [text] // message 가 String 타입 이라, UIActivityViewController 에서  String 타입을 공유 할 수 있는 앱목록을 보여준다.
        let avc = UIActivityViewController(activityItems:things, applicationActivities:nil)
        
        // ios8
        avc.completionWithItemsHandler = {
            type, ok, items, err in
            //com.iwilab.KakaoTalk.Share  , false , nil, nil
            //e(_rawValue: com.iwilab.KakaoTalk.Share)) true nil nil
            //com.apple.mobilenotes.SharingExtension)) true nil nil
            //log?.debug("completed \(type as Any) \(ok) \(items as Any) \(err as Any)")
            
        }
        
        // openInIBooks 은 iOS9 부터
        // 제외 항목 리스트 (메일, 페이스북, 트위터등)
        // 원래 목적이 SNS (카카오톡) 통해서, 문자 공유
        avc.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .message,
            .mail,
            .print,
            .copyToPasteboard,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .airDrop,
//            .openInIBooks,
            //.markupAsPDF,
        ]
        // avc.excludedActivityTypes = nil
        viewController.present(avc, animated:true)
        
        
    }
}

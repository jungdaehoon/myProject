//
//  SMSSendInterface.swift
//  cereal
//
//  Created by srkang on 2018. 7. 19..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit
import MessageUI

class SMSSendInterface : NSObject{
    
    static let COMMAND_SEND_SMS = "sendSMS"
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        super.init()
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        //log?.debug("SMSSendInterface")
    }
}

extension SMSSendInterface : HybridInterface {
    
    // SMS 문자 공유
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        var args = command[2] as! Array<Any>
        
        let text = args[0] as! String // SMS 통해서 공유하려는 문자 메시지
        
        
       // MFMessageComposeViewController 통해서 문자 공유
        let messageVC = MFMessageComposeViewController()
        messageVC.body = text
        messageVC.recipients = [] // 수신인, 수신인은 직접 MFMessageComposeViewController 통해서 선택
        messageVC.messageComposeDelegate = self
        
        if MFMessageComposeViewController.canSendText() {
            viewController.present(messageVC, animated: true, completion: nil)
        }
        
        
    }
}

extension SMSSendInterface : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            viewController.dismiss(animated: true, completion: nil)
        case .failed:
            viewController.dismiss(animated: true, completion: nil)
        case .sent:
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}

//
//  HybridInterface.swift
//  cereal
//
//  Created by srkang on 2018. 7. 3..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit

enum CerealError: Error {
    case businessError(reason: String)
}
typealias ResultCallback =  (HybridResult) -> ()
typealias Command = Array<Any>

enum HybridResult {
    case progress(message:Any)
    case success(message:Any)
    case fail(error :Error,  errorMessage:String)
    case cancel
}
protocol HybridInterface: class {
    func command(viewController : UIViewController , command : Command , result: @escaping (_ result : HybridResult) -> () )
    func afterNotify(_ data : Any)
}


extension HybridInterface {
    func afterNotify(_ data : Any) {
        
    }
}

//
//  AppshieldManager.swift
//  cereal
//
//  Created by 아프로 on 2022/01/18.
//  Copyright © 2022 srkang. All rights reserved.
//

import Foundation
import UIKit


/**
 앱 실드 지원 메니저 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.27
 */
class AppshieldManager
{
    /// 도메인 URL 정보를 가져 옵니다.
    static let APPIRON_AUTHCHECK_URL = Bundle.main.infoDictionary?["APPIRON_URL"] as? String ?? ""
    static let sharedInstance = AppshieldManager()
    var mAlertView: UIAlertController?
    
    enum Result {
       case success(BSAppIronResult)
       case failure(NSError)
    }
    
    private init() {}
    
    func authApp(completion: @escaping (Result) -> Void) {
        /*---------------------------------------------------------------------------*
         * 진행 Alert 보이기
         *---------------------------------------------------------------------------*/
        DispatchQueue.global(qos: .default).async(execute: {
            var aError: Error? = nil
            var aAppIronResult: BSAppIronResult? = nil
            do {
                /*---------------------------------------------------------------------------*
                 * 앱아이언 검증서버 url
                 *---------------------------------------------------------------------------*/
//                let APPIRON_AUTHCHECK_URL = "http://inspect.appiron.com/authCheck.call"
                /*---------------------------------------------------------------------------*
                 * 1차 무결성 검증 수행
                 *---------------------------------------------------------------------------*/
                let aAppiron = BSAppIron.getInstance()
                aAppIronResult = try aAppiron?.authenticateApp(withUrl: AppshieldManager.APPIRON_AUTHCHECK_URL, timeout: 30)
            
                completion(.success(aAppIronResult!))
            } catch {
                aError = error;
                
                completion(.failure(aError! as NSError))
            }
       
        })
    }
    
}

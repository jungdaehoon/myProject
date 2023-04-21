//
//  LoginInterface.swift
//  cereal
//
//  Created by srkang on 2018. 8. 27..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit

class LoginInterface: NSObject {
    
    static let COMMAND_CHECK_LOGIN                  = "checkLogin" // 로그인 여부 체크 , 올리고에서는 사용하지 않음
    static let COMMAND_GET_LOGIN_INFO               = "getLoginInfo" // 로그인 정보 , 올리고에서는 사용하지 않음
    static let COMMAND_CALL_LOGIN                   = "callLogin" // 로그인창 띄우기
    static let COMMAND_AUTO_LOGIN_SETTING           = "autoLoginSetting" // 자동로그인 설정
    static let COMMAND_SET_LOGOUT                   = "setLogout" // 로그아웃
    static let COMMAND_SET_NICK_NAME                = "setNickName" //닉네임 변경. 슬라이딩 메뉴에 있는 닉네임도 같이 변경 하기 위해서
    static let COMMAND_SET_PROFILE_DEFAULT_IMAGE    = "setProfileDefaultImage" // 프로필 디폴트이미지 설정
    static let COMMAND_SET_ALARM_COUNT              = "setAlramCount" // 알람 카운트 변경 Noti
    static let COMMAND_SET_INVESTMENT_TYPE          = "setInvestmentType" // 투자 성향명 변경
    static let COMMAND_SAVE_TOKEN                   = "saveToken" // 로그인 토큰 저장
    
    
    static let COMMAND_CALL_LOGIN_DIRECT            = "callLoginDirect" // 로그인창 띄우기
    
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        super.init()
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        //log?.debug("LoginInterface")
    }
}



extension LoginInterface : HybridInterface {
    
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        let action  = command[1] as! String
        var args    = command[2] as! Array<Any>
        
        if  action == LoginInterface.COMMAND_CHECK_LOGIN {
            if ApplicationShare.shared.loginInfo.isLogin {
                resultCallback( HybridResult.success(message: "true" ))
            } else {
                resultCallback( HybridResult.success(message: "false" ))
            }
            
        } else if action == LoginInterface.COMMAND_GET_LOGIN_INFO  || action == LoginInterface.COMMAND_CALL_LOGIN {
            // 로그인 화면 이동
            if let tabVC = viewController.tabBarController as? TabBarViewController {
        
                tabVC.hybridShowLogin { (success, error) in
                    
                    if let error = error {
                        self.resultCallback( HybridResult.fail(error: error, errorMessage:error.localizedDescription))
                    } else {
                        if success {
                            self.resultCallback( HybridResult.success(message: "true" ))
                        } else {
                            self.resultCallback( HybridResult.success(message: "false" ))
                        }
                    }
                }
            }
        } else if  action == LoginInterface.COMMAND_AUTO_LOGIN_SETTING {
            //  자동 로그인 설정
            let autoSetting = args[0] as! String
            
            log?.debug("COMMAND_AUTO_LOGIN_SETTING called")
            
            if autoSetting == "Y" {
                // Y  이면 키체인안의 custItem의 객체 auto_login 를 true
                let keyChainWrapper = ApplicationShare.shared.keychainWrapper
                if let custItem = keyChainWrapper.object(forKey: Configuration.keyChainKey) as? KeyChainCustItem  {
                    log?.debug("custItem:\(custItem)")
                   
                    custItem.auto_login = true
                    
                    keyChainWrapper.set(custItem, forKey: Configuration.keyChainKey)
                    
                    self.resultCallback( HybridResult.success(message: "Y" ))
                } else {
                 self.resultCallback( HybridResult.success(message: "N" ))
                }
            } else {
                // N  이면 키체인안의 custItem의 객체 auto_login 를 false
                let keyChainWrapper = ApplicationShare.shared.keychainWrapper
                if let custItem = keyChainWrapper.object(forKey: Configuration.keyChainKey) as? KeyChainCustItem  {
                    log?.debug("custItem:\(custItem)")
                    
                    custItem.auto_login = false
                    keyChainWrapper.set(custItem, forKey: Configuration.keyChainKey)
                    self.resultCallback( HybridResult.success(message: "Y" ))
                } else {
                    // 실패시 N  콜백
                    self.resultCallback( HybridResult.success(message: "N" ))
                }
                
            }       
        } else if  action == LoginInterface.COMMAND_SET_NICK_NAME {
            // 닉네임 변경. 슬라이딩 메뉴에 있는 닉네임도 같이 변경 하기 위해서
            let nickname = args[0] as! String
            nicknameChange(nickname: nickname)
        } else if  action == LoginInterface.COMMAND_SET_PROFILE_DEFAULT_IMAGE {
            // 프로필 디폴트 이미지 설정
            defaultImageChange()
        } else if  action == LoginInterface.COMMAND_SET_ALARM_COUNT {
            // 알람 카운트
            let alarmCount = args[0] as! Int
            
            log?.debug("alarmCount:\(alarmCount)")
            
            // 알람카운트 변경한것을 Noti. 메뉴 화면에서 뱃지 카운트 변경
            Notification.Name.BadgeCount.post(object: nil, userInfo: ["badgeCount": alarmCount])
        } else if  action == LoginInterface.COMMAND_SET_LOGOUT {
            // 로그아웃 처리
            logout()
        } else if  action == LoginInterface.COMMAND_SET_INVESTMENT_TYPE {
            // 투자성향명 변경
            let investType = args[0] as! String
            investTypeChange(investType: investType)
        } else if  action == LoginInterface.COMMAND_SAVE_TOKEN {
            // 토큰 저장, 키체인의 custItem 객체의  token 속성에 저장한다. 로그인 할때, 키체인의 token 을 파라미터로 넘겨준다.
            // 토큰 저장 / 아이디찾기 본인 인증 완료 후에 호출됨.
            let token = args[0] as! String
            let keyChainWrapper = ApplicationShare.shared.keychainWrapper
            if let custItem = keyChainWrapper.object(forKey: Configuration.keyChainKey) as? KeyChainCustItem  {
                log?.debug("custItem:\(custItem)")
                custItem.token = token
                
                keyChainWrapper.set(custItem, forKey: Configuration.keyChainKey)
                
            }
            
        } else if action == LoginInterface.COMMAND_CALL_LOGIN_DIRECT  {
            // 로그인 화면 이동
            let successURL = args[0] as! String
            let failURL    = args[1] as! String
            
            let info = ["successURL" : successURL , "failURL" : failURL]
            
            if let tabVC = viewController.tabBarController as? TabBarViewController {
                tabVC.hybridShowLogin(info) {  (success, error) in
                    
                    if let error = error {
                        self.resultCallback( HybridResult.fail(error: error, errorMessage:error.localizedDescription))
                    } else {
                        if success {
                            self.resultCallback( HybridResult.success(message: "true" ))
                        } else {
                            self.resultCallback( HybridResult.success(message: "false" ))
                        }
                    }
                }
            }
        }
        
        
    }
    
    // 로그아웃 처리
    func logout() {
        NetworkInterface.transferServer(viewController: viewController, operation: .logout ) { [weak self]  (error, response) in
            
            guard let strongSelf = self else {
                return
            }
            
            if error == nil {
                
                /*
                 {
                 "msg" : "로그인 핀번호 복호화 오류",
                 "data" : {
                 "aResultCode" : "50006",
                 "aResultMessage" : "[DB fail]-[Does not exist, can not be select, deleted or updated to] "
                 },
                 "code" : "1001"
                 }
                 */
                
                // 로그인 응답존재 하고,  Succes (response["code"]  == "0000" ) 인 경우
                if let response =  response,  let code = response["code"] as? String , code == CerealConstrants.NetworkServerResponse.success {
                    if let data = response["data"] as? [String:Any]   {
                        //                                let last_login_time = data["Last_login_time"]
                        
                        ApplicationShare.shared.loginInfo.resetLogout()
                        Notification.Name.ActionLogout.post()
                        
                        let keyChainWrapper = ApplicationShare.shared.keychainWrapper
                        let custItem = keyChainWrapper.object(forKey: Configuration.keyChainKey) as! KeyChainCustItem
                        custItem.auto_login = false
                        keyChainWrapper.set(custItem, forKey: Configuration.keyChainKey)
                        
                    }
                } else if let response =  response,  let msg = response["msg"] as? String {
                    CMAlertView().setAlertView(detailObject: msg as AnyObject, cancelText: "확인") { event in }
                    
                } else {
                    // response 없는 경우
                }
            } else {
                //  AlamoFire 오류
            }
        }
    }//logout()
    
    // 닉네임 변경  Noti
    func nicknameChange(nickname : String) {
         // 닉네임 변경 설정 한것을 Noti 한다.  메뉴 화면에서 닉네임 변경
        Notification.Name.NickNameChange.post(object: nil, userInfo: ["NickName" : nickname])
    }
    
    // 투자성향이름  변경  Noti
    func investTypeChange(investType : String) {
        // 투자성향이름 변경 설정 한것을 Noti 한다.  메뉴 화면에서 투자성향명  변경
        Notification.Name.InvestTypeChange.post(object: nil, userInfo: ["InvestType" : investType])
    }
    
    

    // 프로필 디폴트 이미지 설정
    func defaultImageChange() {
        // 프로필 디폴트 이미지 설정 한것을 Noti 한다.  메뉴 화면에서 디폴트 이미지로 변경
        Notification.Name.DefaultImageChange.post()
    }
            
}

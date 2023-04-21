//
//  UtilityInterface.swift
//  cereal
//
//  Created by srkang on 2018. 7. 20..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class UtilityInterface: NSObject {
    
    static let COMMAND_SET_PREFERENCE           = "setPreference" // 네이트브 저장소에 저장
    static let COMMAND_GET_PREFERENCE           = "getPreference" // 네이트브 저장소 부터 값 조회
    static let COMMAND_OPEN_MENU                = "openMenu" // 슬라이딩 메인 메뉴 오픈
    
    static let COMMAND_GET_PICKER_INFO          = "getPickerInfo" // 테스트 용도
    static let COMMAND_GET_DATE_PICKER          = "getDatePicker" // 날짜 Picker 띄우기
    static let COMMAND_UTIL_TEST                = "utilTest" // 테스트 용도
    static let COMMAND_SEND_GA_EVENT            = "sendGAEvent" //  GA 이벤트 보내기
    static let COMMAND_GET_STATUSBAR_HEIGHT     = "getStatusBarHeight" // 네이티브 상태바 높이 구하기
    static let COMMAND_COPY_PASTEBOARD          = "copyPasteboard" //  Pasteboard 에 복사 - 추천인코드 복사에 사용함
    
    static let COMMAND_GET_OS_TYPE              = "getOSType" //  iOS , Android 구분
    static let COMMAND_GET_DEVICE_NAME          = "getDeviceName" //  디바이스명 가져오기
    static let COMMAND_GET_APP_VERSION          = "getAppVersion" //   앱 버전 정보 조회
    static let COMMAND_GET_PUSH_TOKEN           = "getPushToken" // FCM 푸시 토큰
    static let COMMAND_GET_PUSH_SETTING         = "getPushSetting" // 앱 푸시 설정 여부.  iOS 만 사용함.
    
    static let COMMAND_MOVE_PUSH_SETTING         = "movePushSetting" // 푸시 설정 할 수 있도록 , 앱 설정으로 이동. iOS 만 사용함.
    static let COMMAND_INSTALLED_KAKAOTALK       = "installedKakaoTalk" // 카카오톡 설치 여부
    
    static let COMMAND_APP_UPDATE                = "appUpdate" // 앱 업데이트
    static let COMMAND_GOTO_MANBOGO                = "moveToManboGo" // 만보고 이동
    
    
    var selectedDate : Date?
    
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        super.init()
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        log?.debug("UtilityInterface")
    }
}

extension UtilityInterface : HybridInterface {
    
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        let action = command[1] as! String
        let args = command[2] as! Array<Any>
        
        let keyChainWrapper = ApplicationShare.shared.keychainWrapper
      
        if action == UtilityInterface.COMMAND_SET_PREFERENCE {
            // 네이트브 저장소에 저장
            /*
             key :  저장소에 저장하려는 키
             value :저장소에 저장하려는 값(키에 대응)
             올리고에서는 사용하지 않음
            */
            keyChainWrapper.set(args[1] as! String, forKey: args[0] as! String)
        } else if action == UtilityInterface.COMMAND_GET_PREFERENCE {
            // 네이트브 저장소 부터 값 조회
            /*
                 key :  조회 하려는 키
             
                 올리고에서는 사용하지 않음
            */
            let val = keyChainWrapper.string(forKey: args[0] as! String)
            // 조회하려는 키에 대응하는 값을  콜백
            resultCallback( HybridResult.success(message: val! ))
        } else if action == UtilityInterface.COMMAND_OPEN_MENU {
//            Notification.Name.OpenMenu.post()
        } else if action == UtilityInterface.COMMAND_GET_PICKER_INFO {
            Notification.Name.GetPicker.post()
        } else if action == UtilityInterface.COMMAND_GET_DATE_PICKER {
            // 날짜 선택할 수 있으로 Picker 뷰로 띄운다.
            self.selectedDate = nil
            let alert = UIAlertController(style: .actionSheet , title: "", message: "날짜 선택하세요")
            
            let minDtString = args[0] as! String
            let maxDtString = args[1] as! String
            let settingDtString = args[2] as! String
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "yyyyMMdd"
            
            var  minimumDate : Date? = nil // 선택 가능한 최소일자
            var  maximumDate : Date? = nil // 선택 가능한 최대일자
            var  settingDate : Date? = nil // 선택 가능한 최대일자
            
            if minDtString != "" && minDtString.count == 8 {
                if let minDt = dateFormatter.date(from: minDtString) {
                    minimumDate = minDt
                }
            }
            
            if maxDtString != "" && maxDtString.count == 8 {
                if let maxDt = dateFormatter.date(from: maxDtString) {
                    maximumDate = maxDt
                }
            }
            
            if settingDtString != "" && settingDtString.count == 8 {
                if let settingDt = dateFormatter.date(from: settingDtString) {
                    settingDate = settingDt
                }
            } else {
                settingDate = Date()
            }
            
            alert.addDatePicker(mode: .date, date: settingDate , minimumDate: minimumDate, maximumDate: maximumDate) { date in
                Log(date)
                self.selectedDate = date
            }
            alert.addAction(title: "완료", style: .cancel) { _ in
               
                if let selectedDate = self.selectedDate {
          
                    let retStringDate = dateFormatter.string(from: selectedDate)
                    // 선택한 일자리 callback
                    self.resultCallback( HybridResult.success(message: retStringDate ))
                } else {
                    self.resultCallback( HybridResult.success(message: settingDtString ))
                   
                    
                }
            }
            alert.show()
        }  else if action == UtilityInterface.COMMAND_SEND_GA_EVENT {
            
            // GA 이벤트 보내기
            let event = args[0] as! String //  이벤트명
            let parameters = args[1] as! String // 파라미터 JSON String

            log?.debug("event: \(event)")
            log?.debug("parameters: \(parameters)")
            
            let data: Data = parameters.data(using: .utf8)!
            do {
                // JSON 스트링을  Object 로 변환
                let jsObj = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
                //["sign_up_method" : "A"]
                Analytics.logEvent(event,parameters:(jsObj as! [String : Any]))
                resultCallback( HybridResult.success(message: "success" ))
            }catch  {
                
            }
        } else if action == UtilityInterface.COMMAND_GET_STATUSBAR_HEIGHT {
            // 네이티브 상태바 높이 구하기
            resultCallback( HybridResult.success(message: ApplicationShare.shared.deviceInfo.topLength ))
        } else if action == UtilityInterface.COMMAND_COPY_PASTEBOARD {
            // Pasteboard 에 복사 - 추천인코드 복사에 사용함
            let message = args[0] as! String
            UIPasteboard.general.string = message
        } else if action == UtilityInterface.COMMAND_GET_OS_TYPE {
            // iOS
            resultCallback( HybridResult.success(message: "iOS" ))
        } else if action == UtilityInterface.COMMAND_GET_DEVICE_NAME {
            resultCallback( HybridResult.success(message: UIDevice.modelName ))
        } else if action == UtilityInterface.COMMAND_GET_APP_VERSION {
            
            // 앱버전 조회
            let message : [String:Any] = [
                "app_version" : Configuration.appVersion, // App 버전
                "server_version" : Configuration.serverVersion, // 서버 관리하는 App 최신버전
                "os" : UIDevice.current.systemVersion, //  iOS, Android 버전
                "devname" : UIDevice.modelName, // 디바이스명
            ]
            
            do {
                let data =  try JSONSerialization.data(withJSONObject: message, options:.prettyPrinted)
                if let dataString = String.init(data: data, encoding: .utf8) {
                    resultCallback( HybridResult.success(message: dataString ))
                }
            } catch {
               // resultCallback( HybridResult.success(message: dataString ))
            }
            
        } else if action == UtilityInterface.COMMAND_GET_PUSH_TOKEN {
            // FCM 푸시토큰 리턴
            
            //ADDED YUN
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                    self.resultCallback( HybridResult.success(message: "false"))
                } else if let token = token {
                    print("FCM registration token: \(token)")
                    self.resultCallback( HybridResult.success(message: token ))
                }
            }
            //FINISHED YUN
            
//            if let fcmToken = Messaging.messaging().fcmToken {
//                resultCallback( HybridResult.success(message: fcmToken ))
//            } else {
//                resultCallback( HybridResult.success(message: "false"))
//            }
            
        } else if action == UtilityInterface.COMMAND_GET_PUSH_SETTING {
            // 앱 푸시 설정 여부 iOS 만 사용함.
            
            if let permissionScope = ApplicationShare.shared.permissionInfo.permissionScope {
                
                permissionScope.statusNotifications(completion: { (status) in
                    
                    delay(0.0) {
                        if status ==  .authorized {
                            // 푸시가 설정 되어 있으면  Y 로 리턴
                            self.resultCallback( HybridResult.success(message: "Y"))
                        } else {
                            self.resultCallback( HybridResult.success(message: "N"))
                        }
                    }
                })
            }
            
            
        } else if action == UtilityInterface.COMMAND_MOVE_PUSH_SETTING {
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            UIApplication.shared.openURL(settingsUrl!)
        } else if action == UtilityInterface.COMMAND_INSTALLED_KAKAOTALK {
            // 카카오톡 설치 여부
            let kakaotalk = "kakaolink://"
            
            let isInstalledKakaoTalk = UIApplication.shared.canOpenURL(URL(string: kakaotalk)!)
            
            if isInstalledKakaoTalk {
                self.resultCallback( HybridResult.success(message: "Y"))
            } else {
                self.resultCallback( HybridResult.success(message: "N"))
            }
        } else if action == UtilityInterface.COMMAND_APP_UPDATE {
            
            // 앱 업데이트 하기 위해 앱스토어 이동
            let versionInfo = MenuInfo.versionJSON
            
            let market_url = versionInfo!["market_url"].stringValue
            
            
//            let appId = "838696918"
//            let url = "itms-apps://itunes.apple.com/app/id\(appId)"
            
            
            UIApplication.shared.openURL(URL(string: market_url)!)
        }
     
        
        
        
        
        
    }
}

//
//  Utils.swift
//  MyData
//
//  Created by UMCios on 2022/01/05.
//

import Foundation
import UIKit
import CryptoKit
import os


/**
 Console App Log 확인을 위해 사용 합니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.05.03
 */
extension OSLog
{
    private static var log_subtype = Bundle.main.bundleIdentifier
    /// Console Log 확인시 "Network" 카테고리 구분 입니다.
    static let network  = OSLog(subsystem: log_subtype!, category: "Network")
    /// Console Log 확인시 "Apns" 카테고리 구분 입니다.
    static let apns     = OSLog(subsystem: log_subtype!, category: "Push")
    /// Console Log 확인시 "DeepLink" 카테고리 구분 입니다.
    static let deeplink = OSLog(subsystem: log_subtype!, category: "DeepLink")
    /// Console Log 확인시 "OKPay" 카테고리 구분 입니다.
    static let okpay    = OSLog(subsystem: log_subtype!, category: "OKPay")
    /// Console App Log 활성화 여부 입니다.
    static let OS_LOG   = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)?.value(forKey: "CONSOLE_OS_LOG") as? String ?? "" == "YES" ? true : false
}


/**
 Log 확인을 위해 사용 합니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.05.03
 - Parameters:
    - object : 로그 정보 입니다.
    - category : 카테고리 타입 입니다. ( default : .okpay )
    - logType : 콘솔 로그 타입 입니다. ( default : .default )
 - returns :False
 */
func Slog(_ object: Any, category : OSLog = .okpay, logType : OSLogType = .default ) {
     
    if OSLog.OS_LOG == true
    {
        os_log("%{public}@", log:  category, type: logType, "\(object)")
        return
    }
    #if DEBUG
    print(object)
    #endif
}


/// 앱 버튼 ID 정보 입니다.
let APP_BUNDLE_ID       = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
/// 앱 버전 정보 입니다.
let APP_VERSION         = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"


class Utils {
    static let bundleIdentifier = {
        return Bundle.main.bundleIdentifier
    }()
    
    static let appVersion : String = {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }()
    
    static let gaiTrackingKey : String = {
        return Bundle.main.object(forInfoDictionaryKey: "GAI_TRACKING_KEY") as! String
    }()
        
    
    static var serverVersion : String?
        
    
    static func getInfoDictionary(key: String) -> String? {
        guard let data = Bundle.main.infoDictionary?[key] as? String, !data.isEmpty else {
            return nil
        }
        return data
    }
    
    // MARK: 기타
    static func toJSON(_ jsonStr: String) -> [String : Any]? {
        if jsonStr.isEmpty {
            return nil
        }
        if let data = jsonStr.data(using: .utf8) {
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                return jsonData
            }
        }
        return nil
    }
    
    
    static func toJSONAnyArray(_ jsonStr: String) -> [Any]? {
        if jsonStr.isEmpty {
            return nil
        }
        if let data = jsonStr.data(using: .utf8) {
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                return jsonData
            }
        }
        return nil
    }
    
    
    static func toJSONSArray(_ jsonStr: String) -> [String]? {
        if jsonStr.isEmpty {
            return nil
        }
        if let data = jsonStr.data(using: .utf8) {
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                return jsonData
            }
        }
        return nil
    }
    

    static func toJSONArray(_ jsonStr: String) -> [[String : Any]]? {
        if jsonStr.isEmpty {
            return nil
        }
        if let data = jsonStr.data(using: .utf8) {
            if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                return jsonData
            }
        }
        return nil
    }
    
    static func toJSONString(_ dic: Dictionary<String, Any>) throws -> String? {
        let data = try JSONSerialization.data(withJSONObject: dic)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }
    
    
    static func openSettings() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url)
    }
    
    static func openURL(url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any] = [:]) {
        UIApplication.shared.open(url, options: options, completionHandler: nil)
    }
    
    static func randomIdString() -> String {
        let rendomStringLength = 14
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSS"
        let currentDateString = formatter.string(from: Date())
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""

        for _ in 0..<rendomStringLength {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        let randomId = String(format: "%@%@", currentDateString, randomString)
        
        return randomId
    }
    
    static func hasJailbreak() -> Bool {
        guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return false }
        if UIApplication.shared.canOpenURL(cydiaUrlScheme as URL) {
            return true
        }
        #if arch(i386) || arch(x86_64)
        return false
        #endif
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            fileManager.fileExists(atPath: "/bin/bash") ||
            fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
            fileManager.fileExists(atPath: "/etc/apt") ||
            fileManager.fileExists(atPath: "/usr/bin/ssh") ||
            fileManager.fileExists(atPath: "/private/var/lib/apt") {
            return true
        }
        if canOpen(path: "/Applications/Cydia.app") ||
            canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
            canOpen(path: "/bin/bash") ||
            canOpen(path: "/usr/sbin/sshd") ||
            canOpen(path: "/etc/apt") ||
            canOpen(path: "/usr/bin/ssh") {
            return true
        }
        let path = "/private/" + NSUUID().uuidString
        do {
            try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    static func canOpen(path: String) -> Bool {
        let file = fopen(path, "r")
        guard file != nil else { return false }
        fclose(file)
        return true
    }
    
    // 디바이스 모델 조회
    func getModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return model
    }
    
    
    func deviceModelName() -> String? {
            Slog("")
            Slog("===============================")
            Slog("[ViewController >> deviceModelName() :: 디바이스 모델 명칭 확인 실시]")
            Slog("===============================")
            Slog("")
            
            // [1]. 시뮬레이터 체크 수행 실시
            var modelName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? ""
            if modelName != "" && modelName.isEmpty == false && modelName.count>0 {
                Slog("")
                Slog("===============================")
                Slog("[ViewController >> deviceModelName() :: 디바이스 시뮬레이터]")
                Slog("[deviceModelName :: \(modelName)]")
                Slog("===============================")
                Slog("")
                
                // [리턴 반환 실시]
                return modelName
            }
            
            // [2]. 실제 디바이스 체크 수행 실시
            let device = UIDevice.current
            let selName = "_\("deviceInfo")ForKey:"
            let selector = NSSelectorFromString(selName)
            
            if device.responds(to: selector) { // [옵셔널 체크 실시]
                modelName = String(describing: device.perform(selector, with: "marketing-name").takeRetainedValue())
            }
            
            Slog("")
            Slog("===============================")
            Slog("[ViewController >> deviceModelName() :: 실제 디바이스 기기]")
            Slog("[deviceModelName :: \(modelName)]")
            Slog("===============================")
            Slog("")
            
            // [리턴 반환 실시]
            return modelName
        }
    
}



/**
 Nil 체크 하는 클래스 입니다.  ( J.D.H  VER : 1.0.0 )
- Date : 2022.03.16
*/
class NC {

    /**
     NIL 체크 후 안내 팝업을 오픈 하며 앱을 강제 종료 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.01
     - Parameters:
        - object : 체크할 데이터를 받습니다.
     - returns :False
     */
    static func PE( _ object : Any?)
    {
        /*
        if object == nil
        {
            /// 네트워크 사용 불가능으로 안내 팝업을 오픈 합니다.
            CMAlertView().setAlertView(titleText: TIMEOUT_ERR_MSG, detailObject: TIMEOUT_ERR_MSG_DETAIL as AnyObject, cancelText: "확인") { event in
                /// 앱 버전 체크 다시 요청 합니다.
                exit(0)
            }
        }
         */
         
    }
    
    
    /**
     NIL 체크 후 안내 팝업을 오픈 하며 현 페이지를  종료 하며 이전 페이지로 돌아 갑니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.01
     - Parameters:
        - object : 체크할 데이터를 받습니다.
     - returns :False
     */
    static func PB( _ object : Any?)
    {
        if object == nil
        {
            /// 네트워크 사용 불가능으로 안내 팝업을 오픈 합니다.
            CMAlertView().setAlertView(titleText: TEMP_NETWORK_ERR_MSG, detailObject: TEMP_NETWORK_ERR_MSG_DETAIL as AnyObject, cancelText: "확인") { event in
                /// 앱 버전 체크 다시 요청 합니다.
                let rootController          = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
                let childs                  = rootController!.children
                
                /// 탭 정보가 1 이상인경우 네비게이션 컨트롤 타입을 적용 합니다.
                if childs.count > 1
                {
                    childs.last?.navigationController?.popViewController(animated: true)
                }
                else
                {
                    /// 연결된 루트 뷰어 모달 타입을 체크 합니다.
                    if let presented = rootController!.presentedViewController {
                        /// 모달 타입 뷰어의 0 번째 컨트롤러의 네비 위치를 0번째로 이동하며 해당 모달 타입을 내립니다.
                        let presentedChilds = presented.children
                        /// 모달 타입 뷰어에 추가 네비 페이지가 있을 경우 네비 이전 페이지로만 이동 합니다.
                        if presentedChilds.count > 1
                        {
                            presentedChilds.last?.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            /// 모달 페이지만 있는 경우 입니다.
                            if presentedChilds.count == 1
                            {
                                let root = presentedChilds[0] as UIViewController
                                root.navigationController?.popViewController(animated: false)
                                root.dismiss(animated: true)
                                return
                            }
                        }
                    }
                    else
                    {
                        rootController!.navigationController?.popViewController(animated: false)
                    }
                }
            }
        }
    }
    
    
    /**
     Int 형 데이터를 체크  합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - object : 체크할 Int 형 데이터 입니다.
     - returns :
        - Int Typre
            > 체크된 데이터를 리턴 합니다. 비정상 데이터면 0 정보를 리턴 합니다.
     */
    static func I( _ object : Int? ) -> Int {
        if object == nil
        {
            return 0
        }
        return object!
    }
    
    
    /**
     Double 형 데이터를 체크  합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - object : 체크할 Double 형 데이터 입니다.
     - returns :
        - Double Typre
            > 체크된 데이터를 리턴 합니다. 비정상 데이터면 0.0 정보를 리턴 합니다.
     */
    static func D( _ object : Double? ) -> Double {
        if object == nil
        {
            return 0.0
        }
        return object!
    }
    
    
    /**
     String 형 데이터를 체크  합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - object : 체크할 String 형 데이터 입니다.
     - returns :
        - String Typre
            > 체크된 데이터를 리턴 합니다. 비정상 데이터면 "" 정보를 리턴 합니다.
     */
    static func S( _ object : String? ) -> String
    {
        if object == nil
        {
            return ""
        }
        //return object!
        return String.init(htmlEncodedString: object!)!
    }
    
    
    /**
     Bool 형 데이터를 체크  합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.03
     - Parameters:
        - object : 체크할 Bool 형 데이터 입니다.
     - returns :
        - Bool Type
            > 체크된 데이터를 리턴 합니다. 비정상 데이터면 false 정보를 리턴 합니다.
     */
    static func B( _ object : Bool? ) -> Bool
    {
        if object == nil
        {
            return false
        }
        //return object!
        return object!
    }
    
}


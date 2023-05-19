//
//  SharedDefaults.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/20.
//

import Foundation
import SwiftKeychainWrapper
import UIKit

/**
 앱내 저장하는 UserDefaults  입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.27
 */
class SharedDefaults {
    /// 앱 최초 권한 선택 여부 값을 체크 합니다.
    static let PERMISSION_INITIALCHECK          = "PERMISSION_INITIALCHECK"
    /// 앱 가이드 유저 확인 여부 체크 입니다.
    static let GUIDE_SHOW_FINISHED              = "GUIDE_SHOW_FINISHED"
    /// 만보고 약관 동의 여부 입니다.
    static let PEDOMETER_TERAMS_AGREE           = "PEDOMETER_TERAMS_AGREE"
    /// 만보고 최초 진입시 날짜 정보 입니다.
    static let PEDOMETER_FIRST_AGREE            = "PEDOMETER_FIRST_DATE"
    /// 연결 계좌 여부 체크 입니다.
    static let SET_ACCOUNT_ENABLED              = "SET_ACCOUNT_ENABLED"
    /// 월렛 복구문 정보 입니다.
    static let WALLET_MNEMONIC                  = "WALLET_MNEMONIC"
    /// 키체인 정보를 읽었는지를 체크 합니다.
    static let IS_KEYCHAIN_READ                 = "IS_KEYCHAIN_READ"
    
    
    /// 키체인을 연결 합니다.
    var keychainWrapper                         =  KeychainWrapper(serviceName: APP_BUNDLE_ID, accessGroup: nil)
    /// SharedDefaults 에 UserDefaults.standard 연결 정보 입니다.
    let defaults: UserDefaults
    static var `default`: SharedDefaults = {
        let defaults = SharedDefaults()
        return defaults
    }()
    init() {  defaults = UserDefaults.standard }
    
    
    private var _isKeychainRead : Bool = false
    /// 키체인 정보를 사용한 이력이 있는지를 체크 합니다.
    var isKeychainRead : Bool {
        get {
            _isKeychainRead = defaults.bool(forKey: SharedDefaults.IS_KEYCHAIN_READ)
            return _isKeychainRead
        }
        set {
            _isKeychainRead = newValue
            defaults.set(_isKeychainRead, forKey: SharedDefaults.IS_KEYCHAIN_READ)
        }
    }
    
    
    private var _walletMnemonic : String = ""
    /// 월렛 복구문 입니다.
    var walletMnemonic : String {
        get {
            _walletMnemonic = defaults.string(forKey: SharedDefaults.WALLET_MNEMONIC) ?? ""
            return _walletMnemonic
        }
        set {
            _walletMnemonic = newValue
            defaults.set(_walletMnemonic, forKey: SharedDefaults.WALLET_MNEMONIC)
        }
    }
    
    
    private var _pedometerFirstDate : String = ""
    /// 만보고 최초 진입시 날짜 정보 입니다.
    var pedometerFirstDate : String {
        get {
            _pedometerFirstDate = defaults.string(forKey: SharedDefaults.PEDOMETER_FIRST_AGREE) ?? ""
            return _pedometerFirstDate
        }
        set {
            _pedometerFirstDate = newValue
            defaults.set(_pedometerFirstDate, forKey: SharedDefaults.PEDOMETER_FIRST_AGREE)
        }
    }
    
    
    private var _pedometerTermsAgree : String = "N"
    /// 만보기 약관 동의 여부 갑니다.
    var pedometerTermsAgree : String {
        get {
            _pedometerTermsAgree = defaults.string(forKey: SharedDefaults.PEDOMETER_TERAMS_AGREE) ?? ""
            return _pedometerTermsAgree
        }
        set {
            _pedometerTermsAgree = newValue
            defaults.set(_pedometerTermsAgree, forKey: SharedDefaults.PEDOMETER_TERAMS_AGREE)
        }
    }
    
    
    private var _permissionInitialCheck : Bool = false
    /// 앱 최초 접근 앱 사용 안내 여부를 체크 키 값입니다.
    var permissionInitialCheck : Bool {
        get {
            _permissionInitialCheck = defaults.bool(forKey: SharedDefaults.PERMISSION_INITIALCHECK)
            return _permissionInitialCheck
        }
        set {
            _permissionInitialCheck = newValue
            defaults.set(_permissionInitialCheck, forKey: SharedDefaults.PERMISSION_INITIALCHECK)
        }
    }
    
    
    private var _guideShowFinished : Bool = false
    /// 앱 가이드 유저 확인 여부 체크 입니다.
    var guideShowFinished : Bool {
        get {
            _guideShowFinished = defaults.bool(forKey: SharedDefaults.PERMISSION_INITIALCHECK)
            return _guideShowFinished
        }
        set {
            _guideShowFinished = newValue
            defaults.set(_guideShowFinished, forKey: SharedDefaults.PERMISSION_INITIALCHECK)
        }
    }
    
    
    
    private var _accountEnabled : Bool = false
    /// 연결 계좌 여부 체크 입니다.
    var accountEnabled : Bool {
        get {
            _accountEnabled = defaults.bool(forKey: SharedDefaults.SET_ACCOUNT_ENABLED)
            return _accountEnabled
        }
        set {
            _accountEnabled = newValue
            defaults.set(_accountEnabled, forKey: SharedDefaults.SET_ACCOUNT_ENABLED)
        }
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     키체인 연결 custItem 타입의 데이터를 가져 옵니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.31
     - Parameters:False
     - Throws : False
     - returns :
        - KeyChainCustItem
            + 유저 데이터를 가져 옵니다.
     */
    static func getKeyChainCustItem() -> KeyChainCustItem?
    {
        let keyChainWrapper = SharedDefaults.default.keychainWrapper
        return keyChainWrapper.object(forKey: "keyChainKey") as? KeyChainCustItem
    }
    
    
    /**
     키체인에 custItem 타입의 데이터를 추가 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.31
     - Parameters:
        - custItem : 유저 데이터를 추가 합니다.
     - Throws : False
     - returns :False
     */
    static func setKeyChainCustItem( _ custItem : KeyChainCustItem )
    {
        let keyChainWrapper = SharedDefaults.default.keychainWrapper
        keyChainWrapper.set(custItem, forKey: "keyChainKey")
    }
    
    
    /**
     키체인에 데이터를 추가 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.31
     - Parameters:
        - value : 추가할 데이터 입니다.
        - key : 데이터 키 정보 입니다.
     - Throws : False
     - returns :False
     */
    static func setKeyChain( _ value: String, forKey key: String )
    {
        let keyChainWrapper = SharedDefaults.default.keychainWrapper
        keyChainWrapper.set(value, forKey: key)
    }
    
    
    /**
     키체인에 문자형 데이터를 리턴 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.31
     - Parameters:
        - key : 리턴할 데이터의 키값을 받습니다.
     - Throws : False
     - returns :
        - String
            + 리턴할 문자형 데이터 입니다.
     */
    static func getStringKeyChain( forKey key: String ) -> String?
    {
        let keyChainWrapper = SharedDefaults.default.keychainWrapper
        return keyChainWrapper.string(forKey: key) ?? ""
    }
}

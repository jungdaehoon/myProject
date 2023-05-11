//
//  NetworkManager.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation
import Alamofire
import Combine
import CoreMedia


/**
 Request 관련 API 메서드를 관리 합니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.09
 */
class NetworkManager {
    
    /**
     토큰 정보를 가져 옵니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.09
     - Parameters:False
     - Throws : False
     - returns :
        - String
            + 토큰 정보를 리턴 합니다.
     */
    static func getToken() -> String
    {
        if let item = SharedDefaults.getKeyChainCustItem()
        {
            return NC.S(item.token)
        }
        return ""
    }
    
    
    /**
     전체 탭 요청 합니다.( J.D.H  VER : 1.0.0 )
     - API ID:
     - API 명: 하단 전체 탭에 데이터 정보를 요청 합니다.
     - Date : 2023.03.09
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<AllMoreResponse, ResponseError>
            + AllMoreResponse : 전체 탭 상세 정보 데에터 입니다.
     */
    static func requestAllMore( token : String = NetworkManager.getToken() ) -> AnyPublisher<AllMoreResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_MYALL_MENU, parameters: parameters)
    }
    
    
    /**
     만보게 약관 동의 여부 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID:
     - API 명: 만보게 페이지 진입전 약관 동의 여부를 확인 합니다.
     - Date : 2023.03.09
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<PedometerTermsAgreeResponse, ResponseError>
            +  PedometerTermsAgreeResponse : 만보게 약관 동의 여부를 받습니다.
     */
    static func requestPedometerTermsAgree( token : String = NetworkManager.getToken() ) -> AnyPublisher<PedometerTermsAgreeResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        
        return AlamofireAgent.request(APIConstant.API_PEDO_TERMS_CHECK, parameters: parameters)
    }
    
    
    /**
     만보게 약관 동의 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID:
     - API 명: 만보기 약관동의 팝업에서 "동의" 선택으로 약관동의를 요청 합니다.
     - Date : 2023.03.15
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<InsertPedometerTermsResponse, ResponseError>
            +  InsertPedometerTermsResponse : 만보게 약관동의 요청 후 확인 정보를 받습니다.
     */
    static func requestInsertPedometerTerms( token : String = NetworkManager.getToken() ) -> AnyPublisher<InsertPedometerTermsResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_PEDO_TERMS_AGREE, parameters: parameters)
    }
    
    
    /**
     앱 시작 기본 정보 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: /api/start.do
     - API 명: 앱 시작 기본 정보 요청 합니다.
     - Date : 2023.03.27
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws : False
     - returns :
        - AnyPublisher<AppStartResponse, ResponseError>
            +  AppStartResponse : 앱 전체적으로 기본 정보를 가집니다. ( 각 메뉴 선택시 URL 정보 )
     */
    static func requestAppStart( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<AppStartResponse, ResponseError> {
        var parameters: Parameters = [:]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_START_APP, parameters: parameters)
    }
    
    
    /**
      Fcm PUSH 토큰 정보를 업로드 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: /api/pushToken.do
     - API 명: FCM Token 업데이트 합니다.
     - Date : 2023.04.12
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws : False
     - returns :
        - AnyPublisher<FcmPushUpdateResponse, ResponseError>
            +  FcmPushUpdateResponse : FCM 업로드 요청 입니다.
     */
    static func requestFcmUpdate( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<FcmPushUpdateResponse, ResponseError> {
        var parameters: Parameters = [:]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_PUSH_TOKEN, parameters: parameters)
    }
    
    
    /**
     로그인을 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: /api/login.do
     - API 명: 로그아웃을 요청 합니다.
     - Date : 2023.03.27
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws : False
     - returns :
        - AnyPublisher<LoginResponse, ResponseError>
            +  LoginResponse : 로그인 데이터 정보 입니다.
     */
    static func requestLogin( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<LoginResponse, ResponseError> {
        var parameters: Parameters = ["token": token]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_LOGIN, parameters: parameters)
    }
    
    
    /**
     로그아웃을 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: /api/logout.do
     - API 명: 로그아웃을 요청 합니다.
     - Date : 2023.03.20
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<LogOutResponse, ResponseError>
            +  LogOutResponse : 로그아웃 여부 정보를 받습니다.
     */
    static func requestLogOut( token : String = NetworkManager.getToken() ) -> AnyPublisher<LogOutResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_LOGOUT, parameters: parameters)
    }
    
    
    /**
     만료된 은행 계좌 재인증 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: openbank/authorizeAccount
     - API 명: 계좌 재인증 요청 입니다.
     - Date : 2023.03.21
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<ReBankAuthResponse, ResponseError>
            +  ReBankAuthResponse : 인증 여부를 받습니다.
     */
    static func requestReBankAuth( token : String = NetworkManager.getToken() ) -> AnyPublisher<ReBankAuthResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_AUTH_ACCOUNT, parameters: parameters)
    }
    
    
    /**
     연결된 은행 계좌 리스트 정보를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: myp/selectAccountList.do
     - API 명: 은행 계좌 요청 입니다.
     - Date : 2023.03.22
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<SelectAccountListResponse, ResponseError>
            +  SelectAccountListResponse : 계좌 리스트 정보를 받습니다.
     */
    static func requestSelectAccountList( token : String = NetworkManager.getToken() ) -> AnyPublisher<SelectAccountListResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_ACCOUNT_LIST, parameters: parameters)
    }

    
    /**
     만보기 수령 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: myp/selectMyPedometer.do
     - API 명: 만보기 수령 요청 입니다.
     - Date : 2023.03.22
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<PedometerResponse, ResponseError>
            +  PedometerResponse : 만보기 데이터를 받습니다.
     */
    static func requestPedometer( token : String = NetworkManager.getToken() ) -> AnyPublisher<PedometerResponse, ResponseError> {
        let parameters: Parameters = [ "token": token ]
        return AlamofireAgent.request(APIConstant.API_GET_PEDOMETER, parameters: parameters)
    }
    
    
    /**
     만보기 리워드 수령 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: myp/insertPedometer.do
     - API 명: 만보기 리워드 수령 요청 입니다.
     - Date : 2023.03.22
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws : False
     - returns :
        - AnyPublisher<PedometerRewardResponse, ResponseError>
            +  PedometerRewardResponse : 만보기 리워드 데이터를 받습니다.
     */
    static func requestPedometerReward( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<PedometerRewardResponse, ResponseError> {
        var parameters: Parameters = [ "token": token ]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_GET_PEDOMETER_REWARD, parameters: parameters)
    }
    
    
    /**
     만보기 데이터를 업데이트 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: myp/updateDailyPedometer.do
     - API 명: 만보기 데이터를 업데이트 합니다.
     - Date : 2023.03.22
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws : False
     - returns :
        - AnyPublisher<PedometerUpdateResponse, ResponseError>
            +  PedometerUpdateResponse : 만보기 업데이트 완료 여부를 받습니다.
     */
    static func requestPedometerUpdate( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<PedometerUpdateResponse, ResponseError> {
        var parameters: Parameters = [ "token": token ]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_UPDATE_PEDOMETER, parameters: parameters, encoding: JSONEncoding.default)
    }
    
    
    
    /**
     제로페이 인증 정보와 QRCode 정보로 제로페이에 리턴할 스크립트를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - API ID: /api/v1/zeropay/qrcode.do
     - API 명: QRCode 인증 할 제로페이 스크립트를 요청 합니다.
     - Date : 2023.04.19
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws : False
     - returns :
        - AnyPublisher<ZeroPayQRCodeResponse, ResponseError>
            +  ZeroPayQRCodeResponse : QRCode 인증 할 제로페이 스크립트를 받습니다.
     */
    static func requestZeroPayQRcode( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<ZeroPayQRCodeResponse, ResponseError> {
        var getParams = "?"
        for (key,value) in params
        {
            getParams += "\(key)=\(value)&"
        }
        getParams.remove(at: getParams.index(before: getParams.endIndex))
        return AlamofireAgent.request(APIConstant.API_ZEROPAY_QRCODE + getParams, method : .get, parameters: nil)
    }
    
}

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
 Request 관련 API 메서드를 관리 합니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.09
 */
class NetworkManager {
    
    /**
     토큰 정보를 가져 옵니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.09
     - Parameters:False
     - Throws: False
     - Returns:
        토큰 정보를 리턴 합니다. ( String )
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
     기본 파라미터 정보를 설정합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.05
     - Parameters:False
     - Throws: False
     - Returns:
        토큰 정보 , 유저 넘버를 리턴 합니다.  [String:Any]
     */
    static func getDefaultParams( method : HTTPMethod = .post ) -> Any?
    {
        if let item = SharedDefaults.getKeyChainCustItem()
        {
            if method == .get
            {
                return "?token=\(NC.S(item.token))&user_no=\(NC.S(item.user_no))"
            }
            return ["token":NC.S(item.token),"user_no":NC.S(item.user_no)]
        }
        return ["":""]
    }
    
    
    /**
     전체 탭 요청 합니다.( J.D.H VER : 2.0.0 )
     - API ID: /all/selectMyInfo.do
     - API 명: 하단 전체 탭에 데이터 정보를 요청 합니다.
     - Date: 2023.03.09
     - Parameters:
        - token : 기본 토큰 정보 입니다.
     - Throws: False
     - Returns:
        전체 탭 상세 정보 데에터 입니다. ( AnyPublisher<AllMoreResponse, ResponseError> )
     */
    static func requestAllMore( token : String = NetworkManager.getToken() ) -> AnyPublisher<AllMoreResponse, ResponseError> {
        let parameters: Parameters = ["token": token, "type":"N"]
        return AlamofireAgent.request(APIConstant.API_MYALL_MENU, parameters: parameters)
    }
    
    
    /**
     만보게 약관 동의 여부 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /popup/selectPedometerTerms.do
     - API 명: 만보게 페이지 진입전 약관 동의 여부를 확인 합니다.
     - Date: 2023.03.09
     - Parameters:
        - token : 기본 토큰 정보 입니다.
     - Throws: False
     - Returns:
        만보게 약관 동의 여부를 받습니다. (AnyPublisher<PedometerTermsAgreeResponse, ResponseError>)
     */
    static func requestPedometerTermsAgree( token : String = NetworkManager.getToken() ) -> AnyPublisher<PedometerTermsAgreeResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        
        return AlamofireAgent.request(APIConstant.API_PEDO_TERMS_CHECK, parameters: parameters)
    }
    
    
    /**
     만보게 약관 동의 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /popup/insertPedometerTerms.do
     - API 명: 만보기 약관동의 팝업에서 "동의" 선택으로 약관동의를 요청 합니다.
     - Date: 2023.03.15
     - Parameters:
        - token : 기본 토큰 정보 입니다.
     - Throws: False
     - returns:
        만보게 약관동의 요청 후 확인 정보를 받습니다. (AnyPublisher<InsertPedometerTermsResponse, ResponseError>)
     */
    static func requestInsertPedometerTerms( token : String = NetworkManager.getToken() ) -> AnyPublisher<InsertPedometerTermsResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_PEDO_TERMS_AGREE, parameters: parameters)
    }
    
    
    /**
     앱 시작 기본 정보 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/start.do
     - API 명: 앱 시작 기본 정보 요청 합니다.
     - Date: 2023.03.27
     - Parameters:
        - token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        앱 전체적으로 기본 정보를 및 각 네이티브 영역 메뉴 선택시 이동 할 URL 정보를 리턴 합니다. (AnyPublisher<AppStartResponse, ResponseError>)
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
      Fcm PUSH 토큰 정보를 업로드 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/pushToken.do
     - API 명: FCM Token 업데이트 합니다.
     - Date: 2023.04.12
     - Parameters:
        - token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        FCM 업로드 요청 입니다. ( AnyPublisher<FcmPushUpdateResponse, ResponseError> )
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
     로그인을 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/login.do
     - API 명: 로그아웃을 요청 합니다.
     - Date: 2023.03.27
     - Parameters:
        - token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        로그인 데이터 정보 입니다. (AnyPublisher<LoginResponse, ResponseError>)
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
     로그아웃을 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/logout.do
     - API 명: 로그아웃을 요청 합니다.
     - Date: 2023.03.20
     - Parameters:
        - token : 기본 토큰 정보 입니다.
     - Throws: False
     - Returns:
        로그아웃 여부 정보를 받습니다. (AnyPublisher<LogOutResponse, ResponseError>)
     */
    static func requestLogOut( token : String = NetworkManager.getToken() ) -> AnyPublisher<LogOutResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_LOGOUT, parameters: parameters)
    }
    
    
    /**
     만료된 은행 계좌 재인증 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: openbank/authorizeAccount
     - API 명: 계좌 재인증 요청 입니다.
     - Date: 2023.03.21
     - Parameters:
        - token : token : 기본 토큰 정보 입니다.
     - Throws: False
     - Returns:
        인증 여부를 받습니다. (AnyPublisher<ReBankAuthResponse, ResponseError>)
     */
    static func requestReBankAuth( token : String = NetworkManager.getToken() ) -> AnyPublisher<ReBankAuthResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_AUTH_ACCOUNT, parameters: parameters)
    }
    
    
    /**
     연결된 은행 계좌 리스트 정보를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: myp/selectAccountList.do
     - API 명: 은행 계좌 요청 입니다.
     - Date: 2023.03.22
     - Parameters:
        - token : 기본 토큰 정보 입니다.
     - Throws: False
     - Returns:
        계좌 리스트 정보를 받습니다. (AnyPublisher<SelectAccountListResponse, ResponseError>)
     */
    static func requestSelectAccountList( token : String = NetworkManager.getToken() ) -> AnyPublisher<SelectAccountListResponse, ResponseError> {
        let parameters: Parameters = ["token": token]
        return AlamofireAgent.request(APIConstant.API_ACCOUNT_LIST, parameters: parameters)
    }
    
    
    /**
     계좌 정보를 메인 계좌로 등록 요청 합니다. ( J.D.H VER : 2.0.2 )
     - API ID: /all/updateMainAccount.do
     - API 명: 주계좌 업데이트 요청 입니다.
     - Date: 2023.08.16
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        주계좌 인증여부를 받습니다. ( AnyPublisher<UpdateMainAccountResponse, ResponseError> )
     */
    static func requestUpdateMainAccount( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<UpdateMainAccountResponse, ResponseError> {
        var parameters: Parameters = [ "token": token ]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_ACCOUNT_MAIN_UPDATE, parameters: parameters)
    }
    

    /**
     만보기 수령 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: myp/selectMyPedometer.do
     - API 명: 만보기 수령 요청 입니다.
     - Date: 2023.03.22
     - Parameters:
        - token : 기본 토큰 정보 입니다.
     - Throws: False
     - Returns:
        만보기 데이터를 받습니다. (AnyPublisher<PedometerResponse, ResponseError>)
     */
    static func requestPedometer( token : String = NetworkManager.getToken() ) -> AnyPublisher<PedometerResponse, ResponseError> {
        let parameters: Parameters = [ "token": token ]
        return AlamofireAgent.request(APIConstant.API_GET_PEDOMETER, parameters: parameters)
    }
    
    
    /**
     만보기 리워드 수령 합니다.  ( J.D.H VER : 2.0.0 )
     - API ID: myp/insertPedometer.do
     - API 명: 만보기 리워드 수령 요청 입니다.
     - Date: 2023.03.22
     - Parameters:
        - token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        만보기 리워드 데이터를 받습니다. (AnyPublisher<PedometerRewardResponse, ResponseError>)
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
     만보기 데이터를 업데이트 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: myp/updateDailyPedometer.do
     - API 명: 만보기 데이터를 업데이트 합니다.
     - Date: 2023.03.22
     - Parameters:
        - token : 기본 토큰 정보 입니다.
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        만보기 업데이트 완료 여부를 받습니다. (AnyPublisher<PedometerUpdateResponse, ResponseError>)
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
     세션이 활성화 상태인지를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/checkLoginInfo
     - API 명: 현 세션이 활성화 상태인지를 체크 합니다.
     - Date: 2023.05.26
     - Parameters:
        - token : 기본 토큰 정보 입니다.
     - Throws:False
     - Returns:
        세션 유지 여부를 받습니다. ( AnyPublisher<SessionCheckResponse, ResponseError> )
     */
    static func requestSessionCheck( token : String = NetworkManager.getToken() ) -> AnyPublisher<SessionCheckResponse, ResponseError> {
        let parameters: Parameters = [ "token": token ]
        return AlamofireAgent.request(APIConstant.API_SESSION_CHECK, parameters: parameters)
    }
    
    
    /**
     제로페이 인증 정보와 QRCode 정보로 제로페이에 리턴할 스크립트를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/v1/zeropay/qrcode.do
     - API 명: QRCode 인증 할 제로페이 스크립트를 요청 합니다.
     - Date: 2023.04.19
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        QRCode 인증 할 제로페이 스크립트를 받습니다. ( AnyPublisher<ZeroPayQRCodeResponse, ResponseError> )
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
    
    
    /**
     제로페이 간편결제 약관 동의 여부를 체크 합니다.. ( J.D.H VER : 2.0.0 )
     - API ID: /api/v1/zeropay/qr/agree
     - API 명: 제로페이 간편결제 약관동의 체크 입니다.
     - Date: 2023.07.05
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        약관동의 여부를 받습니다.  ( AnyPublisher<ZeroPayTermsCheckResponse, ResponseError> )
     */
    static func requestZeroPayTermsCheck( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<ZeroPayTermsCheckResponse, ResponseError> {
        var getParams = "?"
        for (key,value) in params
        {
            getParams += "\(key)=\(value)&"
        }
        getParams.remove(at: getParams.index(before: getParams.endIndex))
        return AlamofireAgent.request(APIConstant.API_ZEROPAY_TERMS_CHECK + getParams, method : .get, parameters: nil)
    }
    
    
    /**
     제로페이 간편결제 약관 동의를 요청 합니다. "POST" 요청 하여야 하며 해당 경우는 동의로 판단 합니다.( J.D.H VER : 2.0.0 )
     - API ID: /api/v1/zeropay/qr/agree
     - API 명: 제로페이 간편결제 약관동의 저장 입니다.
     - Date: 2023.07.05
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        약관동의 정상 처리 여부를 받습니다.  ( AnyPublisher<ZeroPayTermsAgreeResponse, ResponseError> )
     */
    static func requestZeroPayTermsAgree( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<ZeroPayTermsAgreeResponse, ResponseError> {
        var parameters: Parameters = [ "token": token ]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_ZEROPAY_TERMS_AGREE, parameters: parameters)
    }
    
    
    /**
     제로페이 간편결제 카드 머니 정보 숨김/보기 입니다 ( J.D.H VER : 2.0.0 )
     - API ID: /all/updateBalanceView.do
     - API 명: 카드 머니 정보 숨김/보기 정보 업데이트 입니다.
     - Date: 2023.07.05
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        정상 처리 여부를 받습니다.  ( AnyPublisher<ZeroPayMoneyOnOffResponse, ResponseError> )
     */
    static func requestZeroPayMoneyOnOff( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<ZeroPayMoneyOnOffResponse, ResponseError> {
        var updateParam : [String:Any] = [ "token": token ]
        for (key,value) in params
        {
            updateParam.updateValue(value, forKey: key)
        }
        return AlamofireAgent.requestJson( APIConstant.API_ZEROPAY_MONEY_ONOFF, parameters: updateParam )
    }
    
    
    /**
     제로페이 간편결제 QR/BarCode 정보를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/v1/zeropay/qr/code
     - API 명: 간편결제 사용될 코드 정보를 요청 합니다.
     - Date: 2023.07.05
     - Parameters:
        - params : token , user_no 정보를 받습니다.
     - Throws: False
     - Returns:
        QR/BarCode 정보를 받습니다.  ( AnyPublisher<ZeroPayQRBarCodeResponse, ResponseError> )
     */
    static func requestZeroPayQRBarCode( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<ZeroPayQRBarCodeResponse, ResponseError> {
        /// 기본 파라미터 정보를 설정 합니다.
        let parameters = self.getDefaultParams(method: .get) as! String
        return AlamofireAgent.request(APIConstant.API_ZEROPAY_QR_BARCODE + "/\(parameters)", method :.get, parameters: nil)
    }
    
    
    /**
     제로페이 간편결제 스캔된 QRCode 정보를 정상여부 체크 합니다. ( J.D.H VER : 2.0.0 )
     - API ID: /api/v1/zeropay/qr
     - API 명: MPM 고정형 QR코드 정상여부 인식 입니다.  ( S : 정지, A : 사용가능, N :  존재하지 않는 QR코드 )
     - Date: 2023.07.05
     - Parameters:
        - qrcode : 스캔한 QRCode 정보 입니다.
     - Throws: False
     - Returns:
        QR/BarCode 정보를 받습니다.  ( AnyPublisher<ZeroPayQRCodeStatusResponse, ResponseError> )
     */
    static func requestZeroPayQRCodeCheck( qrcode : String ) -> AnyPublisher<ZeroPayQRCodeStatusResponse, ResponseError> {
        return AlamofireAgent.request(APIConstant.API_ZEROPAY_ENCOED_QRCODE_CHECK + "/\(qrcode)", method :.get, parameters: nil)
    }
    
    
    /**
     해당 사용자의 OK머니 잔액,잔액 숨김여부,메인계좌 정보를 요청합니다.( J.D.H VER : 2.0.0 )
     - API ID: /api/v1/okmoney
     - API 명:   OK머니 정보 조회 입니다.
     - Date: 2023.07.06
     - Parameters:False
     - Throws: False
     - Returns:
        QR/BarCode 정보를 받습니다.  ( AnyPublisher<ZeroPayOKMoneyResponse, ResponseError> )
     */
    static func requestZeroPayOKMoney() -> AnyPublisher<ZeroPayOKMoneyResponse, ResponseError> {
        /// 기본 파라미터 정보를 설정 합니다.
        let parameters = self.getDefaultParams(method: .get) as! String
        return AlamofireAgent.request(APIConstant.API_ZEROPAY_OkMONEY + "/\(parameters)", method :.get, parameters: nil)
    }
    
    
    /**
     ATM 약관 동의 여부를 체크 합니다.. ( J.D.H VER : 2.0.7 )
     - API ID: /coocon/atmAgreeChk.do
     - API 명: ATM 약관동의 여부 체크 입니다.
     - Date: 2023.11.28
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        약관동의 여부를 받습니다.  ( AnyPublisher<AtmAgreementResponse, ResponseError> )
     */
    static func requestATMAgreeCheck( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<AtmAgreementResponse, ResponseError> {
        var updateParam : [String:Any] = [ "token": token ]
        for (key,value) in params
        {
            updateParam.updateValue(value, forKey: key)
        }
        return AlamofireAgent.requestJson( APIConstant.API_COOCON_ATM_AGREEMENT, parameters: updateParam )
    }
    
    
    /**
     ATM 약관동의 요청 입니다..( J.D.H VER : 2.0.7 )
     - API ID: /coocon/insertAtmAgreement.do
     - API 명: ATM 약관동의 요청 입니다.
     - Date: 2023.11.28
     - Parameters:
        - params : 파라미터 정보를 넘깁니다.
     - Throws: False
     - Returns:
        약관동의 정상 처리 여부를 받습니다.  ( AnyPublisher<AtmInsertAgreementResponse, ResponseError> )
     */
    static func requestATMInsertAgreement( token : String = NetworkManager.getToken(), params : [String : Any] = [:] ) -> AnyPublisher<AtmInsertAgreementResponse, ResponseError> {
        var parameters: Parameters = [ "token": token ]
        for (key,value) in params
        {
            parameters.updateValue(value, forKey: key)
        }
        return AlamofireAgent.request(APIConstant.API_COOCON_ATM_INSERT_AGREE, parameters: parameters)
    }
}

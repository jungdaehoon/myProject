//
//  LoginModel.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/27.
//

import Foundation
import Combine


/**
 로그인 코드 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.03
*/
enum LOGIN_CODE : String {
    /// 로그인 체크 코드가 없을 경우 입니다.
    case _code_fail_   = ""
    /// 정상 로그인 입니다.
    case _code_0000_   = "0000"
    /// 휴대폰 본인 재인증 입니다.
    case _code_1004_   = "1004"
    ///  PW 불일치 입니다.
    case _code_1005_   = "1005"
    /// 아이디가 존재 하지 않습니다.
    case _code_1002_   = "1002"
    /// 90일 동안 비밀번호 변경 요청 없는 경우 입니다.
    case _code_1006_   = "1006"
}


/**
 로그인 페이지 모델 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
*/
class LoginModel : BaseViewModel {
    
    /**
     로그인 처리 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:
        - id : 아이디 정보를 받습니다.
        - xkPWField : 보안 텍스트 필드 입니다.
        - inputPW : 입력된 패스워드 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<LoginResponse?, ResponseError>
            +  LoginResponse : 로그인 처리 결과를 받습니다.
     */
    func setLogin( _ id : String, xkPWField : XKTextField, inputPW : String ) ->  AnyPublisher<LoginResponse?, ResponseError> {
        var parameters  : [String:Any] = [:]
        var aSessionID          = xkPWField.getSessionIDE2E()
        let aToken              = xkPWField.getTokenE2E()
        
        if aSessionID!.count < 8 {
            let appendZero = "0"
            let count = aSessionID!.count
            let paddingCount = 8 - count
            let i = 0
            for  _ in i ..< paddingCount {
                aSessionID = appendZero + aSessionID!
            }
        }
        
        parameters = ["login_type"              : "P",
                      "user_hp"                 : id,
                      "xksessionid"             : aSessionID! ,
                      "xksectoken"              : aToken! ,
                      "xkindexed"               : inputPW,
                      "appshield_session_id"    : self.appShield.session_id! ,
                      "appshield_token"         : self.appShield.token!]
        
        parameters["auto_login"]    = SharedDefaults.getKeyChainCustItem()!.auto_login == true ? "Y" : "N"
        parameters["user_no"]       = NC.S(SharedDefaults.getKeyChainCustItem()!.user_no)
        
        
        let subject             = PassthroughSubject<LoginResponse?,ResponseError>()
        requst(showLoading: true ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 로그인 요청 합니다.
            return NetworkManager.requestLogin(params: parameters)
        } completion: { model in
            BaseViewModel.loginResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     정상 로그인된 정보를 KeyChainCustItem 정보에 세팅 합니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.17
     - Parameters:
        - user_hp : 유저 휴대폰 정보를 받습니다.
     - Throws : False
     - returns :
        - AnyPublisher<Bool?, Never>
            +  정상 저장 여부를 리턴 합니다.
     */
    func setKeyChainCustItem( _ user_hp : String ) -> Future<Bool, Never> {
        return Future<Bool, Never> { promise in
            if let custItem = SharedDefaults.getKeyChainCustItem() {
                if let response = BaseViewModel.loginResponse
                {
                    if let info = response.data
                    {
                        custItem.last_login_time    = info.Last_login_time
                        custItem.token              = info.token
                        custItem.user_no            = info.user_no
                        custItem.user_hp            = user_hp
                        SharedDefaults.setKeyChainCustItem(custItem)
                        promise(.success(true))
                        return
                    }
                }
            }
            promise(.success(false))
        }
    }
}

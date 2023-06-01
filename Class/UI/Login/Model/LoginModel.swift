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
 - Date: 2023.04.03
*/
enum LOGIN_CODE : String {
    /// 로그인 체크 코드가 없을 경우 입니다.
    case _code_fail_   = ""
    /// 정상 로그인 입니다.
    case _code_0000_   = "0000"
    /// 휴먼회원 코드 입니다.
    case _code_0010_   = "0010"
    /// 인증 만료 코드 입니다. ( 계좌인증 만료 )
    case _code_0011_   = "0011"
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
 - Date: 2023.03.20
*/
class LoginModel : BaseViewModel {
    
    /**
     로그인 처리 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.20
     - Parameters:
        - id : 아이디 정보를 받습니다.
        - xkPWField : 보안 텍스트 필드 입니다.
        - inputPW : 입력된 패스워드 입니다.
     - Throws: False
     - Returns:
        로그인 처리 결과를 받습니다. (AnyPublisher<LoginResponse?, ResponseError>)
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
        
        parameters["auto_login"]        = SharedDefaults.getKeyChainCustItem()!.auto_login == true ? "Y" : "N"
        parameters["user_no"]           = NC.S(SharedDefaults.getKeyChainCustItem()!.user_no)
        parameters["wallet_address"]    = SharedDefaults.default.walletAddress
        
        let subject             = PassthroughSubject<LoginResponse?,ResponseError>()
        requst() { error in
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
}

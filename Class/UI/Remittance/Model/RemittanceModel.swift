//
//  RemittanceModel.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/05.
//

import Foundation
import Combine

/**
 송금 웹뷰 모델 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.22
*/
class RemittanceModel : BaseViewModel{
    /// 계좌 정보를 요청 합니다.
    var selectAccountListResponse : SelectAccountListResponse?
    /// 만료된 계좌 재인증 데이터를 받습니다.
    var reBankAuthResponse  : ReBankAuthResponse?
    
    
    
    /**
     은행 계좌 리스트 정보를 요청 입니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.21
     - Parameters:False
     - Throws : False
     - returns :
        - AnyPublisher<SelectAccountListResponse?, ResponseError>
            +  SelectAccountListResponse : 연결된 계좌 정보들을 받습니다.
     */
    func getSelectAccountList() ->  AnyPublisher<SelectAccountListResponse?, ResponseError> {
        let subject             = PassthroughSubject<SelectAccountListResponse?,ResponseError>()
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 계좌 리스트 요청 합니다.
            return NetworkManager.requestSelectAccountList()
        } completion: { model in
            self.selectAccountListResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     은행 계좌 재인증 요청 입니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.21
     - Parameters:False
     - Throws : False
     - returns :
        - AnyPublisher<LogOutResponse?, ResponseError>
            +  LogOutResponse : 로그아웃 처리 결과를 받습니다.
     */
    func setReBankAuth() ->  AnyPublisher<ReBankAuthResponse?, ResponseError> {
        let subject             = PassthroughSubject<ReBankAuthResponse?,ResponseError>()
        requst( showLoading: true ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 계좌 재인증 요청 합니다.
            return NetworkManager.requestReBankAuth()
        } completion: { model in
            self.reBankAuthResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
}

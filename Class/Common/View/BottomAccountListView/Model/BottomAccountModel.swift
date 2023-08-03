//
//  BottomAccountModel.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/02.
//

import Foundation
import Combine


/**
 하단 계좌 리스트 모델 입니다.    ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.05
 */
class BottomAccountModel : BaseViewModel{
    /// 계좌 리스트 정보를 가집니다.
    var accountResponse : AccountsResponse?
    
    /**
     은행 계좌 리스트 정보를 요청 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.05
     - Parameters:False
     - Throws: False
     - Returns:
        연결된 계좌 정보들을 받습니다. (AnyPublisher<AccountsResponse?, ResponseError>)
     */
    func getAccountList() ->  AnyPublisher<AccountsResponse?, ResponseError> {
        let subject             = PassthroughSubject<AccountsResponse?,ResponseError>()
        requst( showLoading : false ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 계좌 리스트 요청 합니다.
            return NetworkManager.requestAccounts()
        } completion: { model in
            self.accountResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
}

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
 - Date: 2023.03.22
*/
class RemittanceModel : BaseViewModel{
    /// 계좌 정보를 요청 합니다.
    var selectAccountListResponse : SelectAccountListResponse?    
    
    /**
     은행 계좌 리스트 정보를 요청 입니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.21
     - Parameters:False
     - Throws: False
     - Returns:
        연결된 계좌 정보들을 받습니다. (AnyPublisher<SelectAccountListResponse?, ResponseError>)
     */
    func getSelectAccountList() ->  AnyPublisher<SelectAccountListResponse?, ResponseError> {
        let subject             = PassthroughSubject<SelectAccountListResponse?,ResponseError>()
        requst( showLoading : false ) { error in
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
}

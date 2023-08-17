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
    var accountResponse : SelectAccountListResponse?
    
    
    /**
     은행 계좌 리스트 정보를 요청 입니다. ( J.D.H VER : 2.0.2 )
     - Date: 2023.08.16
     - Parameters:False
     - Throws: False
     - Returns:
     연결된 계좌 정보들을 받습니다. (AnyPublisher<SelectAccountListResponse?, ResponseError>)
     */
    func getAccountList() ->  AnyPublisher<SelectAccountListResponse?, ResponseError> {
        let subject             = PassthroughSubject<SelectAccountListResponse?,ResponseError>()
        requst( showLoading : false ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 계좌 리스트 요청 합니다.
            return NetworkManager.requestSelectAccountList()
        } completion: { model in
            self.accountResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     메인 계좌 등록 요청  입니다. ( J.D.H VER : 2.0.2 )
     - Date: 2023.08.16
     - Parameters:False
     - Throws: False
     - Returns:
     업데이트 여부를 받습니다.. (AnyPublisher<UpdateMainAccountResponse?, ResponseError>)
     */
    func setUpdateMainAccount( account : Account ) ->  AnyPublisher<UpdateMainAccountResponse?, ResponseError> {
        let subject             = PassthroughSubject<UpdateMainAccountResponse?,ResponseError>()
        requst( showLoading : false ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 계좌 리스트 요청 합니다.
            return NetworkManager.requestUpdateMainAccount( params: ["fin" : account._fintech_use_num!] )
        } completion: { model in
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     은행 계좌 제인증 여부를 체크 합니다.. ( J.D.H VER : 2.0.2 )
     - Date: 2023.08.16
     - Parameters:
        - account : 계좌 상세 정보 입니다.
     - Throws: False
     - Returns:
     계좌 제인증 여부를 체크 하여 리턴 합니다. ( 제인증 : true , 인증하지 않음 : false )
     */
    func getAccountReauth( account : Account? ) -> Bool {
        if let account = account {
            /// 계좌 제인증 관련 여부를 체크 합니다.
            if account._acc_aggre_yn == "N" || account._inquiry_agree_yn == "N" || account._transfer_agree_yn == "N"
            {
                return true
            }
            return false
        }
        return true
    }
    
    
    /**
     은행 계좌 제인증 여부에 따른 높이 값을 체크 합니다.  ( J.D.H VER : 2.0.2 )
     - Date: 2023.08.16
     - Parameters:
        - account : 계좌 상세 정보 입니다.
     - Throws: False
     - Returns:
     계좌 제인증 여부를 체크 하여 리턴 합니다. ( 제인증 : true , 인증하지 않음 : false )
     */
    func getAccountHeight( account : Account? ) -> CGFloat {
        /// 제인증 여부를 받습니다.
        if self.getAccountReauth( account: account) {
            return 76.0
        }
        return 64.0
    }
    
    
    /**
     계좌 총 리스트 정보에 따른 전체 높이값을 리턴 합니다.  ( J.D.H VER : 2.0.2 )
     - Date: 2023.08.16
     - Parameters:
        - account : 계좌 상세 정보 입니다.
     - Throws: False
     - Returns:
     계좌 제인증 여부를 체크 하여 리턴 합니다. ( 제인증 : true , 인증하지 않음 : false )
     */
    func getAccountsHeight( model : SelectAccountListResponse? ) -> CGFloat {
        var maxHeight = 0.0
        if let response = model,
           let accounts = response._list {
            for account in accounts
            {
                /// 계좌 타입에 맞춰 높이 값을 받습니다.
                maxHeight += self.getAccountHeight(account: account)
            }
        }
        return maxHeight
    }
}

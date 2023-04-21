//
//  AllMoreModel.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import Foundation
import Combine


/**
 메뉴 리스트별 인포 정보 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
*/
struct AllModeMenuListInfo: Codable {
    /// 타이틀 정보 입니다
    var _title              : String?
    /// 서브 타이틀 입니다
    var _subTitle           : String?
    /// 메뉴 안내 아이콘 정보 입니다. ("NEW!", "UPDATE!!")
    var _subiCon            : String?
    /// 메뉴 리스트 타입입니다. ("text" : "등록" 문구 , "rightimg" : > 이미지)
    var _menuType           : String?
}


/**
 전체 상세정보를 모델 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
*/
class AllMoreModel : BaseViewModel{
    /// 전체 탭 데이터를 가집니다.
    var allModeResponse     : AllMoreResponse?    
    /// 만료된 계좌 재인증 데이터를 받습니다.
    var reBankAuthResponse  : ReBankAuthResponse?
    /// 로그아웃 여부를 가집니다.
    @Published var logOut   : Bool = false
    
    
    /**
     메뉴 리스트별 디스플레이 할 정보를 넘깁니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.07
     - Parameters:
        - title     : 메뉴 리스트 타이틀 정보 입니다.
        - subTitle  : 메뉴 리스트 오른쪽 추가 정보 문구 입니다. ( "우리01029" )
        - subiCon   : 메뉴 리스트 타이틀 정보 오른족 안내 아이콘 입니다. ( "NEW!", "UPDATE!!" )
        - menuType  : 메뉴 리스트 타입 정보 입니다. ("text" : "등록" 문구 , "rightimg" : > 이미지)
     - Throws : False
     - returns :
        + AllModeMenuListInfo : 메뉴에 디스플레이할 정보 입니다.
     */
    func getMenuInfo( title : String = "", subTitle : String = "", subiCon : String = "", menuType : String = "" ) -> AllModeMenuListInfo
    {
        var model       = AllModeMenuListInfo()
        model._title    = title
        model._subTitle = subTitle
        model._subiCon  = subiCon
        model._menuType = menuType
        return model
    }
    
    
    /**
     전체 탭 상세 정보를 서버에 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.09
     - Parameters:False
     - Throws : False
     - returns :
        - AnyPublisher<AllMoreResponse?, ResponseError>
            >  AllMoreResponse : 홈 소비 정보를 요청 합니다.
     */
    func getAllMoreInfo() -> AnyPublisher<AllMoreResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<AllMoreResponse?,ResponseError>()
        requst(showLoading : true ) { error in
            self.allModeResponse = nil
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 전체 탭 정보를 요청 합니다.
            return NetworkManager.requestAllMore()
        } completion: { model in
            self.allModeResponse = model
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
            >  LogOutResponse : 로그아웃 처리 결과를 받습니다.
     */
    func setReBankAuth() ->  AnyPublisher<ReBankAuthResponse?, ResponseError> {
        let subject             = PassthroughSubject<ReBankAuthResponse?,ResponseError>()
        requst( showLoading : true ) { error in
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

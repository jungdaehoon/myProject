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
 - Date: 2023.03.07
*/
struct AllModeMenuListInfo: Codable {
    /// 타이틀 정보 입니다
    var title              : String?
    /// 서브 타이틀 입니다
    var subTitle           : String?
    /// 메뉴 안내 아이콘 정보 입니다. ("NEW!", "UPDATE!!")
    var subiCon            : String?
    /// 메뉴 리스트 타입입니다.
    var menuType           : MENU_TYPE?
}


/**
 메뉴 리스트 타입 정보 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.05.02
*/
enum MENU_TYPE : Codable {
    /// 아무런 정보를 디스플레이 하지 않습니다.
    case null
    /// 메뉴 문구 입니다.
    case text
    /// 오른쪽 이동 화살표 입니다.
    case rightimg
}


/**
 전체 상세정보를 모델 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.07
*/
class AllMoreModel : BaseViewModel{
    /// 전체 탭 데이터를 가집니다.
    var allModeResponse     : AllMoreResponse?
    
    
    /**
     메뉴 리스트별 디스플레이 할 정보를 넘깁니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.07
     - Parameters:
        - title     : 메뉴 리스트 타이틀 정보 입니다.
        - subTitle  : 메뉴 리스트 오른쪽 추가 정보 문구 입니다. ( "우리01029" )
        - subiCon   : 메뉴 리스트 타이틀 정보 오른족 안내 아이콘 입니다. ( "NEW!", "UPDATE!!" )
        - menuType  : 메뉴 리스트 타입 정보 입니다. (.text : "등록" 문구 , .rightimg : > 이미지)
     - Throws: False
     - Returns:
        메뉴에 디스플레이할 정보 입니다. (AllModeMenuListInfo)
     */
    func getMenuInfo( title : String = "", subTitle : String = "", subiCon : String = "", menuType : MENU_TYPE = .null ) -> AllModeMenuListInfo
    {
        var model      = AllModeMenuListInfo()
        model.title    = title
        model.subTitle = subTitle
        model.subiCon  = subiCon
        model.menuType = menuType
        return model
    }
    
    
    /**
     전체 탭 상세 정보를 서버에 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.09
     - Parameters:False
     - Throws: False
     - Returns:
        홈 소비 정보를 요청 합니다. (AnyPublisher<AllMoreResponse?, ResponseError>)
     */
    func getAllMoreInfo() -> AnyPublisher<AllMoreResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<AllMoreResponse?,ResponseError>()
        requst() { error in
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
}

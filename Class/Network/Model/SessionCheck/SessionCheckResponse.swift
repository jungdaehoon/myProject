//
//  SessionCheckResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/26.
//

import Foundation



/**
 현 세션이 활성화 되어있는지를 체크 정보를 가집니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.05.26
*/
struct SessionCheckResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
    
    /// 사용자 번호 입니다.
    var _user_no            : String? { get { return  NC.S(user_no) } }
    
    /// 사용자 번호 입니다.
    var user_no             : String?
}

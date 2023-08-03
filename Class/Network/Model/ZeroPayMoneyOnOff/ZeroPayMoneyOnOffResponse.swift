//
//  ZeroPayMoneyOnOffResponse.swift
//  cereal
//
//  Created by OKPay on 2023/07/05.
//

import Foundation

 /**
  제로페이 간편결제 카드 머니 정보 숨김/보기 입니다.  ( J.D.H VER : 2.0.0 )
  - Date: 2023.07.05
 */
 struct ZeroPayMoneyOnOffResponse: BaseResponse {
     /// 세부 응답코드 입니다.
     var result_cd           : String?
     /// 세부 응답메세지 입니다.
     var result_msg          : String?
     /// 세부 응답코드 입니다.
     var code                : String?
     /// 세부 응답메세지 입니다.
     var msg                 : String?
         
     /// 메인 데이터 입니다.
     var _data        : String? { get { return  NC.S(data) } }
     /// 메인 데이터 입니다.
     var data        : String?
 }

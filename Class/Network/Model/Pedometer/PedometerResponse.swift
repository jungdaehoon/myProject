//
//  PedometerResponse.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation

/**
 만보기 상세정보 요청 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.23
*/
struct PedometerResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
    
    
    /// 걸음수 입니다.
    var _steps              : Int? { get { return  NC.I(steps) } }
    /// 지급 포인트 입니다.
    var _data               : pedometer_data?  { get { return data != nil ? data : pedometer_data() } }
    /// 위변조방지용 문자 입니다. ( 암호화 steps + timestamp 13자리 )
    var _verification       : String? { get { return  NC.S(verification) } }
    
        
    /// 걸음수 입니다.
    var steps               : Int?
    /// 지급 포인트 입니다.
    var data                : pedometer_data?
    /// 위변조방지용 문자 입니다. ( 암호화 steps + timestamp 13자리 )
    var verification        : String?
}


/**
 만보기 지급 포인트 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.23
*/
struct pedometer_data : Codable {
    /// 지금 포인트 입니다.
    var _rcv_point          : Int? { get { return  NC.I(rcv_point) } }
    /// _전체 포인트 입니다.
    var _total_rcv_point    : Int? { get { return  NC.I(total_rcv_point) } }
    /// 리워여 여부 입니다.
    var _reward_yn          : String? { get { return  NC.S(reward_yn) } }
    /// 배너 이미지 정보 입니다.
    var _ban_img            : String? { get { return  NC.S(ban_img) } }
    /// 배너 선택시 이동할 URL 입니다.
    var _ban_url            : String? { get { return  NC.S(ban_url) } }
    /// 배너 타이틀 정보 입니다.
    var _ban_detail_title   : String? { get { return  NC.S(ban_detail_title) } }
    
    
    /// 배너 타이틀 정보 입니다.
    var ban_detail_title    : String?    
    /// 지금 포인트 입니다.
    var rcv_point           : Int?
    /// 전체 포인트 입니다.
    var total_rcv_point     : Int?
    /// 리워여 여부 입니다.
    var reward_yn           : String?
    /// 배너 이미지 정보 입니다.
    var ban_img             : String?
    /// 배너 선택시 이동할 URL 입니다.
    var ban_url             : String?
    
}

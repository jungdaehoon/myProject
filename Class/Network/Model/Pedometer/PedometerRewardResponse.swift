//
//  PedometerRewardResponse.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation

/**
 만보기 리워드 요청 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.23
*/
struct PedometerRewardResponse: BaseResponse {
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
    var _data               : pedometer_rewardData?  { get { return data != nil ? data : pedometer_rewardData() } }
    /// 위변조방지용 문자 입니다. ( 암호화 steps + timestamp 13자리 )
    var _verification       : String? { get { return  NC.S(verification) } }
    
        
    /// 걸음수 입니다.
    var steps               : Int?
    /// 지급 포인트 입니다.
    var data                : pedometer_rewardData?
    /// 위변조방지용 문자 입니다. ( 암호화 steps + timestamp 13자리 )
    var verification        : String?
}


struct pedometer_rewardData : Codable {
    /// 지금 포인트 입니다.
    var _rcv_point          : Int? { get { return  NC.I(rcv_point) } }
    /// _전체 포인트 입니다.
    var _total_rcv_point    : Int? { get { return  NC.I(total_rcv_point) } }
    /// 리워여 여부 입니다.
    var _reward_yn          : String? { get { return  NC.S(reward_yn) } }
    
    
    /// 지금 포인트 입니다.
    var rcv_point           : Int?
    /// 전체 포인트 입니다.
    var total_rcv_point     : Int?
    /// 리워여 여부 입니다.
    var reward_yn           : String?
}

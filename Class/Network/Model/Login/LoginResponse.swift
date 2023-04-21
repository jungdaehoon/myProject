//
//  LoginResponse.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/24.
//

import Foundation

/**
 로그인 정보를 받습니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.13
*/
struct LoginResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd       : String?
    /// 세부 응답메세지 입니다.
    var result_msg      : String?
    /// 세부 응답코드 입니다.
    var code            : String?
    /// 세부 응답메세지 입니다.
    var msg             : String?
    /// 로그인 여부를 가집니다.
    var islogin         : Bool?
    /// 닉네임 변경 여부를 가집니다.
    var nickname_ch     : Bool? { get {
        if let loginInfo = data
        {
            if NC.S(loginInfo.user_no) == NC.S(loginInfo.nickname)
            {
                return true
            }
        }
        return false        
    } }
    /// 로그인 인포 정보 입니다.
    var _data           : loginInfo? { get { return data != nil ? data : loginInfo() } }
    
    
    
    /// 로그인 인포 정보 입니다.
    var data        : loginInfo?
}


struct loginInfo: Codable
{
    
    /// 가입 날짜 정보 입니다.
    var _user_no                : String? { get { return  NC.S(user_no) } }
    /// 고객 CI 정보 입니다.
    var _ci                     : String? { get { return  NC.S(ci) } }
    /// 투자 성향명 입니다.
    var _simul_nm               : String? { get { return  NC.S(simul_nm) } }
    /// 유저 닉네임 입니다.
    var _nickname               : String? { get { return  NC.S(nickname) } }
    /// 유저 레벨 정보 입니다.
    var _user_level             : Int? { get { return  NC.I(user_level) } }
    /// 푸시 팝업 띄울지 여부 입니다.
    var _push_yn                : String? { get { return  NC.S(push_yn) } }
    /// 푸시 총 카운트 입니다.
    var _push_count             : Int? { get { return  NC.I(push_count) } }
    /// 제휴사 금액 정보입니다.
    var _asset_info             : asset_info? { get { return asset_info != nil ? asset_info : nil } }
    /// 최종 로그인 시간 입니다.
    var _Last_login_time        : String? { get { return  NC.S(Last_login_time) } }
    /// 프로필 이미지 입니다.
    var _user_img_url           : String? { get { return  NC.S(user_img_url) } }
    /// 자동 로그인 토큰 입니다.
    var _token                  : String? { get { return  NC.S(token) } }
    
    /// 고객번호 입니다.
    var user_no         : String?
    /// 고객 CI 정보 입니다.
    var ci              : String?
    /// 투자 성향명 입니다.
    var simul_nm        : String?
    /// 유저 닉네임 입니다.
    var nickname        : String?
    /// 유저 레벨 정보 입니다.
    var user_level      : Int?
    /// 푸시 팝업 띄울지 여부 입니다.
    var push_yn         : String?
    /// 푸시 총 카운트 입니다.
    var push_count      : Int?
    /// 제휴사 금액 정보입니다.
    var asset_info      : asset_info?
    /// 최종 로그인 시간 입니다.
    var Last_login_time : String?
    /// 프로필 이미지 입니다.
    var user_img_url    : String?
    /// 자동 로그인 토큰 입니다.
    var token           : String?
}


struct asset_info: Codable
{
    /// OK 머니 잔액 정보 입니다.
    var balance     : String?
    /// 총자산 정보입니다.
    var asset_amt   : String?
}

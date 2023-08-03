//
//  AccountsResponse.swift
//  cereal
//
//  Created by OKPay on 2023/07/05.
//

import Foundation

/**
 계좌 리스트 조회 정보를 받습니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.22
*/
struct AccountsResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
    /// 결과코드 입니다.
    var _result     : Bool? { get { return  result == nil ? false : result } }
    /// 계좌 목록 입니다.
    var _list       : [Accounts]? { get { return list != nil ? list : [] } }
    
    
    /// 결과코드 입니다.
    var result      : Bool?
    /// 계좌 목록 입니다.
    var list        : [Accounts]?
}


struct Accounts : Codable {
    /// 고객번호 입니다.
    var _user_no             : String? { get { return  NC.S(user_no) } }
    /// 계좌번호 입니다.
    var _acc_no              : String? { get { return  NC.S(acc_no) } }
    /// 납부자 번호 입니다.
    var _payer_num           : String? { get { return  NC.S(payer_num) } }
    /// 은행 코드 입니다.
    var _bank_cd             : String? { get { return  NC.S(bank_cd) } }
    /// 은행명 입니다.
    var _acc_nm              : String? { get { return  NC.S(acc_nm) } }
    /// 주계좌여부 입니다.
    var _main_yn             : String? { get { return  NC.S(main_yn) } }
    /// 등록일시 입니다.
    var _reg_dt              : Int? { get { return  NC.I(reg_dt) } }
    /// 등록자 아이디 입니다.
    var _req_id              : String? { get { return  NC.S(req_id) } }
    /// 수정일시 입니다.
    var _mod_dt              : Int? { get { return  NC.I(mod_dt) } }
    /// 수정자 아이디 입니다.
    var _mod_id              : String? { get { return  NC.S(mod_id) } }
    /// 핀테크 이용번호 입니다.
    var _fintech_use_num     : String? { get { return  NC.S(fintech_use_num) } }
    /// 조회 및 출금 동의 유효여부 입니다.
    var _acc_aggre_yn        : String? { get { return  NC.S(acc_aggre_yn) } }
    /// 조회 동의 여부 입니다.
    var _inquiry_agree_yn    : String? { get { return  NC.S(inquiry_agree_yn) } }
    /// 출금 동의 여부 입니다.
    var _transfer_agree_yn   : String? { get { return  NC.S(transfer_agree_yn) } }
    /// 금일 출금액 입니다.
    var _sum_data            : Int? { get { return  NC.I(sum_data) } }
    
    /// 고객번호 입니다.
    var user_no             : String?
    /// 계좌번호 입니다.
    var acc_no              : String?
    /// 납부자 번호 입니다.
    var payer_num           : String?
    /// 은행 코드 입니다.
    var bank_cd             : String?
    /// 은행명 입니다.
    var acc_nm              : String?
    /// 주계좌여부 입니다.
    var main_yn             : String?
    /// 등록일시 입니다.
    var reg_dt              : Int?
    /// 등록자 아이디 입니다.
    var req_id              : String?
    /// 수정일시 입니다.
    var mod_dt              : Int?
    /// 수정자 아이디 입니다.
    var mod_id              : String?
    /// 핀테크 이용번호 입니다.
    var fintech_use_num     : String?
    /// 조회 및 출금 동의 유효여부 입니다.
    var acc_aggre_yn        : String?
    /// 조회 동의 여부 입니다.
    var inquiry_agree_yn    : String?
    /// 출금 동의 여부 입니다.
    var transfer_agree_yn   : String?
    /// 금일 출금액 입니다.
    var sum_data            : Int?
}


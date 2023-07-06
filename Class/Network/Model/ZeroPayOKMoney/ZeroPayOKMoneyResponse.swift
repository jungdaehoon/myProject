//
//  ZeroPayOKMoneyResponse.swift
//  cereal
//
//  Created by OKPay on 2023/07/06.
//

import Foundation


/**
 제로페이 진입시 OK 머니 카드  상세 정보 입니다.  (  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.07.05
*/
struct ZeroPayOKMoneyResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
    
    /// 메인 데이터 입니다.
    var _data        : okmoneydata?    { get { return data != nil ? data : nil } }
    /// 메인 데이터 입니다.
    var data        : okmoneydata?
}


struct okmoneydata : Codable
{
    /// Ok머니 잔액 정보 입니다.
    var _balance         : Int? { get { return  NC.I(balance) } }
    /// 잔액 숨김 여부 입니다.
    var _balanceViewYn   : String? { get { return  NC.S(balanceViewYn) } }
    /// 잔액 보기 여부 입니다. ( true / false )
    var _isBalanceShow   : Bool? { get { return  NC.B(isBalanceShow) } }
    /// 메인계좌 은행명 입니다.
    var _bankName        : String? { get { return  NC.S(bankName) } }
    /// 메인계좌 넘버 마지막 4자리 입니다.
    var _lastAccountNo   : String? { get { return  NC.S(lastAccountNo) } }
    
    /// Ok머니 잔액 정보 입니다.
    var balance         : Int?
    /// 잔액 숨김 여부 입니다.
    var balanceViewYn   : String?
    /// 잔액 보기 여부 입니다. ( true / false )
    var isBalanceShow   : Bool?
    /// 메인계좌 은행명 입니다.
    var bankName        : String?
    /// 메인계좌 넘버 마지막 4자리 입니다.
    var lastAccountNo   : String?
}

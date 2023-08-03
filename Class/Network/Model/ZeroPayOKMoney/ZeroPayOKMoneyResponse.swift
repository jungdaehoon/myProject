//
//  ZeroPayOKMoneyResponse.swift
//  cereal
//
//  Created by OKPay on 2023/07/06.
//

import Foundation


/**
 제로페이 진입시 OK 머니 카드  상세 정보 입니다.  (  ( J.D.H VER : 1.24.43 )
 - Date: 2023.07.10
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


/**
 제로페이 진입시 OK 머니 카드  데이터 입니다.  ( J.D.H VER : 1.24.43 )
 - Date: 2023.07.10
*/
struct okmoneydata : Codable
{
    /// Ok머니 잔액 정보 입니다.
    var _balance         : Int? { get { return  NC.I(balance) } }
    /// 잔액 숨김 여부 입니다.
    var _balanceViewYn   : String? { get { return  NC.S(balanceViewYn) } }
    /// 잔액 보기 여부 입니다. ( true / false )
    var _isBalanceShow   : Bool? { get { return  NC.B(isBalanceShow) } }
    /// 메인 계좌 정보를 받습니다.
    var _mainAccount     : mainaccount? { get { return mainAccount != nil ? mainAccount : nil } }
    
    /// Ok머니 잔액 정보 입니다.
    var balance         : Int?
    /// 잔액 숨김 여부 입니다.
    var balanceViewYn   : String?
    /// 잔액 보기 여부 입니다. ( true / false )
    var isBalanceShow   : Bool?
    /// 메인 계좌 정보를 받습니다.
    var mainAccount     : mainaccount? 
}


/**
 제로페이 진입시 OK 머니 카드  메인 계좌 정보 입니다.  ( J.D.H VER : 1.24.43 )
 - Date: 2023.07.10
*/
struct mainaccount : Codable
{
    /// 잔액 숨김 여부 입니다.
    var _bankName               : String?  { get { return  NC.S(bankName) } }
    /// 납부자 번호 입니다.
    var _payerNum                : String? { get { return  NC.S(payerNum) } }
    /// 메인 계좌 정보 마지막 4자리 입니다.
    var _lastAccountNo           : String? { get { return  NC.S(lastAccountNo) } }
    /// 마킹 처리된 총 계좌 정보 입니다.
    var _maskedAccountNo         : String? { get { return  NC.S(maskedAccountNo) } }
    /// 핀테크 번호 입니다.
    var _fintechUseNum           : String? { get { return  NC.S(fintechUseNum) } }
    /// 계좌 재인증 여부 입니다.
    var _isNeedToReauthorize     : Bool?   { get { return  NC.B(isNeedToReauthorize) } }
    /// 계좌 재인증 여부가 "true" 인 경우 안내 문구 입니다.
    var _needToReAuthorizeMsg    : String? { get { return  NC.S(needToReAuthorizeMsg) } }
    /// 연결 계좌 미 존재 여부 입니다.
    var _hasNoMainAccount        : Bool?   { get { return  NC.B(hasNoMainAccount) } }
    /// 연결 계좌 미존재 여부가 "true" 경우 안내 문구 입니다.
    var _noMainAccountMsg        : String? { get { return  NC.S(noMainAccountMsg) } }
    /// 아래 은행 이미지 호스트 URL  입니다.
    var _host                    : String? { get { return  NC.S(host) } }
    /// 은행 이미지 "사각" 모양 입니다.
    var _bankImg                 : String? { get { return  NC.S(bankImg) } }
    /// 은행 이미지 "라운드" 모양 입니다.
    var _bankRoundImg            : String? { get { return  NC.S(bankRoundImg) } }
    /// 은행 이미지 "큰 라운드" 모양 입니다.
    var _bankBigRoundImg         : String? { get { return  NC.S(bankBigRoundImg) } }
    
    
    /// 은행명 입니다.
    var bankName                : String?
    /// 납부자 번호 입니다.
    var payerNum                : String?
    /// 메인 계좌 정보 마지막 4자리 입니다.
    var lastAccountNo           : String?
    /// 마킹 처리된 총 계좌 정보 입니다.
    var maskedAccountNo         : String?
    /// 핀테크 번호 입니다.
    var fintechUseNum           : String?
    /// 계좌 재인증 여부 입니다.
    var isNeedToReauthorize     : Bool?
    /// 계좌 재인증 여부가 "true" 인 경우 안내 문구 입니다.
    var needToReAuthorizeMsg    : String?
    /// 연결 계좌 미 존재 여부 입니다.
    var hasNoMainAccount        : Bool?
    /// 연결 계좌 미존재 여부가 "true" 경우 안내 문구 입니다.
    var noMainAccountMsg        : String?
    /// 아래 은행 이미지 호스트 URL  입니다.
    var host                    : String?
    /// 은행 이미지 "사각" 모양 입니다.
    var bankImg                 : String?
    /// 은행 이미지 "라운드" 모양 입니다.
    var bankRoundImg            : String?
    /// 은행 이미지 "큰 라운드" 모양 입니다.
    var bankBigRoundImg         : String?
}

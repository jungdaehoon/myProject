//
//  AllMoreResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/08.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation


/**
 전체 탭 영역 정보를 처리합니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
struct AllMoreResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
    
    /// 전체 탭 주요 데이터 입니다.
    var _result       : allData? { get { return result != nil ? result : allData() } }
    
    /// 전체 탭 주요 데이터 입니다.
    var result      : allData?
}


/**
 전체 탭 주요 데이터 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
struct allData: Codable {
    /// 추천인 입력 가능여부 입니다.
    var _recomm_yn              : String? { get { return  NC.S(recomm_yn) } }
    /// 계좌넘버 입니다.
    var _acc_no                 : String? { get { return  NC.S(acc_no) } }
    /// 휴대폰 넘버 입니다.
    var _hp_no                  : String? { get { return  NC.S(hp_no) } }
    /// 네트워크 처리 코드 정보 입니다.
    var _code                   : String? { get { return  NC.S(code) } }
    /// 계좌 조회 및 출금 동의 유효 여부 입니다.
    var _acc_aggre_yn           : String? { get { return  NC.S(acc_aggre_yn) } }
    /// 계좌 조회 동의 여부 입니다.
    var _inquiry_agree_yn       : String? { get { return  NC.S(inquiry_agree_yn) } }
    /// 닉네임 정보 입니다.
    var _nickname               : String? { get { return  NC.S(nickname) } }
    /// 유저 레벨 정보 입니다.
    var _user_level             : Int? { get { return  NC.I(user_level) } }
    /// 유저 포인트 정보입니다.
    var _user_point             : Int? { get { return  NC.I(user_point) } }
    /// OK머니 잔액 정보 입니다.
    var _balance                : Int? { get { return  NC.I(balance) } }
    /// 어벤달 결제 건수 입니다.
    var _current_month_pay_cnt  : Int? { get { return  NC.I(current_month_pay_cnt) } }
    /// 어벤달 결제 정보 입니다.
    var _current_month_pay_amt  : Int? { get { return  NC.I(current_month_pay_amt) } }
    /// 어벤달 적립 정보 입니다.
    var _current_month_save_amt : Int? { get { return  NC.I(current_month_save_amt) } }
    /// 추천인 코드 정보 입니다.
    var _recomm_code            : String? { get { return  NC.S(recomm_code) } }
    /// 오픈 뱅킹 오픈 일시 입니다.
    var _openbank_open_dt       : String? { get { return  NC.S(openbank_open_dt) } }
    /// 제휴사 예치금 입니다.
    var _inv_balance            : Int? { get { return  NC.I(inv_balance) } }
    /// 투자 성향 분석 결과 입니다
    var _simul_nm               : String? { get { return  NC.S(simul_nm) } }
    /// 출금 동의 여부입니다.
    var _transfer_agree_yn      : String? { get { return  NC.S(transfer_agree_yn) } }
    /// 연결된 은행명 입니다.
    var _bank_nm                : String? { get { return  NC.S(bank_nm) } }
    /// 사용자 일련번호 입니다.
    var _user_seq_no            : String? { get { return  NC.S(user_seq_no) } }
    /// 유저 이미지 URL 입니다.
    var _user_img_url           : String? { get { return  NC.S(user_img_url) } }
    /// 제휴사 예치금 정보들 입니다.
    var _inv_balance_list       : [inv_balance_list]? { get { return inv_balance_list != nil ? inv_balance_list : [] } }
    /// 유저 넘버 입니다.
    var _user_no                : String? { get { return  NC.S(user_no) } }
    /// 포인트 거래내역 입니다.
    var _point_trans_list       : [point_trans_list]? { get { return point_trans_list != nil ? point_trans_list : [] } }
    /// 가입 날짜 정보 입니다.
    var _join_dt                : String? { get { return  NC.S(join_dt) } }
    /// 핀테크 이용 번호 입니다.
    var _fintech_use_num        : String? { get { return  NC.S(fintech_use_num) } }
    /// 수정 날짜 정보입니다.
    var _mod_dt                 : String? { get { return  NC.S(mod_dt) } }
    /// 거래내역 정보입니다.
    var _acc_trans_list         : [acc_trans_list]? { get { return acc_trans_list != nil ? acc_trans_list : [] } }
    /// 오픈뱅킹 사용여부 입니다.
    var _openbank               : Bool?   { get { return  openbank == nil ? false : openbank } }
    /// NFT 구매 카운트 입니다.
    var _own_nft_cnt            : Int? { get { return  NC.I(own_nft_cnt)  } }
    /// NFT 아이디 정보 입니다.
    var _nft_id                 : String? { get { return  NC.S(nft_id)  } }
    
    
    
    /// 추천인 입력 가능여부 입니다.
    var recomm_yn               : String?
    /// 계좌넘버 입니다.
    var acc_no                  : String?
    /// 휴대폰 넘버 입니다.
    var hp_no                   : String?
    /// 네트워크 처리 코드 정보 입니다.
    var code                    : String?
    /// 계좌 조회 및 출금 동의 유효 여부 입니다.
    var acc_aggre_yn            : String?
    /// 계좌 조회 동의 여부 입니다.
    var inquiry_agree_yn        : String?
    /// 닉네임 정보 입니다.
    var nickname                : String?
    /// 유저 레벨 정보 입니다.
    var user_level              : Int?
    /// OK포인트 정보 입니다.
    var user_point              : Int?
    /// 어번달 결제 건수 입니다.
    var current_month_pay_cnt   : Int?
    /// 어번달 결제 정보 입니다.
    var current_month_pay_amt   : Int?
    /// 어번달 적립 정보 입니다.
    var current_month_save_amt  : Int?
    /// OK머니 잔액 정보 입니다.
    var balance                 : Int?
    /// 추천인 코드 정보 입니다.
    var recomm_code             : String?
    /// 오픈 뱅킹 오픈 일시 입니다.
    var openbank_open_dt        : String?
    /// 제휴사 예치금 입니다.
    var inv_balance             : Int?
    /// 투자 성향 분석 결과 입니다.
    var simul_nm                : String?
    /// 출금 동의 여부입니다.
    var transfer_agree_yn       : String?
    /// 연결된 은행명 입니다.
    var bank_nm                 : String?
    /// 사용자 일련번호 입니다.
    var user_seq_no             : String?
    /// 회원 사진 URL 정보입니다.
    var user_img_url            : String?
    /// 제휴사 예치금 정보들 입니다.
    var inv_balance_list        : [inv_balance_list]?
    /// 유저 넘버 입니다.
    var user_no                 : String?
    /// 포인트 거래내역 입니다.
    var point_trans_list        : [point_trans_list]?
    /// 가입 날짜 정보 입니다.
    var join_dt                 : String?
    /// 핀테크 이용 번호 입니다.
    var fintech_use_num         : String?
    /// 수정 날짜 정보입니다.
    var mod_dt                  : String?
    /// 거래내역 정보입니다.
    var acc_trans_list          : [acc_trans_list]?
    /// 오픈뱅킹 사용여부 입니다.
    var openbank                : Bool?
    /// NFT 보유 카운트 입니다.
    var own_nft_cnt             : Int?
    /// NFT 아이디 정보 입니다.
    var nft_id                  : String?
}


/**
 제휴사 예치금 정보 데이터 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
struct inv_balance_list: Codable
{
    /// 제휴사 코드 정보입니다.
    var comp_cd : String?
    /// 제휴사 네임 정보 입니다.
    var comp_nm : String?
    /// 제휴사 금액 정보입니다.
    var comp_amt : String?
}


/**
 포인트 거래내역 데이터 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
struct point_trans_list: Codable
{
    /// 거래 일자 정보 입니다.
    var _tran_dt     : String? { get { return  NC.S(tran_dt) } }
    /// 거래 결과 정보입니다.
    var _tran_stat   : String? { get { return  NC.S(tran_stat) } }
    /// 거래 포인트 정보입니다.
    var _tran_point  : Int? { get { return  NC.I(tran_point) } }
    /// 거래내역 정보입니다.
    var _note_cd     : String? { get { return  NC.S(note_cd) } }
    /// 거래시간 정보입니다.
    var _tran_tm     : String? { get { return  NC.S(tran_tm) } }
    /// 등록시간 정보입니다.
    var _reg_tm      : String? { get { return  NC.S(reg_tm) } }
    /// 등록자 ID 정보입니다.
    var _reg_id      : String? { get { return  NC.S(reg_id) } }
    /// 고객번호 정보입니다.
    var _user_no     : String? { get { return  NC.S(user_no) } }
    /// 현재포인트 정보입니다.
    var _cur_point   : Int? { get { return  NC.I(cur_point) } }
    /// 거래구분 정보입니다.
    var _tran_kn     : String? { get { return  NC.S(tran_kn) } }
    /// 수신자넘버?? 정보입니다.
    var _recv_nm     : String? { get { return  NC.S(recv_nm) } }
    /// 등록일자 정보입니다.
    var _reg_dt      : String? { get { return  NC.S(reg_dt) } }
    /// 거래구분명 입니다.
    var _tran_kn_nm  : String? { get { return  NC.S(tran_kn_nm) } }
    /// 포인트 구분 정보입니다.
    var _point_kn    : String? { get { return  NC.S(point_kn) } }
    
    /// 거래 일자 정보 입니다.
    var tran_dt     : String?
    /// 거래 결과 정보입니다.
    var tran_stat   : String?
    /// 거래 포인트 정보입니다.
    var tran_point  : Int?
    /// 거래내역 정보입니다.
    var note_cd     : String?
    /// 거래시간 정보입니다.
    var tran_tm     : String?
    /// 등록시간 정보입니다.
    var reg_tm      : String?
    /// 등록자 ID 정보입니다.
    var reg_id      : String?
    /// 고객번호 정보입니다.
    var user_no     : String?
    /// 현재포인트 정보입니다.
    var cur_point   : Int?
    /// 거래구분 정보입니다.
    var tran_kn     : String?
    /// 수신자넘버?? 정보입니다.
    var recv_nm     : String?
    /// 등록일자 정보입니다.
    var reg_dt      : String?
    /// 거래구분명 입니다.
    var tran_kn_nm  : String?
    /// 포인트 구분 정보입니다.
    var point_kn    : String?
}


/**
 거래내역 데이터 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.21
*/
struct acc_trans_list: Codable
{
    /// 거래 넘버 정보입니다.
    var _seq_no      : Int? { get { return  NC.I(seq_no) } }
    /// 거래일자 정보입니다.
    var _tran_dt     : String? { get { return  NC.S(tran_dt) } }
    /// ???
    var _note        : String? { get { return  NC.S(note) } }
    /// 거래구분 정보입니다.
    var _tran_kn     : String? { get { return  NC.S(tran_kn) } }
    /// 거래결과 정보입니다.
    var _tran_stat   : String? { get { return  NC.S(tran_stat) } }
    /// ???
    var _class_nm    : String? { get { return  NC.S(class_nm) } }
    /// 잔액 정보입니다.
    var _balance     : Int? { get { return  NC.I(balance) } }
    /// 거래구분 명입니다.
    var _tran_kn_nm  : String? { get { return  NC.S(tran_kn_nm) } }
    /// 거래시간 정보입니다.
    var _tran_tm     : String? { get { return  NC.S(tran_tm) } }
    /// 거래금액 정보입니다.
    var _tran_amt    : Int? { get { return  NC.I(tran_amt) } }
    /// 인증토큰 정보입니다.
    var _token       : String? { get { return  NC.S(token) } }
    
    
    /// 거래 넘버 정보입니다.
    var seq_no      : Int?
    /// 거래일자 정보입니다.
    var tran_dt     : String?
    /// ???
    var note        : String?
    /// 거래구분 정보입니다.
    var tran_kn     : String?
    /// 거래결과 정보입니다.
    var tran_stat   : String?
    /// ???
    var class_nm    : String?
    /// 잔액 정보입니다.
    var balance     : Int?
    /// 거래구분 명입니다.
    var tran_kn_nm  : String?
    /// 거래시간 정보입니다.
    var tran_tm     : String?
    /// 거래금액 정보입니다.
    var tran_amt    : Int?
    /// 인증토큰 정보입니다.
    var token       : String?
    
}

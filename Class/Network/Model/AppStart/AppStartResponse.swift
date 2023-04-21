//
//  AppStartResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/27.
//

import Foundation


/**
 앱 시작시 기본 정보를 받습니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.27
*/
struct AppStartResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd   : String?
    /// 세부 응답메세지 입니다.
    var result_msg  : String?
    /// 세부 응답코드 입니다.
    var code        : String?
    /// 세부 응답메세지 입니다.
    var msg         : String?
    
    /// 메뉴 데이터 입니다.
    var _data        : menudata?    { get { return data != nil ? data : nil } }
        
    /// 메뉴 데이터 입니다.
    var data        : menudata?    
}


/**
 메뉴 연결할 정보를 받습니다.
 - Description : 메뉴 연결할 정보들을 받습니다
 - Date : 2023.03.27
  ex ) 정보들
   "menu_nm" : "알림",
   "menu_id" : "ALL_003",
   "menu_nm" : "설정",
   "menu_id" : "ALL_004",
   "menu_nm" : "내정보관리",
   "menu_id" : "ALL_005",
   "menu_nm" : "뱃지 획득 방법",
   "menu_id" : "ALL_007",
   "menu_nm" : "친구추천",
   "menu_id" : "ALL_012",
   "menu_nm" : "공지사항",
   "menu_id" : "ALL_013",
   "menu_nm" : "이벤트",
   "menu_id" : "ALL_015",
   "menu_nm" : "포인트안내",
   "menu_id" : "ALL_017",
   "menu_nm" : "FAQ",
   "menu_id" : "ALL_018",
   "menu_nm" : "1:1 문의",
   "menu_id" : "ALL_019",
   "menu_nm" : "투자성향분석",
   "menu_id" : "INV_014_01",
   "menu_nm" : "ID변경",
   "menu_id" : "LOG_004",
   "menu_nm" : "비밀번호 찾기",
   "menu_id" : "LOG_006",
   "menu_nm" : "90일비밀번호변경",
   "menu_id" : "LOG_028",
   "menu_nm" : "메인",
   "menu_id" : "MAN_001",
   "menu_nm" : "간편투자메인",
   "menu_id" : "MAN_002_1",
   "menu_nm" : "지갑메인",
   "menu_id" : "MAN_002_2",
   "menu_nm" : "리얼투자정보메인",
   "menu_id" : "MAN_002_3",
   "menu_nm" : "회원가입",
   "menu_id" : "MEM_000",
   "menu_nm" : "기프티콘",
   "menu_id" : "MYP_027",
 }
 */
struct menudata : Codable
{
    /// 메뉴 리스트 정보를 받습니다.
    var _menu_list          : [menu_list]? { get { menu_list != nil ? menu_list : [] } }
    /// 버전 정보를 받습니다.
    var _versionInfo        : versionInfo? { get { return versionInfo != nil ? versionInfo : nil } }
    
    /// 메뉴 리스트 정보를 받습니다.
    var menu_list          : [menu_list]?
    /// 버전 정보를 받습니다.
    var versionInfo        : versionInfo?
}

/**
 메뉴 상세 정보를 받습니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.27
*/
struct menu_list : Codable {
    /// 로그인 체크 여부 입니다.
    var _login_check : String?   { get { return NC.S(login_check) } }
    /// 타이틀 명 입니다.
    var _menu_nm     : String?   { get { return NC.S(menu_nm) } }
    /// 해당 ID 입니다.
    var _menu_id     : String?   { get { return NC.S(menu_id) } }
    /// 연결할 URL 정보 입니다.
    var _url         : String?   { get { return NC.S(url) } }
    
    
    /// 로그인 체크 여부 입니다.
    var login_check : String?
    /// 타이틀 명 입니다.
    var menu_nm     : String?
    /// 해당 ID 입니다.
    var menu_id     : String?
    /// 연결할 URL 정보 입니다.
    var url         : String?
}


/**
 앱 시작시 버전 정보를 받습니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.27
*/
struct versionInfo :Codable
{
    /// 버전 정보 입니다.
    var _version : String?              { get { return NC.S(version) } }
    /// 팝업 안내 문구 입니다.
    var _popup_msg : String?            { get { return NC.S(popup_msg) } }
    /// 강제 업데이트 여부를 받습니다.
    var _compulsion_update : String?    { get { return NC.S(compulsion_update) } }
    /// Apple Store 마켓 URL 정보 입니다.
    var _market_url : String?           { get { return NC.S(market_url) } }
    
    /// 버전 정보 입니다.
    var version : String?
    /// 팝업 안내 문구 입니다.
    var popup_msg : String?
    /// 강제 업데이트 여부를 받습니다.
    var compulsion_update : String?
    /// Apple Store 마켓 URL 정보 입니다.
    var market_url : String?
}


//
//  AppStartResponse.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/27.
//

import Foundation


/**
 앱 시작시 기본 정보를 받습니다. ( J.D.H VER : 2.0.2 )
 - Date: 2023.03.27
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
 메뉴 연결할 정보를 받습니다. ( J.D.H VER : 2.0.2 )
 - Description : 메뉴 연결할 정보들을 받습니다
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
 - Date: 2023.03.27
 }
 */
struct menudata : Codable
{
    /// 메뉴 리스트 정보를 받습니다.
    var _menu_list          : [menu_list]? { get { menu_list != nil ? menu_list : [] } }
    /// 버전 정보를 받습니다.
    var _versionInfo        : versionInfo? { get { return versionInfo != nil ? versionInfo : nil } }
    /// 이벤트 정보를 받습니다.
    var _eventInfo          : [eventInfo]? { get { return eventInfo != nil ? eventInfo : [] } }
    /// 세션 타임 정보 입니다.
    var _sessionExpireTime  : Int?     { get { return NC.I(sessionExpireTime) == 0 ? 60*10 : NC.I(sessionExpireTime) } }
    
    
    /// 메뉴 리스트 정보를 받습니다.
    var menu_list          : [menu_list]?
    /// 버전 정보를 받습니다.
    var versionInfo        : versionInfo?
    /// 이벤트 정보를 받습니다.
    var eventInfo          : [eventInfo]?
    /// 세션 타임 정보 입니다.
    var sessionExpireTime  : Int?
}




/**
 메뉴 상세 정보를 받습니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.27
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
 앱 시작시 버전 정보를 받습니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.27
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


/**
 앱 시작시 이벤트 정보를 받습니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.27
*/
struct eventInfo :Codable
{
    /// 타입 넘버 입니다.
    var _ord : String?       { get { return NC.S(ord) } }
    /// 내용 입니다.
    var _note : String?      { get { return NC.S(note) } }
    /// 이벤트 아이디 입니다.
    var _event_id : Int?     { get { return NC.I(event_id) } }
    /// 이미지 URL 입니다.
    var _img_url : String?   { get { return NC.S(img_url) } }
    /// 링크 URL 입니다. ( popup_kn 타입 3인 경우 예/아니오 버튼 선택 정보를 url 같이 넘겨주는 형태로 사용, "예 : agreeFlag=Y " )
    var _link_url : String?  { get { return NC.S(link_url) } }
    /// 타이틀 정보 입니다.
    var _title : String?     { get { return NC.S(title) } }
    /// 팝업 타입 입니다. ( 1 : 시스템 공지, 2 : 이벤트, 3 : 확인/취소 버튼 )
    var _popup_kn : String?  { get { return NC.S(popup_kn) } }
    /// 이벤트 유지 날짜 정보 입니다.
    var _post_ed_dt: String? { get { return NC.S(post_ed_dt) } }
    
    
    
    /// 타입 넘버 입니다.
    var ord : String?
    /// 내용 입니다.
    var note : String?
    /// 이벤트 아이디 입니다.
    var event_id : Int?
    /// 이미지 URL 입니다.
    var img_url : String?
    /// 링크 URL 입니다. ( popup_kn 타입 3인 경우 예/아니오 버튼 선택 정보를 url 같이 넘겨주는 형태로 사용, "예 : agreeFlag=Y " )
    var link_url : String?
    /// 타이틀 정보 입니다.
    var title : String?
    /// 팝업 타입 입니다. ( 1 : 시스템 공지, 2 : 하단 이벤트, 3/4 : 중앙 마케팅 동의 확인/취소 버튼,  )
    var popup_kn : String?
    /// 이벤트 유지 날짜 정보 입니다.
    var post_ed_dt: String?
}

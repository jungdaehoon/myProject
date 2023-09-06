/**
 제로페이 간편결제 약관동의 요청 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.07.05
*/
struct ZeroPayTermsAgreeResponse: BaseResponse {
    /// 세부 응답코드 입니다.
    var result_cd           : String?
    /// 세부 응답메세지 입니다.
    var result_msg          : String?
    /// 세부 응답코드 입니다.
    var code                : String?
    /// 세부 응답메세지 입니다.
    var msg                 : String?
        
    /// 약관 동의 요청 여부 입니다.
    var _data        : Bool? { get { return  NC.B(data) } }
    /// 약관 동의 요청 여부 입니다.
    var data        : Bool?
}



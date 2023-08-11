//
//  BaseViewModel.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import Foundation
import AppTrackingTransparency
import FirebaseMessaging
import SystemConfiguration
import Combine
import Photos
import Contacts
import AdSupport
import GoogleAnalytics
import Firebase
import FirebaseMessaging
import WebKit


/**
 앱실드 데이터를 가집니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.27
*/
struct AppShield  {
    /// 세션 아이디 입니다.
    var session_id   : String?
    /// 토큰 정보 입니다.
    var token        : String?
    /// 애러 여부 체크 입니다.
    var error        : NSError?
    /// 애러 메세지 입니다.
    var error_msg    : String?
}

/**
 앱 활성화 여부를 체크 타입 합니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.05.17
 */
enum IN_APP_START_TYPE : Int {
    /// 푸시로 타입입니다.
    case push_type      = 10
    /// 딥링크 타입 입니다.
    case deeplink_type  = 11
}

/**
 앱 세션 체크 타입 입니다.( J.D.H VER : 2.0.2 )
 - Date: 2023.08.11
 */
enum APP_SESSION_TIME_CHECKING : Int {
    /// 세션 체킹 초기 값입니다.
    case wait           = 0
    /// 세션 체크 시작 합니다.
    case start          = 10
    /// 세션 체크 중 모드로 변경 합니다.
    case ing            = 11
    /// 세션 체크를 타임을 초기화 합니다.
    case refresh        = 12
    /// 세션 체크를 중단 합니다.
    case end            = 13
    /// 세션 체크를 강제 종료 합니다.
    case exit           = 14
}

/**
 앱 시작시 관련 정보 메뉴 리스트 URL 정보 타입 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.03
*/
enum MENU_LIST : String  {
    /// 메인 페이지 URL 입니다.
    case ID_MAIN                = "MAN_001"
    /// 회원가입 페이지 URL 입니다.
    case ID_MEM_INTRO           = "MEM_000"
    /// 간편투자메인 페이지 URL 입니다.
    case ID_INVEST              = "MAN_002_1"
    /// 지갑메인 페이지 URL 입니다.
    case ID_WALLET              = "MAN_002_2"
    /// 리얼투자정보메인 페이지 URL 입니다.
    case ID_COMMUNITY           = "MAN_002_3"
    /// 알림 페이지 URL 입니다.
    case ID_ALARM               = "ALL_003"
    /// 설정 페이지 URL 입니다.
    case ID_SETTING             = "ALL_004"
    /// 내정보 관리 페이지 URL 입니다.
    case ID_MYINFO              = "ALL_005"
    /// 뱃지 획득 방법 페이지 URL 입니다.
    case ID_BADGEINFO           = "ALL_007"
    /// 공지사항 페이지 URL 입니다.
    case ID_NOTICE              = "ALL_013"
    /// 이벤트 페이지 URL 입니다.
    case ID_EVENT               = "ALL_015"
    /// 포인트안내 페이지 URL 입니다.
    case ID_POINT               = "ALL_017"
    /// 기프티콘 페이지 URL 입니다.
    case ID_GIFTYCON            = "MYP_027"
    /// FAQ 페이지 URL 입니다.
    case ID_FAQ                 = "ALL_018"
    /// 1:1 문의 페이지 URL 입니다.
    case ID_QNA                 = "ALL_019"
    /// 제로페이 QR 결제 페이지 URL 입니다
    case ID_ZERO_QR             = "ZERO_001"
    /// 제로페이 상품권 페이지 URL 입니다
    case ID_ZERO_GIFT           = "ZERO_002"
    /// 투자 성향분석 페이지 URL 입니다.
    case ID_INV_ANA             = "INV_014_01"
    /// 친구추천 페이지 URL 입니다.
    case ID_RECOMMEND_USER      = "ALL_012"
    /// ID변경 페이지 URL 입니다.
    case ID_LOG_FIND_ID         = "LOG_004"
    /// 비밀번호 찾기 페이지 URL 입니다.
    case ID_LOG_FIND_PW         = "LOG_006"
    /// 90일 비밀번호 찾기 페이지 URL 입니다.
    case ID_LOG_CHANG_PW_90     = "LOG_028" 
    /// 휴먼회원 페이지 URL 입니다.
    case ID_WAKE_SLEEP_USER     = "LOG_029"
}



/**
 기본 베이스 모델 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.15
 */
class BaseViewModel : NSObject {
    private var curCancellable: AnyCancellable?
    var cancellableSet                                      = Set<AnyCancellable>()
    public static let shared            : BaseViewModel     = BaseViewModel()
    /// 로그아웃 여부를 가집니다. ( TabbarViewController:viewDidLoad $reLogin 이벤트 입니다.   )
    @Published public var reLogin       : Bool              = false
    /// 네트워크 채킹 값입니다.  ( TabbarViewController:viewDidLoad $isNetConnected 이벤트 입니다.   )
    @Published var isNetConnected       : IS_CHECKING       = .checking
    /// 딥링크 URL 정보를 가집니다. ( TabbarViewController:viewDidLoad $deepLinkUrl 이벤트 입니다.   )
    @Published public var deepLinkUrl   : String            = ""
    /// 딥링크 정보를 미리 저장하는 정보 입니다. ( 로그인 이후 사용 합니다. )
    public var saveDeepLinkUrl          : String            = ""
    ///  PUSH URL 정보를 가집니다.  ( TabbarViewController:viewDidLoad $pushUrl 이벤트 입니다.   )
    @Published public var pushUrl       : String            = ""
    ///  PUSH 정보를 미리 저장하는 정보 입니다. ( 로그인 이후 사용 합니다. )
    public var savePushUrl              : String            = ""
    /// 앱 시작시 받는 데이터 입니다.
    static var appStartResponse         : AppStartResponse? = AppStartResponse()
    /// 로그인 정보를 받습니다.
    static var loginResponse            : LoginResponse?    = LoginResponse()
    /// 로그인 페이지 디스플레이 중인지를 체크 합니다.
    static var isLoginPageDisplay       : Bool              = false
    /// 안티디버깅 여부를 가집니다.
    static var isAntiDebugging          : Bool              = false
    /// GA 클라이언트 ID 정보 입니다. GA  업데이트시 사용 합니다.
    static var GAClientID               : String            = ""
    /// 앱 실드 데이터를 저장 합니다.
    var appShield                       : AppShield         = AppShield()
    /// 만보게 약관 동의 여부 데이터를 가집니다.
    var PTAgreeResponse                 : PedometerTermsAgreeResponse?
    /// 만보게 약관동의를 넘깁니다.
    var IPTAgreeResponse                : InsertPedometerTermsResponse?
    /// 로그아웃 데이터를 받습니다.
    var logoutResponse                  : LogOutResponse?
    /// FCM 토큰 업로드 입니다.
    var fcmPushResponse                 : FcmPushUpdateResponse?
    /// 만료된 계좌 재인증 데이터를 받습니다.
    var reBankAuthResponse              : ReBankAuthResponse?
    /// App 백그라운드 내려 갈 경우 현 타임을 저장 합니다. 백그라운드에서 앱이 올라오는 시기에는 0 값으로 변경 됩니다.
    static var appBackgroundSaveTimer   : Int    = 0
    /// App 활성화 여부를 판단말 세션 체크 타입 입니다.
    static var isSssionType             : APP_SESSION_TIME_CHECKING = .wait
    
    
    
    
    /**
     상황별 인터페이스를 요청 합니다.( J.D.H VER : 2.0.0 )
     - Description          : Http 네트워크 요청시 공통 지원 메서드 입니다. "errorPopEnabled" 에 따라 공통 오류 코드에 따른 안내 팝업 처리 및 공통 이벤트 처리가 될수 있습니다. 별도 이벤트 처리는 "errorPopEnabled = false"  처리시 별도 이벤트 처리가 가능합니다.
     - Date: 2023.05.23
     - Parameters:
        - showLoading       : 로딩 디스플레이 여부 입니다. ( default = true )
        - appExit           : 예외 사항일 경우 앱 종료로 연결할지 여부 입니다. ( default = false )
        - errorPopEnabled   : 공통 error 팝업을 사용할지 여부 입니다. ( default = true )
        - errorHandler      : ResponseError 헨들러 입니다. ( default = nil )
        - publisher         : 타입별 데이터를 연결 합니다.
        - completion        : 통신 완료처리 후 콜백입니다. (T: BaseResponse)
     - Throws: False
     - Returns:False
     */
    func requst<T: BaseResponse>(showLoading: Bool = true,
                                 appExit : Bool = false,
                                 errorPopEnabled : Bool = true,
                                 errorHandler: ((ResponseError) -> Bool)? = nil,
                                 publisher: () -> AnyPublisher<T, ResponseError>,
                                 completion: ((T) -> Void)? = nil) {
        /// 로딩 디스플레이 여부 입니다.
        if showLoading {
            LoadingView.default.show()
        }
        /// 네트웤 가용가능 여부 체크 합니다.
        BaseViewModel.shared.isNetConnected = .checking
        curCancellable = publisher()
            .handleEvents(receiveOutput: { received in
            }, receiveCancel: {
                Slog("receiveCancel")
                //self?.action = .navigation(.close)
            })
            .sink(receiveCompletion: { [weak self] completion in
                /// 로딩을 종료 합니다.
                if showLoading { LoadingView.default.hide() }
                /// Http Error 공통 팝업을 사용하지 않을 경우 입니다.
                if errorPopEnabled == false {
                    let _ =  errorHandler!(.unknown(""))
                    return
                }
                guard self != nil else { return }
                
                switch completion {
                case .finished:
                    Slog("completion")
                case .failure(let error):
                    // 공통 에러처리
                    if errorHandler?(error) ?? false == false {
                        /// Error 경우 무조건 강제 종료 하는 타입을 받았을 경우 앱을 강제 종료로 합니다.
                        if appExit == true {
                            /// 로그인 요청을 다시 안내하는 팝업을 오픈 합니다.
                            CMAlertView().setAlertView(detailObject: "일시적으로 문제가 발생했습니다.\n잠시 후에 다시 시도하여 주십시오." as AnyObject, cancelText: "확인") { event in
                                exit(0)
                            }
                            //self.action = .alert(COMMON_TIMEOUT_ALERT)
                            return
                        }
                        switch error {
                        case .http(let errorData):
                            Slog("[ NETWORK_ERROR_DATA_HTTP ]\n\(errorData.message)")
                        case .parsing(let errMsg):
                            Slog("[ NETWORK_ERROR_DATA_Parsing ]\n\(errMsg)")
                        case .unknown(let errMsg):
                            let _ =  errorHandler!(.unknown(errMsg))
                            Slog("[ NETWORK_ERROR_DATA_Unknown ]\n\(errMsg)")
                        case .timeout(let errMsg):
                            let _ =  errorHandler!(.timeout(errMsg))
                            Slog("[ NETWORK_ERROR_DATA_Timeout ]\n\(errMsg)")
                        }
                    }
                }
                HttpErrorPop().show()
            }, receiveValue: { value in
                /// 로딩을 종료 합니다.
                if showLoading { LoadingView.default.hide() }
                /// Http Error 공통 팝업을 사용하지 않을 경우 입니다.
                if errorPopEnabled == false
                {
                    completion?(value)
                    return
                }
                let code = value.code == nil ? NC.S(value.result_cd) : NC.S(value.code)
                /// 정상 처리가 아닌 경우 입니다.
                if code != "0000"
                {
                    /// 로그인 필요경우 입니다.
                    if code == "8888"
                    {
                        DispatchQueue.main.async {
                            /// 로그인 요청을 다시 안내하는 팝업을 오픈 합니다.
                            CMAlertView().setAlertView(detailObject: "고객님의 소중한 개인정보 \n보호를 위해  재로그인 부탁드립니다." as AnyObject, cancelText: "확인") { event in
                                /// 로그인 페이지로 이동합니다.
                                BaseViewModel.shared.reLogin = true
                            }
                        }
                        return
                    }
                    /// 기타 오류 사항 입니다.
                    else
                    {
                        if NC.S(value.msg).count != 0
                        {
                            DispatchQueue.main.async {
                                /// 서버 안내 기준 문구를 디스플레이 합니다.
                                CMAlertView().setAlertView(detailObject: NC.S(value.msg) as AnyObject, cancelText: "확인") { event in
                                    completion?(value)
                                }
                            }
                            return
                        }
                    }
                }
                completion?(value)
            })
        curCancellable?.store(in: &cancellableSet)
    }
    
    
    /**
     이미지를 서버에 전송 합니다. ( J.D.H VER : 2.0.0 )
     - Description:
     - Date: 2023.08.04
     - Parameters:
        - image : 서버에 업로드할 이미지 입니다.
        - url : 업로드할 URL 정보 입니다.
        - maxMByte :최대 등록 가능 메가 바이트 단위 입니다. ( default : 10MB )
     - Throws: False
     - Returns:서버로 리턴할 스크립트를 리턴 합니다.  Future<[String:Any]?, Never>
     */
    func request( image : UIImage, url : String, maxByte : Int = (1024*1024) * 10 )  -> Future<[String:Any]?, Never>
    {
        return Future<[String:Any]?, Never> { promise in
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                Slog("Could not get JPEG representation of UIImage", category: .network)
                return
            }
            /// 이미지 데이터 maxByte 이상일 경우 안내 팝업을 오픈후 업로드를 중단 합니다.
            if imageData.count > maxByte
            {
                /// 로그인 요청을 다시 안내하는 팝업을 오픈 합니다.
                CMAlertView().setAlertView(detailObject: "파일 크기가 10MB를 초과하여 등록할 수 없습니다." as AnyObject, cancelText: "확인") { event in
                    promise(.success(nil))
                }
                return
            }
            
            let custItem = SharedDefaults.getKeyChainCustItem()
            LoadingView.default.show(maxTime: 20.0)
            // Multi-part 형태로 보낸다.
            AlamofireAgent.upload( WebPageConstants.baseURL + url, multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData,  withName: "file", fileName: "fileName.jpg", mimeType: "image/jpeg")
                multipartFormData.append(custItem!.user_no!.data(using: .utf8)!, withName: "user_no")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        Slog("uploadProgress : \(progress.fractionCompleted)", category: .network)
                    }
                    _ = upload.log()
                    
                    upload.response(completionHandler: { (defaultData) in
                        if let data =  defaultData.data {
                            let responseData = String(data: data, encoding: .utf8)
                            Slog("upload.response(completionHandler : \(defaultData.response?.statusCode as Any)", category: .network)
                            Slog("upload.response(completionHandler : \(responseData as Any)", category: .network)
                        }
                    })
                    
                    upload.responseJSON { response in
                        LoadingView.default.hide()
                        guard response.result.isSuccess else {
                            Slog("Error while uploading file: \(String(describing: response.result.error))", category: .network)
                            /// 다시 안내하는 팝업을 오픈 합니다.
                            CMAlertView().setAlertView(detailObject: "일시적으로 문제가 발생했습니다.\n잠시 후에 다시 시도하여 주십시오." as AnyObject, cancelText: "확인") { event in
                                /// 스크립트 실패 보내기
                                promise(.success(nil))
                            }
                            return
                        }
                       
                        if let value = response.result.value as? [String:Any] {
                            Slog("uploading file success: \(value as Any)", category: .network)
                            promise(.success(value))
                            return
                        }
                        else
                        {
                            /// 다시 안내하는 팝업을 오픈 합니다.
                            CMAlertView().setAlertView(detailObject: "일시적으로 문제가 발생했습니다.\n잠시 후에 다시 시도하여 주십시오." as AnyObject, cancelText: "확인") { event in
                                /// 스크립트 실패 보내기
                                promise(.success(nil))
                            }
                            return
                        }
                    }
                case .failure(let encodingError):
                    LoadingView.default.hide()
                    Slog(encodingError, category: .network)
                    /// 다시 안내하는 팝업을 오픈 합니다.
                    CMAlertView().setAlertView(detailObject: "일시적으로 문제가 발생했습니다.\n잠시 후에 다시 시도하여 주십시오." as AnyObject, cancelText: "확인") { event in
                        /// 스크립트 실패 보내기
                        promise(.success(nil))
                    }
                    return
                }
            })
        }
    }
    
    
    /**
     앱 시작시 관련 정보를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.03
     - Parameters:False
     - Throws: False
     - Returns:
        홈 소비 정보를 요청 합니다. (AnyPublisher<PedometerTermsAgreeResponse?, ResponseError>)
     */
    func setAppStart() -> AnyPublisher<AppStartResponse?, ResponseError> {
        var parameters  : [String:Any] = [:]
        parameters = ["os_cd"                   : "I",
                      "appshield_session_id"    : NC.S(self.appShield.session_id) ,
                      "appshield_token"         : NC.S(self.appShield.token)]
        let subject             = PassthroughSubject<AppStartResponse?,ResponseError>()
        requst( showLoading : false, errorPopEnabled: false ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 로그아웃 요청 합니다.
            return NetworkManager.requestAppStart(params: parameters)
        } completion: { model in
            BaseViewModel.appStartResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     로그아웃 처리 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.20
     - Parameters:False
     - Throws: False
     - Returns:
        로그아웃 처리 결과를 받습니다. (AnyPublisher<LogOutResponse?, ResponseError>)
     */
    func setLogOut() ->  AnyPublisher<LogOutResponse?, ResponseError> {
        let subject             = PassthroughSubject<LogOutResponse?,ResponseError>()
        /// 자동 로그인 값을 false 변경 합니다.
        let custItem                = SharedDefaults.getKeyChainCustItem()
        custItem!.auto_login        = false
        SharedDefaults.setKeyChainCustItem(custItem!)
        
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 로그아웃 요청 합니다.
            return NetworkManager.requestLogOut()
        } completion: { model in
            /// 로그인 정보를 초기화 합니다.
            BaseViewModel.loginResponse = nil
            BaseViewModel.loginResponse = LoginResponse()
            self.logoutResponse         = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     DeepLink,Push 선택으로 들어 온 경우 데이터 찾아 리턴 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.17
     - Parameters:False
     - Throws: False
     - Returns:
        페이지 이동 할 링크 입니다. (String)
     */
    func getInDataAppStartURL() -> String?
    {
        if BaseViewModel.shared.saveDeepLinkUrl.isValid
        {
            let deepLink = BaseViewModel.shared.saveDeepLinkUrl
            BaseViewModel.shared.saveDeepLinkUrl = ""
            return deepLink
        }
        
        if BaseViewModel.shared.savePushUrl.isValid
        {
            let pushLink = WebPageConstants.baseURL + BaseViewModel.shared.savePushUrl
            BaseViewModel.shared.savePushUrl = ""
            return pushLink
        }
        return ""
    }
    
    
    /**
     앱 활성화 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Description: 세션여부를 체크 하여 세션이 유지 상태인 경우 저장된 PUSH/Deep 링크 정보가 있다면 앱 실행중이 아니였다고 판단하여 앱 비활성으로 false 를 리턴 합니다. 앱 실행중에 세션 체크가 되어 세션이 비정상일 경우 로그아웃을 요청, 로그인 페이지로 이동 합니다.
     - Date: 2023.07.18
     - Parameters:
        - inAppStartType : 앱 활성화 여부를 체크하는 타입 입니다.
     - Throws: False
     - Returns:
        앱 활성화 여부를 리턴 합니다. (Future<Bool, Never>)
     */
    func isAppEnabled( inAppStartType : IN_APP_START_TYPE ) -> Future<Bool, Never> {
        return Future<Bool, Never> { promise in
            /// 로그인 여부를 체크 합니다.
            if BaseViewModel.isLogin()
            {
                /// 로그인 상태에서 세션이 유지되고 있는지를 체크 합니다.
                self.isSessionEnabeld().sink { result in
                    /// 요청 비정상 처리로 세션 유지 실패로 리턴 합니다.
                    promise(.success(false))
                    /// 로그아웃 요청 합니다.
                    BaseViewModel.setLogoutData()
                } receiveValue: { sessionSesponse in
                    /// 앱 활성화 여부를 체크 합니다.
                    var isEnabled = true
                    /// 세션 유지가 정상인지를 체크 합니다.
                    if let response = sessionSesponse,
                       let code     = response.code,
                       code         == "0000"
                    {
                        /// 활성화 여부 타입 입니다.
                        switch inAppStartType
                        {
                            case .push_type:
                                /// 저장된 PUSH 데이터가 있는 경우 앱 비활성화 상태로 판단 합니다.
                                if BaseViewModel.shared.savePushUrl.isValid {
                                    /// 앱 비활성화 타입으로 변경 합니다.
                                    isEnabled = false
                                }
                            case .deeplink_type:
                                /// 저장된 DeepLink 데이터가 있는 경우 앱 비활성화 상태로 판단 합니다.
                                if BaseViewModel.shared.saveDeepLinkUrl.isValid{
                                    /// 앱 비활성화 타입으로 변경 합니다.
                                    isEnabled = false
                                }
                        }
                    }
                    else
                    {
                        /// 앱 비활성화 타입으로 변경 합니다.
                        isEnabled                    = false
                        /// 로그아웃 요청 합니다.
                        BaseViewModel.setLogoutData()
                    }
                    /// 앱 타입을 리턴 합니다.
                    promise(.success(isEnabled))
                }.store(in: &self.cancellableSet)
            }
            else
            {
                /// 비로그인으로 앱 비활성화 타입으로 리턴 합니다.
                promise(.success(false))
            }
        }
    }
    
    
    /**
     앱 세션 활성화 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Description: 세션 여부 체크만 하는 것으로 네트워크 통신 오류시에 공통 오류 팝업 처리 하지 않으며. 세션 실패로 리턴 하도록 합니다.
     - Date: 2023.05.26
     - Parameters:False
     - Throws: False
     - Returns:
        앱 활성화 여부를 리턴 합니다. (AnyPublisher<SessionCheckResponse?, ResponseError>)
     */
    func isSessionEnabeld() -> AnyPublisher<SessionCheckResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<SessionCheckResponse?,ResponseError>()
        requst( showLoading : false, errorPopEnabled: false ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 만보게 약관 동의여부 요청 합니다.
            return NetworkManager.requestSessionCheck()
        } completion: { model in
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    

    /**
     메뉴 활성화 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.02
     - Parameters:
        - menuID : 연동할 URL 정보 타입 ID 값을 넣습니다.
     - Throws: False
     - Returns:
        활성화 여부를 리턴 합니다. (Bool)
     */
    func isAppMenuList( menuID : MENU_LIST ) -> Bool
    {
        if let response = BaseViewModel.appStartResponse,
           let data     = response.data,
           let menulist = data.menu_list
        {
            for info in menulist
            {
                if info.menu_id! == menuID.rawValue
                {
                    return true
                }
            }
        }
        return false
    }
    
    
    /**
     연동할 URL 정보를 가져 옵니다.( J.D.H VER : 2.0.0 )
     - Date: 2023.04.03
     - Parameters:
        - menuID : 연동할 URL 정보 타입 ID 값을 넣습니다.
     - Throws: False
     - Returns:
        연동할 URL 정보르 리턴 합니다. (Future<String, Never>)
     */
    func getAppMenuList( menuID : MENU_LIST ) -> Future<String, Never>
    {
        return Future<String, Never> { promise in
            if let response = BaseViewModel.appStartResponse,
               let data     = response.data,
               let menulist = data.menu_list
            {
                for info in menulist
                {
                    if info.menu_id! == menuID.rawValue
                    {
                        promise(.success( WebPageConstants.baseURL  + info.url! ))
                        return
                    }
                }
            }
            promise(.success(""))
        }
    }
    
    
    /**
     제로페이 간편결제 약관동의 여부 확인 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.05
     - Parameters:False
     - Throws: False
     - Returns:
        약관동의 여부를 리턴 합니다. (AnyPublisher<ZeroPayTermsCheckResponse?, ResponseError>)
     */
    func getZeroPayTermsCheck() -> AnyPublisher<ZeroPayTermsCheckResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<ZeroPayTermsCheckResponse?,ResponseError>()
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 제로페이 약관 동의 여부를 요청 합니다.
            return NetworkManager.requestZeroPayTermsCheck()
        } completion: { model in
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     제로페이 간편결제 약관동의 요청 입니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.05
     - Parameters:False
     - Throws: False
     - Returns:
        약관동의 요청 정상처리 여부를 받습니다. (AnyPublisher<ZeroPayTermsAgreeResponse?, ResponseError>)
     */
    func setZeroPayTermsAgree() -> AnyPublisher<ZeroPayTermsAgreeResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<ZeroPayTermsAgreeResponse?,ResponseError>()
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 만보게 약관 동의를 요청 합니다.
            return NetworkManager.requestZeroPayTermsAgree()
        } completion: { model in
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     만보기 약관 동의 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.09
     - Parameters:False
     - Throws: False
     - Returns:
        약관동의 여부를 리턴 합니다. (AnyPublisher<PedometerTermsAgreeResponse?, ResponseError>)
     */
    func getPTTermAgreeCheck() -> AnyPublisher<PedometerTermsAgreeResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<PedometerTermsAgreeResponse?,ResponseError>()
        requst() { error in
            
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 만보게 약관 동의 여부를 요청 합니다.
            return NetworkManager.requestPedometerTermsAgree()
        } completion: { model in
            self.PTAgreeResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     만보기 약관 동의 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.09
     - Parameters:False
     - Throws: False
     - Returns:
        약관동의 요청 정상처리 여부를 받습니다. (AnyPublisher<InsertPedometerTermsResponse?, ResponseError>)
     */
    func setPTTermAgreeCheck() -> AnyPublisher<InsertPedometerTermsResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<InsertPedometerTermsResponse?,ResponseError>()
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 만보게 약관 동의를 요청 합니다.
            return NetworkManager.requestInsertPedometerTerms()
        } completion: { model in
            self.IPTAgreeResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     은행 계좌 재인증 요청 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.21
     - Parameters:False
     - Throws: False
     - Returns:
        은행 계좌 재인증 처리 결과를 받습니다. (AnyPublisher<ReBankAuthResponse?, ResponseError>)
     */
    func setReBankAuth() ->  AnyPublisher<ReBankAuthResponse?, ResponseError> {
        let subject             = PassthroughSubject<ReBankAuthResponse?,ResponseError>()
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 계좌 재인증 요청 합니다.
            return NetworkManager.requestReBankAuth()
        } completion: { model in
            self.reBankAuthResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    /**
     정상 로그인된 정보를 KeyChainCustItem 정보에 세팅 합니다.( J.D.H VER : 2.0.0 )
     - Date: 2023.04.17
     - Parameters:
        - user_hp : 유저 휴대폰 정보를 받습니다.
     - Throws: False
     - Returns:
        정상 저장 여부를 리턴 합니다. (AnyPublisher<Bool?, Never>)
     */
    func setKeyChainCustItem( _ user_hp : String ) -> Future<Bool, Never> {
        return Future<Bool, Never> { promise in
            if let custItem = SharedDefaults.getKeyChainCustItem() {
                if let response = BaseViewModel.loginResponse
                {
                    if let info = response.data
                    {
                        custItem.last_login_time    = info.Last_login_time
                        custItem.token              = info.token
                        custItem.user_no            = info.user_no
                        custItem.user_hp            = user_hp.setLastMasking()!
                        SharedDefaults.setKeyChainCustItem(custItem)
                        promise(.success(true))
                        return
                    }
                }
            }
            promise(.success(false))
        }
    }
    
    
    /**
     FCM TOKEN 정보를 서버에 등록 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.13
     - Parameters:False
     - Throws: False
     - Returns:
        FCM 정상 등로 결과를 받습니다. (AnyPublisher<FcmPushUpdateResponse?, ResponseError>)
     */
    func setFcmTokenRegister() ->  AnyPublisher<FcmPushUpdateResponse?, ResponseError> {
        let subject             = PassthroughSubject<FcmPushUpdateResponse?,ResponseError>()
        if let custItem = SharedDefaults.getKeyChainCustItem()
        {
            /// FCM 토큰 정보를 체크 합니다.
            if let fcm_token = custItem.fcm_token
            {
                /// 파라미터  user_no : 고객번호, push_token : FCM 토큰 파라미터를 생성 합니다.
                let parameters  = ["user_no" : NC.S(custItem.user_no) , "push_token" : fcm_token]
                requst( showLoading : false, errorPopEnabled: false ) { error in
                    subject.send(completion: .failure(error))
                    return false
                } publisher: {
                    /// 로그인 요청 합니다.
                    return NetworkManager.requestFcmUpdate(params: parameters)
                } completion: { model in
                    self.fcmPushResponse = model
                    // 앱 인터페이스 정상처리 여부를 넘깁니다.
                    subject.send(model)
                }
            }
            else
            {
                subject.send(completion: .failure(.unknown("")))
            }
        }
        else
        {
            subject.send(completion: .failure(.unknown("")))
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     앱 실드 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.27
     - Throws: False
     - Returns:
        앱 실드 정상 여부를 체크 합니다. (Future<AppShield, Never>)
     */
    func getAppShield() -> Future<AppShield, Never>
    {
        return Future<AppShield, Never> { promise in
            /// 앱 실드 여부 체크 입니다.
            AppshieldManager.sharedInstance.authApp { result in                
                switch result {
                case let .success(data):
                    // handle success
                    self.appShield.session_id    = String(data.sessionId())
                    self.appShield.token         = String(data.token())
                    self.appShield.error         = nil
                    self.appShield.error_msg     = ""
                    promise(.success(self.appShield))
                    return
                case let .failure(error):
                    self.appShield.error         = error
                    if (error).code / 100 == 11 {
                        self.appShield.error_msg = "네트워크에 연결할 수 없습니다. 잠시 후 다시 시도해주세요."
                    } else {
                        self.appShield.error_msg = "무결성 검증에 실패했습니다."
                    }
                    promise(.success(self.appShield))
                    return
                }
            }
        }
    }
    
    
    /**
     앱 카메라 접근 허용 여부를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.29
     - Throws: False
     - Returns:
        앱 카메라 접근 여부 값을 리턴 합니다. (Future<Bool, Never>)
     */
    func isCameraAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// 시스템 팝업 여부 체크 입니다.
            BecomeActiveView.systemPopupEnabled = true
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                DispatchQueue.main.async {
                    /// 시스템 팝업 여부 체크 입니다.
                    BecomeActiveView.systemPopupEnabled = false
                    promise(.success(granted))
                }
            })
        }
    }
    
    
    /**
     앱 이미지 저장소 접근 허용 여부를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.20
     - Throws: False
     - Returns:
        앱 이미지 저장소 접근 여부 값을 리턴 합니다. (Future<Bool, Never>)
     */
    func isPhotoSaveAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// 시스템 팝업 여부 체크 입니다.
            BecomeActiveView.systemPopupEnabled = true
            PHPhotoLibrary.requestAuthorization( { status in
                var check : Bool = false
                switch status{
                case .authorized:
                    check = true
                    break
                case .denied:
                    check = false
                    break
                case .restricted, .notDetermined:
                    check = false
                    break
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    /// 시스템 팝업 여부 체크 입니다.
                    BecomeActiveView.systemPopupEnabled = false
                    promise(.success(check))
                }
            })
        }
    }
    
    
    /**
     연락처 접근 허용 여부를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.29
     - Throws: False
     - Returns:
        앱 연락처 접근 여부 값을 리턴 합니다. (Future<Bool, Never>)
     */
    func isContactAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// 시스템 팝업 여부 체크 입니다.
            BecomeActiveView.systemPopupEnabled = true
            CNContactStore().requestAccess(for: .contacts, completionHandler: {
                success, error in
                DispatchQueue.main.async {
                    /// 시스템 팝업 여부 체크 입니다.
                    BecomeActiveView.systemPopupEnabled = false
                    promise(.success(success))
                }
            })
        }
    }
    
    
    /**
     앱 PUSH 사용 허용 여부를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.29
     - Throws: False
     - Returns:
        PUSH 사용 인증 여부 값을 리탄합니다. (Future<Bool, Never>)
     */
    func isAPNSAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// 시스템 팝업 여부 체크 입니다.
            BecomeActiveView.systemPopupEnabled = true
            /// PUSH 사용 할지 인증을 요청 합니다.
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { bool,Error in
                DispatchQueue.main.async {
                    /// 시스템 팝업 여부 체크 입니다.
                    BecomeActiveView.systemPopupEnabled = false
                    UIApplication.shared.registerForRemoteNotifications()
                    promise(.success(bool))
                }
            })
        }
    }
    
    
    /**
     앱 추적 (IDFA) 허용 여부를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.20
     - Throws: False
     - Returns:
        앱 추적 허용 승인 여부 값을 리턴 합니다. (Future<Bool, Never>)
     */
    func isTrackingAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// iOS 14 버전 이후부터  앱 추적 접근 허용 여부를 요청 합니다.
            if #available(iOS 14, *)
            {
                /// 시스템 팝업 여부 체크 입니다.
                BecomeActiveView.systemPopupEnabled = true
                /// 앱 추적 (IDFA) 허용 여부를 요청 합니다
                /// 난독화 안할떄 버젼.
                ATTrackingManager.requestTrackingAuthorization { status in
                    /// 시스템 팝업 여부 체크 입니다.
                    BecomeActiveView.systemPopupEnabled = false
                    /// 승인 되었습니다.
                    if status == .authorized
                    {
                        DispatchQueue.main.async {
                            promise(.success(true))
                        }
                    }
                    /// 요청이 거부 되었습니다.
                    else
                    {
                        DispatchQueue.main.async {
                            promise(.success(false))
                        }
                    }
                }
            }
            else
            {
                DispatchQueue.main.async {
                    promise(.success(true))
                }
            }
        }
    }
    
    
    /**
     Deeplink URL 정보를 체크하여 이동 할 URL 정보를 리턴 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.29
     - Throws: False
     - Returns:
        딥링크 진입 할 URL 정보를 받습니다. (Future<String, Never>)
     */
    func getDeepLink( deelLinkUrl url: URL ) -> Future<String, Never>
    {
        return Future<String, Never> { promise in
            switch url.scheme {
                /// 딥링크 타입 입니다.
            case "cereal":
                /// 호스트 정보가 movepage 인지를 체크 합니다.
                if NC.S(url.host) == "movepage"
                {
                    /// 이동할 링크 정보를 받습니다.
                    if let linkUrl = url.getQueries["url"],
                       linkUrl.isValid
                    {
                        /// Deeplink 데이터를 넘깁니다.
                        promise(.success(linkUrl))
                    }
                }
            default: break
            }
        }
    }
    
    
    /**
     URL 에서 받은 정보르 파라미터로 세팅하여 리턴 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.06.08
     - Parameters:
        - url : URL 정보 입니다.
     - Throws: False
     - Returns:
        파라미터 정보를 정리하여 리턴 합니다. (Future <[String : Any]?,Naver>)
     */
    func getURLParams( url : URL ) -> Future<[String : Any]?, Never>
    {
        return Future<[String : Any]?, Never> { promise in
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let _ = components.queryItems else {
                Slog("Failed to parse query items")
                promise(.success(nil))
                return
            }
            promise(.success(url.getQueries))
        }
    }
    
    
    /**
     제로페이에서 GET 방식 URL 접근시 파라미터 정보를 정리하여 받아옵니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.06.08
     - Parameters:
        - url : URL 정보 입니다.
     - Throws: False
     - Returns:
        파라미터 정보를 정리하여 리턴 합니다. (Future <[String : Any]?,Naver>)
     */
    func getZeroPayURLParams( url : URL ) -> Future<[String : Any]?, Never>
    {
        return Future<[String : Any]?, Never> { promise in
            let queryString = url.absoluteString
            let param = queryString.components(separatedBy: "?")           
            promise(.success( ["param" : param[1]]))
        }
    }
    
    
    /**
     GET 방식 URL 파라미터를 설정하여 리턴 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.19
     - Parameters:
        - mainUrl : 메인 URL 정보 입니다.
        - params : GET 방식으로 연결할 파라미터 정보 입니다.
     - Throws: False
     - Returns:
        파라미터 연결된 GET 방식 URL 정보를 넘깁니다. (Future<String,Never>)
     */
    func getURLGetType( mainUrl : String, params : [String : Any] = [:]) -> Future<String, Never>
    {
        return Future<String, Never> { promise in
            var getParams = "?"
            for (key,value) in params
            {
                getParams += "\(key)=\(value)&"
            }
            getParams.remove(at: getParams.index(before: getParams.endIndex))
            promise(.success(mainUrl + getParams))
        }
    }
    
    
    func okPayRemoveAllCookies(){
        WKWebView.removeCookies()
    }
    
    /**
     Session 유지를 위해 쿠키 업데이트 정보를 리턴 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.25
     - Parameters:
        - cookies : 업데이트할 쿠키 정보입니다.
     - Throws: False
     - Returns:
        업데이트 된 정보를 넘깁니다. (Future<String, Never>)
     */
    func getJSCookiesString( cookies : [HTTPCookie]? ) -> Future<String, Never>
    {
        return Future<String, Never> { promise in
            var source = String()
            cookies?.forEach { cookie in
                Slog("cookie.name : \(cookie.name)")
                Slog("cookie.value : \(cookie.value)")
                Slog("cookie.path : \(cookie.path)")
                Slog("cookie.domain : \(cookie.domain)")
                source.append("document.cookie = '")
                source.append("\(cookie.name)=\(cookie.value); path=\(cookie.path); domain=\(cookie.domain);'\n")
            }
            promise(.success(source))
        }
    }
    
    
    /**
     FCM PUSH 수신을 등록합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.06
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setFcmRegister( appDelegate : AppDelegate ) {
        /// 앱 PUSH 사용 허용 여부를 요청 합니다.
        self.isAPNSAuthorization().sink { success in
            if success
            {
                DispatchQueue.main.async {
                    Messaging.messaging().delegate              = appDelegate
                    UNUserNotificationCenter.current().delegate = appDelegate
                    Messaging.messaging().token { token, error in
                        if let error = error
                        {
                            Slog("Error fetching FCM registration token: \(error)", category: .push)
                        }
                        else if let token = token
                        {
                            Slog("FCM registration token: \(token)", category: .push)
                            if let custItem = SharedDefaults.getKeyChainCustItem()
                            {
                                custItem.fcm_token = token
                                SharedDefaults.setKeyChainCustItem(custItem)
                            }
                        }
                    }
                }
            }
        }.store(in: &self.cancellableSet)
    }
    
    
    /**
     키체인 사용 정보를 체크 합니다. ( 신규설치하거나, 앱 삭제 후 설치 . 기존 키체인 내용을 삭제 ) ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.06
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setKeyChainEnabled(){
        if SharedDefaults.default.isKeychainRead == false
        {
            if let _ = SharedDefaults.getKeyChainCustItem()
            {
                /// 기존에 저장된 키체인 정보를 전부 삭제 합니다.
                SharedDefaults.default.keychainWrapper.removeAllKeys()
                /// 키체인 사용여부를 활성화 합니다.
                SharedDefaults.default.isKeychainRead = true
                /// 신규 정보를 세팅 합니다.
                SharedDefaults.setKeyChainCustItem(KeyChainCustItem())
            }
        }
    }
    
    
    /**
     GA 트레킹을 디버깅 활성화 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.20
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setFIRDebugEnabled(){
        /// GA 디버킹 여부 체크 입니다.
        if APP_GA_DEBUG_ENABLED
        {
            var debugMode = ProcessInfo.processInfo.arguments
            debugMode.append("-FIRDebugEnabled")
            ProcessInfo.processInfo.setValue(debugMode, forKey: "arguments")
            
        }
    }
    
    
    /**
     GA 트레킹을 활성화 합니다. ( J.D.H VER : 2.0.0 )     
     - Date: 2023.07.20
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setGATracker()
    {
        guard let gai = GAI.sharedInstance() else {
            Slog("Google Analytics not configured correctly", category: .gaevent)
            assert(false, "Google Analytics not configured correctly")
            return
        }
        gai.logger.logLevel         = GAILogLevel.verbose
        gai.dispatchInterval        = 1
        gai.tracker(withTrackingId: APP_GA_TRACKING_KEY)
        BaseViewModel.GAClientID    = gai.defaultTracker.get(kGAIClientId)
    }
    
    
    /**
     GA 트레킹을 활성화 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.20
     - Parameters:
        - eventName : 이벤트 명 입니다.
        - parameters : 이벤트 파라미터 정보들 입니다.
     - Throws: False
     - Returns:False
     */
    static func setGAEvent( eventName : String = "", parameters : [String:Any]? ){
        Slog("setGAEvent eventName : \(eventName)", category: .gaevent)
        if let params = parameters {
            Slog("setGAEvent parameters : \(params)", category: .gaevent)
            //Analytics.logEvent(eventName, parameters:params)
        }
        else
        {
            //Analytics.logEvent(eventName, parameters:["":""])
        }
    }
    
    
    /**
     탈옥 방지 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.06
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setSecureCheck() {
        /// 취약점 점검인 경우 입니다.
        if APP_INSPECTION { return }
        if let secuManager = IxSecureManager.shared() {
            secuManager.initLicense("AB441C0C1755")
            secuManager.start()
            if secuManager.check() {
                Slog("Problem")
                exit(0)
            }else {
                Slog("Normal")
            }
        }
    }
    
    
    /**
     안티디버깅 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.04
     - Parameters:Fasle
     - Throws: False
     - Returns:
        디버깅접근 여부를 체크하여 리턴 합니다.
     */
    private func isDebugger() -> Bool {
        if getppid() != 1 { return true }
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var info: kinfo_proc = kinfo_proc()
        var info_size = MemoryLayout<kinfo_proc>.size

        let success = name.withUnsafeMutableBytes { (nameBytePtr: UnsafeMutableRawBufferPointer) -> Bool in
            guard let nameBytesBlindMemory = nameBytePtr.bindMemory(to: Int32.self).baseAddress else { return false }
            return -1 != sysctl(nameBytesBlindMemory, 4, &info, &info_size, nil, 0)
        }
        return (success && (info.kp_proc.p_flag & P_TRACED) != 0) ? true : false
    }

    
    /**
     안티디버깅 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Description: 안티디버깅 접근 여부를 앱 사용하는 동안 체크하며 외부 디버깅 접근이 체크되면 안내 팝업 오픈후 강제 종료 됩니다.
     - Date: 2023.07.04
     - Parameters:Fasle
     - Throws: False
     - DispatchQueue : True
     - Returns:Fasle
     */
    func setAntiDebuggingChecking(){
        /// 안티디버깅 여부를 체크 합니다.
        if APP_ANTI_DEBUG == false { return }
        DispatchQueue.global(qos: .background).async {
            while(true)
            {
                Thread.sleep(forTimeInterval: 0.5)
                if self.isDebugger()
                {
                    BaseViewModel.isAntiDebugging = true
                    break
                }
            }
            DispatchQueue.main.async {
                /// 앱 실드 비정상 처리 안내 팝업 입니다.
                CMAlertView().setAlertView(detailObject: "안티 디버깅이 체크되어 앱을 강제 종료 합니다." as AnyObject, cancelText: "확인") { event in
                    exit(0)
                }
            }
        }
    }
    
    
    /**
     앱 활성화 유지 가능 타입을 체크  합니다. ( J.D.H VER : 2.0.2 )
     - Description: 앱이 활성화 된 상태로 계속 사용중인 경우에만 체크 되도록 합니다. 백그라운드로 앱이 내려 간다면 "appBackgroundSaveTimer" 값이 0보다 크게  설정 되며 세션 체크 값은 "exit" 로 모드가 변경 됩니다. "exit" 모드는 세션 체크를 강제 종료 합니다.
     - Date: 2023.08.11
     - Parameters:Fasle
     - Throws: False
     - DispatchQueue : True
     - Returns:Fasle
     */
    func isAppSessionEnabled(){
        /// 세션 활성화 여부를 체크 중인 경우는 추가 체크를 요청하지 않습니다.
        if BaseViewModel.isSssionType == .start,
           BaseViewModel.isSssionType == .ing { return }
        /// 세션 체크를 시작 합니다.
        BaseViewModel.isSssionType = .start
        DispatchQueue.global(qos: .background).async {
            var enabledCtn = 0
            while(true)
            {
                Thread.sleep(forTimeInterval: 1.0)
                /// 세션 체크를 강제 종료 합니다.
                if BaseViewModel.isSssionType == .exit { break }
                /// 세션 체크 여부를 초기화 모드가 올경우 enabledCtn 값을 0 으로 초기화 합니다.
                if BaseViewModel.isSssionType == .refresh { enabledCtn = 0}
                /// 최대 세션 타임 경우 세션 체크를 중단 합니다.
                if enabledCtn > APP_ING_SESSION_MAX_TIME
                {
                    /// 세션 체크 여부를 .end 모드로 변경 합니다.
                    BaseViewModel.isSssionType = .end
                    break
                }
                /// 세션 유지 중 값으로 변경 합니다.
                else { BaseViewModel.isSssionType = .ing }
                enabledCtn += 1
            }
            
            DispatchQueue.main.async {
                /// 앱이 백그라운드로 내려 갔다면 0 값이 아니므로 체크 하지 않도록 합니다.
                if BaseViewModel.appBackgroundSaveTimer == 0
                {
                    BaseViewModel.setLogoutData()
                }
            }
        }
    }
    
    
    /**
     네트워크 사용 가능 여부를 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.21
     - Parameters:Fasle
     - Throws: False
     - Returns:
     네트워크 사용 가능 정보를 리턴 합니다. (IS_CHECKING?)
     */
    static func isNetworkCheck() -> IS_CHECKING?{
        /// 네크워크 정보 구조체를 가져 옵니다.
        var zeroAddress         = sockaddr_in()
        zeroAddress.sin_len     = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family  = sa_family_t(AF_INET)
        
        /// 연결 가능한 호스트 정보를 가져 옵니다.
        guard let reachability  = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else { return .fail }
        
        /// 현재 네트워크 구성을 사용하여 지정된 네트워크 대상에 연결할 수 있는지 확인합니다.
        var flags: SCNetworkReachabilityFlags? = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags!) == false
        {
            return .fail
        }
        
        /// 해당 플레그가 네트워크 연결을 사용 할수 있는지 여부를 체크 합니다.
        let isReachable         = (flags!.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection     = (flags!.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection) ? .connecting : .fail
    }
    
    
    /**
     앱 시작시 안내 팝업 정보를 요청 합니다.( J.D.H VER : 2.0.0 )
     - Date: 2023.07.13
     - Parameters:Fasle
     - Throws: False
     - Returns:
     안내 팝업 정보를 리턴 합니다. ([eventInfo]?)
     */
    static func appStartEventInfos() -> [eventInfo]? {
        /// 앱 시작시 팝업 !!
        if let start      = BaseViewModel.appStartResponse,
           let data       = start._data,
           let eventInfos = data.eventInfo {
            return eventInfos
        }
        return nil
    }
    
    
    /**
     로그인 여부를 리턴 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.13
     - Parameters:Fasle
     - Throws: False
     - Returns:
     로그인 여부를 리턴 합니다. ( Bool )
     */
    static func isLogin() -> Bool {
        /// 로그인 정보가 있는지를 체크합니다.
        if let login   = BaseViewModel.loginResponse,
           let islogin = login.islogin {
            return islogin
        }
        return false
    }
    
    
    /**
     로그아웃 처리 후 데이터를 초기화 하며,  홈 탭 이동 및 로그인 페이지를 디스플레이 합니다.  ( J.D.H VER : 2.0.0 )
     - Description: 로그아웃 인터페이스를 요청하여 로그인중 관련된 정보를 초기화 합니다. 로그아웃 실패 경우에도 하단 탭은 "홈" 탭으로 이동 하며, 로그인 창을 디스플레이 합니다. 해당 경우는 웹에서 callLogin 및 logout 요청 및 네이티브 일부 영역에서 로그아웃을 요청할 때도 동일 하게 사용 됩니다.
     - Date: 2023.07.18
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    static func setLogoutData() {
        /// 현 로그인 페이지 경우에는 로그아웃 처리 하지 않습니다.
        if BaseViewModel.isLoginPageDisplay { return }
        /// 로그아웃을 요청 합니다.
        BaseViewModel.shared.setLogOut().sink(receiveCompletion: { result in
            /// 탭바 연결된 webView 를 전부 초기화 합니다..
            TabBarView.removeTabContrllersWebView()
            /// 재로그인 요청 합니다.
            BaseViewModel.shared.reLogin             = true
        }, receiveValue: { response in
            if response!.code == "0000"
            {
                /// 탭바 연결된 webView 를 전부 초기화 합니다..
                TabBarView.removeTabContrllersWebView()
                /// 재로그인 요청 합니다.
                BaseViewModel.shared.reLogin             = true
            }
        }).store(in: &BaseViewModel.shared.cancellableSet)
    }
    
    
    
}

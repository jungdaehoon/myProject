//
//  BaseViewModel.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import Foundation
import AppTrackingTransparency
import FirebaseMessaging
import Combine
import Photos
import Contacts
import AdSupport


/**
 앱실드 데이터를 가집니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.27
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
 앱 시작시 관련 정보 메뉴 리스트 URL 정보 타입 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.03
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
 기본 베이스 모델 입니다.
 - Date : 2023.03.15
 */
class BaseViewModel : NSObject {
    private var curCancellable: AnyCancellable?
    var cancellableSet                                      = Set<AnyCancellable>()
    public static let shared            : BaseViewModel     = BaseViewModel()
    /// 로그아웃 여부를 가집니다. ( TabbarViewController:viewDidLoad  $logOut 이벤트 입니다.   )
    @Published public var logOut        : Bool              = false
    /// 딥링크 URL 정보를 가집니다. ( TabbarViewController:viewDidLoad  $deepLinkUrl 이벤트 입니다.   )
    @Published public var deepLinkUrl   : String            = ""
    ///  PUSH URL 정보를 가집니다.
    @Published public var pushUrl       : String            = ""
    /// 앱 시작시 받는 데이터 입니다.
    static var appStartResponse         : AppStartResponse? = AppStartResponse()
    /// 로그인 정보를 받습니다.
    static var loginResponse            : LoginResponse?    = LoginResponse()
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
    
    
    
    
    
    /**
     상황별 인터페이스를 요청 합니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.23
     - Parameters:
        - showLoading       : 로딩 디스플레이 여부 입니다.
        - appExit           : 예외 사항일 경우 앱 종료로 연결할지여부 입니다.
        - errorPopEnabled   : 공통 error 팝업을 사용할지 여부 입니다.
        - errorHandler      : ResponseError 헨들러 입니다.
        - publisher         : 타입별 데이터를 연결 합니다.
        - completion        : http 요청할 파라미터 정보 입니다.
     - Throws : False
     - returns :False
     */
    func requst<T: BaseResponse>(showLoading: Bool = false,
                                 appExit : Bool = false,
                                 errorPopEnabled : Bool = true,
                                 errorHandler: ((ResponseError) -> Bool)? = nil,
                                 publisher: () -> AnyPublisher<T, ResponseError>,
                                 completion: ((T) -> Void)? = nil) {
        /// 로딩 디스플레이 여부 입니다.
        if showLoading {
            LoadingView.default.show()
        }
        curCancellable = publisher()
            .handleEvents(receiveOutput: { received in
            }, receiveCancel: {
                Slog("receiveCancel")
                //self?.action = .navigation(.close)
            })
            .sink(receiveCompletion: { [weak self] completion in
                /// Http Error 공통 팝업을 사용하지 않을 경우 입니다.
                if errorPopEnabled == false { return }
                guard self != nil else { return }
                /// 로딩을 종료 합니다.
                if showLoading { LoadingView.default.hide() }
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
            }, receiveValue: { value in
                /// 로딩을 종료 합니다.
                if showLoading { LoadingView.default.hide() }
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
                                /// 로그아웃 여부를 활성화 합니다.
                                BaseViewModel.shared.logOut = true
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
     앱 시작시 관련 정보를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.03
     - Parameters:False
     - Throws : False
     - returns :
     - AnyPublisher<PedometerTermsAgreeResponse?, ResponseError>
     >  PedometerTermsAgreeResponse : 홈 소비 정보를 요청 합니다.
     */
    func setAppStart() -> AnyPublisher<AppStartResponse?, ResponseError> {
        var parameters  : [String:Any] = [:]
        parameters = ["os_cd"                   : "I",
                      "appshield_session_id"    : self.appShield.session_id! ,
                      "appshield_token"         : self.appShield.token!]
        let subject             = PassthroughSubject<AppStartResponse?,ResponseError>()
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 로그아웃 요청 합니다.
            return NetworkManager.requestAppStart(params: parameters)
        } completion: { model in
            BaseViewModel.appStartResponse = model
            //self.appStartResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     메뉴 활성화 여부를 체크 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.02
     - Parameters:
        - menuID : 연동할 URL 정보 타입 ID 값을 넣습니다.
     - Throws : False
     - returns :
        - Bool
            > 활성화 여부를 리턴 합니다.
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
     연동할 URL 정보를 가져 옵니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.03
     - Parameters:
        - menuID : 연동할 URL 정보 타입 ID 값을 넣습니다.
     - Throws : False
     - returns :
     - Future<String, Never>
     >  연동할 URL 정보르 리턴 합니다.
     */
    func getAppMenuList( menuID : MENU_LIST ) -> Future<String, Never>
    {
        return Future<String, Never> { promise in
            if let response = BaseViewModel.appStartResponse
            {
                if let data = response.data
                {
                    if let menulist = data.menu_list
                    {
                        for info in menulist
                        {
                            if info.menu_id! == menuID.rawValue
                            {                                
                                promise(.success( AlamofireAgent.domainUrl  + info.url! ))
                                return
                            }
                        }
                    }
                }
            }
            promise(.success(""))
        }
    }
    
    
    /**
     만보기 약관 동의 여부를 체크 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.09
     - Parameters:False
     - Throws : False
     - returns :
     - AnyPublisher<PedometerTermsAgreeResponse?, ResponseError>
     >  PedometerTermsAgreeResponse : 홈 소비 정보를 요청 합니다.
     */
    func getPTTermAgreeCheck() -> AnyPublisher<PedometerTermsAgreeResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<PedometerTermsAgreeResponse?,ResponseError>()
        requst( showLoading: true ) { error in
            
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
     만보기 약관 동의 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.09
     - Parameters:False
     - Throws : False
     - returns :
     - AnyPublisher<InsertPedometerTermsResponse?, ResponseError>
     >  InsertPedometerTermsResponse : 약관동의 요청 정상처리 여부를 받습니다.
     */
    func setPTTermAgreeCheck() -> AnyPublisher<InsertPedometerTermsResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<InsertPedometerTermsResponse?,ResponseError>()
        requst( showLoading: true ) { error in
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
     로그아웃 처리 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:False
     - Throws : False
     - returns :
     - AnyPublisher<LogOutResponse?, ResponseError>
     >  LogOutResponse : 로그아웃 처리 결과를 받습니다.
     */
    func setLogOut() ->  AnyPublisher<LogOutResponse?, ResponseError> {
        let subject             = PassthroughSubject<LogOutResponse?,ResponseError>()
        requst( showLoading: true ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 로그아웃 요청 합니다.
            return NetworkManager.requestLogOut()
        } completion: { model in
            /// 로그인 정보를 초기화 합니다.
            BaseViewModel.loginResponse = nil
            BaseViewModel.loginResponse = LoginResponse()
            self.logoutResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    /**
     FCM TOKEN 정보를 서버에 등록 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.13
     - Parameters:False
     - Throws : False
     - returns :
     - AnyPublisher<FcmPushUpdateResponse?, ResponseError>
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
                requst() { error in
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
     앱 실드 여부를 체크 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.27
     - Throws : False
     - returns :
     - Future<AppShield, Never>
     >  AppShield : 앱 실드 정상 여부를 체크 합니다.
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
     앱 카메라 접근 허용 여부를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.29
     - Throws : False
     - returns :
     - Future<Bool, Never>
     >  Bool : 앱 카메라 접근 여부 값을 리턴 합니다.
     */
    func isCameraAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                DispatchQueue.main.async {
                    promise(.success(granted))
                }
            })
        }
    }
    
    
    /**
     앱 이미지 저장소 접근 허용 여부를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Throws : False
     - returns :
     - Future<Bool, Never>
     >  Bool : 앱 이미지 저장소 접근 여부 값을 리턴 합니다.
     */
    func isPhotoSaveAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
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
                    promise(.success(check))
                }
            })
        }
    }
    
    
    /**
     연락처 접근 허용 여부를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.29
     - Throws : False
     - returns :
     - Future<Bool, Never>
     >  Bool : 앱 연락처 접근 여부 값을 리턴 합니다.
     */
    func isContactAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            CNContactStore().requestAccess(for: .contacts, completionHandler: {
                success, error in
                DispatchQueue.main.async {
                    promise(.success(success))
                }
            })
        }
    }
    
    
    /**
     앱 PUSH 사용 허용 여부를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.29
     - Throws : False
     - returns :
     - Future<Bool, Never>
     >  Bool : PUSH 사용 인증 여부 값을 리탄합니다.
     */
    func isAPNSAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// PUSH 사용 할지 인증을 요청 합니다.
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { bool,Error in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    promise(.success(bool))
                }
            })
        }
    }
    
    
    /**
     앱 추적 (IDFA) 허용 여부를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Throws : False
     - returns :
     - Future<Bool, Never>
     >  Bool : 앱 추적 허용 승인 여부 값을 리턴 합니다.
     */
    func isTrackingAuthorization() -> Future<Bool, Never>
    {
        return Future<Bool, Never> { promise in
            /// iOS 14 버전 이후부터  앱 추적 접근 허용 여부를 요청 합니다.
            if #available(iOS 14, *)
            {
                /// 앱 추적 (IDFA) 허용 여부를 요청 합니다
                /// 난독화 안할떄 버젼.
                ATTrackingManager.requestTrackingAuthorization { status in
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
     Deeplink URL 정보를 체크하여 이동 할 URL 정보를 리턴 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.29
     - Throws : False
     - returns :
     - Future<String, Never>
     >  String : 딥링크 진입 할 URL 정보를 받습니다.
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
                    if let linkUrl = url.queryParameters?["url"],
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
     URL 에서 받은 정보르 파라미터로 세팅하여 리턴 합니다.
     - Date : 2023.04.19
     - Parameters:
     - url : URL 정보 입니다.
     - Throws : False
     - returns :
     - Future <[String : Any],Naver>
     + 파라미터 정보를 정리하여 리턴 합니다.
     */
    func getURLParams( url : URL ) -> Future<[String : Any], Never>
    {
        return Future<[String : Any], Never> { promise in
            let components                   = URLComponents(string: url.absoluteString)
            let items                        = components?.queryItems ?? []
            var params      : [String : Any] = [:]
            /// 제로페이에서 받은 데이터를 파라미터로 세팅 합니다.
            for item in items
            {
                params.updateValue(item.value as Any, forKey: item.name)
            }
            promise(.success(params))
        }
    }
    
    
    /**
     GET 방식 URL 파라미터를 설정하여 리턴 합니다.
     - Date : 2023.04.19
     - Parameters:
        - mainUrl : 메인 URL 정보 입니다.
        - params : GET 방식으로 연결할 파라미터 정보 입니다.
     - Throws : False
     - returns :
        - Future<String,Never>
            + 파라미터 연결된 GET 방식 URL 정보를 넘깁니다.
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
    
    
    /**
     Session 유지를 위해 쿠키 업데이트 정보를 리턴 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.25
     - Parameters:
        - cookies : 업데이트할 쿠키 정보입니다.
     - Throws : False
     - returns :
        - Future<String, Never>
            + 업데이트 된 정보를 넘깁니다.
     */
    func getJSCookiesString( cookies : [HTTPCookie]? ) -> Future<String, Never>
    {
        return Future<String, Never> { promise in
            var source = String()
            cookies?.forEach { cookie in
                source.append("document.cookie = '")
                source.append("\(cookie.name)=\(cookie.value); path=\(cookie.path); domain=\(cookie.domain);'\n")
            }
            promise(.success(source))
        }
    }
    
    
    /**
     FCM PUSH 수신을 등록합니다.
     - Date : 2023.04.06
     - Parameters:Fasle
     - Throws : False
     - returns :False
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
     키체인 사용 정보를 체크 합니다. ( 신규설치하거나, 앱삭제후 설치 . 기존 키체인 내용을 삭제 )
     - Date : 2023.04.06
     - Parameters:Fasle
     - Throws : False
     - returns :False
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
     탈옥 방지 체크 합니다.
     - Date : 2023.04.06
     - Parameters:Fasle
     - Throws : False
     - returns :False
     */
    func setSecureCheck() {
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
    
}


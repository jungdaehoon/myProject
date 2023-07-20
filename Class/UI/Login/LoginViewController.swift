//
//  LoginViewController.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/24.
//

import UIKit
import WebKit


/**
 로그인 페이지 버튼 이벤트 타입 입니다. ( J.D.H VER : 1.0.0 )
 - Date: 2023.03.24
 */
enum LOGIN_BTN_ACTION : Int {
    /// 로그인 페이지 종료 입니다.
    case close      = 10
    /// 로그인 요청 입니다.
    case login      = 11
    /// 자동 로그인 체크 입니다.
    case autologin  = 12
    /// 회원가입 요청 입니다.
    case join       = 13
    /// 아이디 변경 요청 입니다.
    case id_change  = 14
    /// 비밀번호 찾기 요청 입니다.
    case pw_change  = 15
    /// 비밀번호 입력정보 초기화 입니다.
    case pw_Clear   = 16
    /// 아이디 입력정보 초기화 입니다.
    case id_Clear   = 17
}



/**
 로그인 페이지 입니다. ( J.D.H VER : 1.0.0 )
 - Date: 2023.03.24
 */
class LoginViewController: BaseViewController {
    
    let viewModel                           : LoginModel  = LoginModel()
    /// 이벤트를 넘깁니다.
    var completion                          : (( _ success : Bool ) -> Void )? = nil
    /// 아이디, 패스워드 실패 최대 카운트 입니다.
    let IDPW_FAILED_MAX                     : Int = 5
    /// 아이디 최대 카운트 입니다.
    let ID_MAX_LEN                          : Int = 11
    /// 패스워드 최대 카운트 입니다.
    let PW_MAX_LEN                          : Int = 6
    /// 가이드뷰 디스플레이 여부 활성화 입니다. ( default : false )
    var guideViewEnabled                    : Bool = false
    /// 가이드 뷰어 입니다.
    @IBOutlet weak var guideView            : GuideInfoView!
    /// 아이디 입력 필드 입니다.
    @IBOutlet weak var idField              : UITextField!
    /// 아이디 입력 필드 초기화 버튼 입니다.
    @IBOutlet weak var idFieldClearBtn      : UIButton!
    /// 아이디 입력 하단 라인 입니다
    @IBOutlet weak var idBottomLine         : UIView!
    /// 패스워드 입력 필드 입니다.
    @IBOutlet weak var pwField              : UITextField!
    /// 패스워드 입력 하단 라인 입니다
    @IBOutlet weak var pwBottomLine         : UIView!
    /// 패스워드 입력 필드 초기화 버튼 입니다.
    @IBOutlet weak var pwFieldClearBtn      : UIButton!
    /// 자동로그인 체크 버튼 입니다.
    @IBOutlet weak var autoLoginBtn         : UIButton!
    /// 로그인 버튼 입니다.
    @IBOutlet weak var loginBtn             : UIButton!
    /// 아이디, 패스워드 실패시 안내 문구뷰 높이 입니다.
    @IBOutlet weak var idpwFailedInfoHegith : NSLayoutConstraint!
    /// 아이디, 패스워드 실패시 안내 문구 입니다.
    @IBOutlet weak var idpwFailedText       : UILabel!
    /// 보안 키패드 뷰어입니다.
    @IBOutlet weak var xkKeyPadView         : UIView!
    /// 보안 키페드 관련 입니다.
    var xkKeypadType                        : XKeypadType?
    var xkKeypadViewType                    : XKeypadViewType?
    var xkPasswordTextField                 : XKTextField!
    /// 보안 키패드에 입력된 정보를 저장 합니다.
    var xkindexedInputText                  : String?
    /// 아이디, 패스워드 실패중인 카운트를 체크 합니다.
    var ingIDPW_FailedCount                 : Int = 0
    
    
    // MARK: - init
    /**
     전체 웹뷰 초기화 메서드 입니다. ( J.D.H VER : 1.0.0 )
     - Date: 2023.04.04
     - Parameters:
        - completion :  페이지 종료시 콜백 핸들러 입니다.
     - Throws: False
     - Returns:False
     */
    init( completion : (( _ success : Bool ) -> Void )? = nil ) {
        super.init(nibName: nil, bundle: nil)
        /// 이벤트 정보를 리턴 하는 콜백입니다.
        self.completion = completion
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 로그인 페이지 디스플레이 여부를 "true" 활성화 합니다.
        BaseViewModel.isLoginPageDisplay = true
        /// 아이디 키패드 활성화시 배경 터치 키패드 종료 이벤트 연결 입니다.
        let idGesture : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureRecognized(_ :)))
        self.view.addGestureRecognizer(idGesture)
        /// PW 키패드 활성화시 배경 터치 키패드 종료 이벤트 연결 입니다.
        let pwGesture : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureRecognized(_ :)))
        self.xkKeyPadView.addGestureRecognizer(pwGesture)
         
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 가이드를 오픈 합니다.
        self.setGuideDisplay()
        /// 로그인 페이지 초기화 입니다.
        self.initLoginView()
        
    }
    
    
    
    // MARK: - GestureRecognizer
    @objc func tapGestureRecognized(_ gestureRecognizer:UITapGestureRecognizer) {
        self.setResignFirstResponder()
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     로그인 페이지 초기화 입니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.24
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func initLoginView()
    {
        if let custitem = SharedDefaults.getKeyChainCustItem()
        {
            /// 자동로그인 여부를 체크 합니다.
            self.autoLoginBtn.isSelected = custitem.auto_login
        }
        
        /// 택스트 필드 안내 문구를 설정 합니다.
        self.setTextFieldPlaceholder()
        /// 입력필드 및 안내 초기화 입니다.
        self.setInitTextField()
        /// 보안 키패드를 설정 합니다.
        self.initXKTextField()
        /// 로그인 버튼 활성화 설정 입니다.
        self.setLoginBtn()
    }
    
    
    /**
     입력 필드 및 안내 초기화 설정 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.04.17
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setInitTextField(){
        self.idField.text                   = ""
        self.pwField.text                   = ""
        self.idpwFailedText.text            = ""
        self.idpwFailedInfoHegith.constant  = 0
        self.idFieldClearBtn.isHidden       = true
        self.pwFieldClearBtn.isHidden       = true
    }
    
    
    /**
     입력 필드 Placeholder Font 정보를 설정 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.24
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setTextFieldPlaceholder() {
        let id_attributedString = NSMutableAttributedString(string: "아이디 (휴대폰번호 “-”없이 입력)", attributes: [
          .font: UIFont(name: "Pretendard-Medium", size: 18.0)!,
          .foregroundColor: UIColor(red:  187.0 / 255.0, green: 187.0 / 255.0, blue:  187.0 / 255.0, alpha: 1.0)
        ])
        
        let pw_attributedString = NSMutableAttributedString(string: "비밀번호 (6자리 숫자)", attributes: [
          .font: UIFont(name: "Pretendard-Medium", size: 18.0)!,
          .foregroundColor: UIColor(red:  187.0 / 255.0, green: 187.0 / 255.0, blue:  187.0 / 255.0, alpha: 1.0)
        ])
        
        self.idField.attributedPlaceholder = id_attributedString
        self.pwField.attributedPlaceholder = pw_attributedString
    }
    
    
    /**
     앱 가이드 디스플레이 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.24
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setGuideDisplay(){
        /// 가이드 뷰가 활성화 인지를 체크 합니다.
        if self.guideViewEnabled
        {
            /// 가이드 뷰를 디스플레이 합니다.
            self.guideView.setOpenView { value in
                /// 가이드 유저 호가인 여부 체크 입니다. ( 미가입자 다시 실행시 가이드 부터로 아래 영역은 아직 체크하지 않도록 합니다. )
                //SharedDefaults.default.guideShowFinished = true
                /// 업데이트 안내 팝업 입니다.
                let alert = CMAlertView().setAlertView( detailObject: "OKpay가 처음인가요?" as AnyObject )
                alert?.addAlertBtn(btnTitleText: "아니요", completion: { result in
                    /// 가이드뷰 활성화 여부 입니다.
                    self.guideViewEnabled = false
                    /// 가이드 뷰어를 종료 합니다.
                    self.guideView.setAniClose()
                    /// 앱 실드 체크 합니다.
                    self.setAppShield()
                })
                alert?.addAlertBtn(btnTitleText: "네", completion: { result in
                    self.guideView.setZeroPage()
                    /// 설정 URL 정보를 가져와 해당 페이지로 이동합니다.
                    self.viewModel.getAppMenuList(menuID: .ID_MEM_INTRO).sink { url in
                        self.view.setDisplayWebView(url, modalPresent: true, titleBarHidden: true)
                    }.store(in: &self.viewModel.cancellableSet)
                })
                alert?.show()
            }
        }
        else
        {
            /// 앱 실드 체크 합니다.
            self.setAppShield()
        }
        
    }
    
    
    /**
     로그인 버튼 활성화 여부를 체크 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.22
     - Parameters:
        - linkUrl : 연결할 페이지 URL 정보 입니다.
     - Throws: False
     - Returns:False
     */
    func setLoginBtn(){
        /// 로그인 버튼 활성화 체크 입니다.
        var loginEnabled : Bool = false
        /// 로그인 버튼 활성가능 여부를 체크 합니다.
        if self.idField.text!.count >= ID_MAX_LEN &&
            self.pwField.text!.count >= PW_MAX_LEN
        {
            loginEnabled = true
        }
        else
        {
            loginEnabled = false
        }
        
        self.loginBtn.isUserInteractionEnabled  = loginEnabled
        self.loginBtn.backgroundColor           = loginEnabled == true ? .OKColor : UIColor(hex: "#E1E1E1")
        self.loginBtn.setTitleColor(loginEnabled == true ? UIColor.white : UIColor(hex: "#BBBBBB"), for: .normal)
    }
    
    
    /**
     앱 실드로 정상 여부를 체크 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.27
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setAppShield(){
        /// 앱 실드 체크 합니다.
        self.viewModel.getAppShield().sink { appShield in
            /// error 이 아닌 경우 정상 처리 합니다.
            if appShield.error != nil
            {
                DispatchQueue.main.async(execute: {
                    /// 앱 실드 비정상 처리 안내 팝업 입니다.
                    CMAlertView().setAlertView(detailObject: appShield.error_msg! as AnyObject, cancelText: "확인") { event in
                        exit(0)
                    }
                })
            }
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    /**
     로그인 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.27
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setLogin(){
        /// 로그인 활성화인 경우 입니다.
        if self.loginBtn.isUserInteractionEnabled
        {
            /// 로그인 요청 합니다.
            self.viewModel.setLogin(self.idField.text!, xkPWField: self.xkPasswordTextField, inputPW: self.xkindexedInputText!).sink { result in                
            } receiveValue: { [self] response in
                if response != nil
                {
                    if NC.S(response!.code).count == 0 {return}
                    /// 팝업 안내 문구 입니다.
                    var msg     : String        = ""
                    /// 팝업 안내후 이동할 웹페이지 id 정보 입니다.
                    var menu_id : MENU_LIST     = .ID_MAIN
                    let code    : LOGIN_CODE    = LOGIN_CODE(rawValue: NC.S(response!.code))!
                    switch code {
                        /// 로그인 체크 코드가 없을 경우 입니다.
                    case ._code_fail_:
                        /// 비정상 상태로 안내후 종료 합니다.
                        CMAlertView().setAlertView(detailObject: TEMP_NETWORK_ERR_MSG_DETAIL as AnyObject, cancelText: "확인") { event in
                            exit(0)
                        }
                        break
                        /// 정상 로그인 입니다.
                    case ._code_0000_:
                        /// 정상 로그인된 정보를 KeyChainCustItem 정보에 세팅 합니다.
                        self.viewModel.setKeyChainCustItem(NC.S(self.idField.text)).sink { success in
                            if success
                            {
                                /// 로그인 여부를 활성화 합니다.
                                BaseViewModel.loginResponse!.islogin = true
                                /// GA 이벤트 정보를 보냅니다.
                                BaseViewModel.setGAEvent( eventName: "login", parameters: ["sign_up_method" : "P"] )
                                /// FCM TOKEN 정보를 서버에 등록 합니다.
                                let _ = self.viewModel.setFcmTokenRegister()
                                /// 닉네임 변경 여부를 체크 합니다.
                                if BaseViewModel.loginResponse!.nickname_ch!
                                {
                                    /// 닉네임 변경 페이지로 이동 합니다.
                                    self.view.setDisplayWebView(WebPageConstants.URL_CHANGE_NICKNAME, modalPresent: true, pageType: .NICKNAME_CHANGE, titleBarType: 0) { value in
                                        self.closeLogin()
                                    }
                                }
                                else
                                {
                                    /// 로그인 페이지를 종료 처리 합니다.
                                    self.closeLogin()
                                }
                            }
                        }.store(in: &self.viewModel.cancellableSet)
                        return
                        /// 아이디, 패스워드가 존재 하지 않습니다.
                    case ._code_1002_ ,
                         ._code_1005_ :
                        /// 아이디, 패스워드 실패 최대 카운트 정보를 체크 합니다.
                        if self.ingIDPW_FailedCount < IDPW_FAILED_MAX
                        {
                            self.ingIDPW_FailedCount            += 1
                            self.idpwFailedInfoHegith.constant  = 40
                            self.idpwFailedText.text            = "ID, 비밀번호가 일치하지 않습니다. (\(self.ingIDPW_FailedCount)/\(IDPW_FAILED_MAX))"
                            self.setAppShield()
                            return
                        }
                        menu_id     = .ID_LOG_FIND_PW
                        return
                        /// 휴먼회원 입니다.
                    case ._code_0010_:
                        self.view.setDisplayWebView(WebPageConstants.URL_WAKE_SLEEP_USER, modalPresent: true, titleBarType: 2) { value in
                            self.setAppShield()
                        }
                        return
                        /// 인증 만료 코드 입니다. ( 계좌인증 만료 )
                    case ._code_0011_:
                        CMAlertView().setAlertView(detailObject: "인증이 만료되었습니다.\n다시 인증 받으시기 바랍니다." as AnyObject, cancelText: "확인") { event in
                            self.view.setDisplayWebView(WebPageConstants.URL_TOKEN_REISSUE, modalPresent: true, titleBarType: 2) { value in
                                self.setAppShield()
                            }
                        }
                        return
                        /// 90일 동안 비밀번호 변경 요청 없는 경우 입니다.
                    case ._code_1006_:
                        menu_id     = .ID_LOG_CHANG_PW_90
                        self.viewModel.getAppMenuList(menuID: menu_id).sink { url in
                            /// 비밀번호 변경 요청 페이지로 이동합니다.
                            self.view.setDisplayWebView(url + "?flag=2", modalPresent: true, pageType: .PW90_NOT_CHANGE, titleBarType: 0) { value in
                                /// 콜백 타입을 체크 합니다.
                                switch value
                                {
                                    /// 비밀번호 변경 후 진입 경우 입니다.
                                    case .loginCall:
                                        self.setAppShield()
                                        return
                                    default:break
                                }
                                
                                /// 비밀번호 미변경시 로그인된 정보를 KeyChainCustItem 정보에 세팅 합니다.
                                self.viewModel.setKeyChainCustItem(NC.S(self.idField.text)).sink { success in
                                    if success
                                    {
                                        /// 로그인 여부를 활성화 합니다.
                                        BaseViewModel.loginResponse!.islogin = true
                                        /// FCM TOKEN 정보를 서버에 등록 합니다.
                                        let _ = self.viewModel.setFcmTokenRegister()
                                        /// 닉네임 변경 여부를 체크 합니다.
                                        if BaseViewModel.loginResponse!.nickname_ch!
                                        {
                                            /// 닉네임 변경 페이지로 이동 합니다.
                                            self.view.setDisplayWebView(WebPageConstants.URL_CHANGE_NICKNAME, modalPresent: true, pageType: .NICKNAME_CHANGE, titleBarType: 0) { value in
                                                self.closeLogin()
                                            }
                                        }
                                        else
                                        {
                                            /// 로그인 페이지를 종료 처리 합니다.
                                            self.closeLogin()
                                        }
                                    }
                                }.store(in: &self.viewModel.cancellableSet)
                            }
                        }.store(in: &self.viewModel.cancellableSet)
                        return
                        /// 휴대폰 본인 재인증 입니다.
                    case ._code_1004_:
                        msg         = "고객님의 안전한 정보보호를 위해 앱 재설치 시, 휴대폰 본인인증이 필요합니다."
                        menu_id     = .ID_LOG_FIND_ID
                        break
                    }
                    
                    /// 메세지 문구가 없는 경우 바로 페이지 이동 입니다.
                    if msg == ""
                    {
                        self.viewModel.getAppMenuList(menuID: menu_id).sink { url in
                            self.view.setDisplayWebView(url + "?flag=2", modalPresent: true, titleBarHidden: true) { value in
                                self.setAppShield()
                            }
                        }.store(in: &self.viewModel.cancellableSet)
                        return
                    }
                    
                    /// 안내 팝업 오픈 합니다.
                    CMAlertView().setAlertView(detailObject: msg as AnyObject, cancelText: "확인") { event in
                        self.viewModel.getAppMenuList(menuID: menu_id).sink { url in
                            self.view.setDisplayWebView(url + "?flag=2", modalPresent: true, titleBarHidden: true) { value in
                                self.setAppShield()
                            }
                        }.store(in: &self.viewModel.cancellableSet)
                    }
                }
            }.store(in: &self.viewModel.cancellableSet)
        }
    }
    
    
    /**
     로그인 페이지를 종료 합니다. ( J.D.H VER : 1.0.0 )
     - Description : 종료후 메인 홈으로 이동하며 딥링크나/PUSH 정보를 가지고 있다면 홈으로 이동 후 해당 웹페이지를 디스플레이 하도록 합니다.
     - Date: 2023.05.31
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func closeLogin(){
        /// 로그인 페이지를 종료 여부를 넘깁니다.
        if self.completion != nil { self.completion!(true) }
        /// 로그인 페이지 디스플레이를 "false" 로 변경 합니다.
        BaseViewModel.isLoginPageDisplay = false
        /// 현 페이지를 종료합니다.
        self.popController(animated: true,animatedType: .down) { firstViewController in
            /// 탭바가 연결되었다면 메인 페이지로 이동 합니다.
            if let tabbar = TabBarView.tabbar
            {
                /// 비로그인 상태에서 딥링크나 PUSH정보의 외부 데이터로 앱이 실행 되는 경우 받은 데이터롤 가져 옵니다.
                if let link = BaseViewModel.shared.getInDataAppStartURL(),
                   link.isValid
                {
                    /// 진행중인 탭 인덱스를 초기화 합니다.
                    tabbar.setIngTabToRootController()
                    /// 메인탭 URL 정보에 뒤 파라미터로 추가한 URL 로 이동 합니다.
                    tabbar.setSelectedIndex(.home, seletedItem: WebPageConstants.URL_MAIN, updateCookies: true) { controller in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            controller.loadMainURL(link) { success in
                                
                            }
                        })
                    }
                }
                else
                {
                    /// 메인 탭 이동하면서 메인 페이지를 디스플레이 합니다.
                    tabbar.setSelectedIndex(.home, seletedItem: WebPageConstants.URL_MAIN, updateCookies: true)
                }
            }
        }
    }
    
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let value : LOGIN_BTN_ACTION = LOGIN_BTN_ACTION(rawValue: (sender as AnyObject).tag!)!
        switch value {
        case .close:
            /// 가이드 디스플레이로 넘어 갑니다.
            self.setGuideDisplay()
            break
        case .login:
            /// 로그인 요청 합니다.
            self.setLogin()
            break
        case .autologin:
            self.autoLoginBtn.isSelected = !self.autoLoginBtn.isSelected
            if let custItem = SharedDefaults.getKeyChainCustItem()
            {
                custItem.auto_login = self.autoLoginBtn.isSelected
                SharedDefaults.setKeyChainCustItem(custItem)
            }
            break
        case .join:
            self.viewModel.getAppMenuList(menuID: .ID_MEM_INTRO).sink { url in
                self.view.setDisplayWebView(url,modalPresent: true,titleBarHidden: true)  { _ in
                    self.setAppShield()
                }
            }.store(in: &self.viewModel.cancellableSet)
            break
        case .id_change:
            self.viewModel.getAppMenuList(menuID: .ID_LOG_FIND_ID).sink { url in
                self.view.setDisplayWebView(url,modalPresent: true,titleBarHidden: true)  { _ in
                    self.setAppShield()
                }
            }.store(in: &self.viewModel.cancellableSet)
            break
        case .pw_change:
            self.viewModel.getAppMenuList(menuID: .ID_LOG_FIND_PW).sink { url in
                self.view.setDisplayWebView(url,modalPresent: true,titleBarHidden: true)  { _ in
                    self.setAppShield()
                }
            }.store(in: &self.viewModel.cancellableSet)
            break
        case .pw_Clear:
            self.pwField.text               = ""
            self.pwFieldClearBtn.isHidden   = true
            break
        case .id_Clear:
            self.idField.text               = ""
            self.idFieldClearBtn.isHidden   = true
            break
        }
    }
}




// MARK: - UITextFieldDelegate
extension LoginViewController : UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        /// 패스워드 타입인지를 체크 합니다.
        if textField == self.pwField
        {
            self.setResignFirstResponder()
            self.pwBottomLine.backgroundColor = .OKColor
            DispatchQueue.main.async {
                /// 보안 키패드를 오픈 합니다.
                self.xkKeyPadBecomeFirstResponder()
            }
            return false
        }
        else if textField == self.idField
        {
            self.idBottomLine.backgroundColor = .OKColor
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField )
    {
        Slog("textFieldDidChangeSelection : \(NC.S(textField.text))")
        if textField == self.idField { self.idFieldClearBtn.isHidden = !textField.text!.isValid }        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// 로그인 버튼 활성화 여부를 체크 합니다.
        self.setLoginBtn()
        /// 삭제 요청 일 경우 입니다.
        if string == "" { return true }
        /// 최대 입력 카운트가 11을 넘집 않도록 합니다.
        if textField.text!.count > ID_MAX_LEN
        {
            return false
        }
        
        
        
        return true
    }
}



// MARK: - 보안 키패드 초기화 관련 입니다.
extension LoginViewController {
    /**
     보안 키페드 를 초기화 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.24
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func initXKTextField() {
        xkKeypadType                        = .number
        xkKeypadViewType                    = .normalView
        xkPasswordTextField                 = XKTextField(frame: CGRect.zero)
        xkPasswordTextField.isFromFullView  = true
        xkPasswordTextField.returnDelegate  = self
        xkPasswordTextField.xkeypadType     = xkKeypadType!
        xkPasswordTextField.xkeypadViewType = xkKeypadViewType!
        xkPasswordTextField.e2eURL          = WebPageConstants.URL_KEYBOARD_E2E
        
        self.xkKeyPadView.addSubview(xkPasswordTextField)
        self.setResignFirstResponder()
        Slog("xkKeypadType!:\(xkKeypadType!)")
        Slog("xkKeypadViewType!!:\(xkKeypadViewType!)")
        Slog("e2eURLString!!:\(WebPageConstants.URL_KEYBOARD_E2E)")
        Slog("xkPasswordTextField::\(xkPasswordTextField)")
    }
     
    
    /**
     보안 키페드 를 활성화 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.27
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func xkKeyPadBecomeFirstResponder() {
        self.view.endEditing(true)
        self.xkKeyPadView.isHidden = false
        self.xkPasswordTextField.becomeFirstResponder()
    }
    
    
    /**
     키페드 를 종료 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.27
     - Parameters:Fasle
     - Throws: False
     - Returns:False
     */
    func setResignFirstResponder() {
        self.view.endEditing(true)
        self.xkKeyPadView.isHidden = true
        self.xkPasswordTextField.resignFirstResponder()        
        self.idBottomLine.backgroundColor = UIColor(hex: 0xE1E1E1)
        self.pwBottomLine.backgroundColor = UIColor(hex: 0xE1E1E1)
        self.setLoginBtn()
    }
    
    
    /**
     보안키패드 입력 될 때 마다 받는 콜백 메서드 입니다.  ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.24
     - Parameters:
        - aCount: 입력된 카운트 정보 입니다.
        - finished : 입력 여부 입니다. ( true : 입력완료 , false : 미입력 )
        - tuple : finished 가 true 일 때  tuple 입력 받습니다.. ( 보안 키패드 관련된 sessionid, token , e2edata)
     - Throws: False
     - Returns:False
     */
    func mainKeypadInputCompleted(_ aCount: Int,  finished : Bool = false, tuple : (String,String)? = nil ) {
        /// 비밀번호 정보를 초기화 합니다.
        self.pwField.text = ""
        /// 카운트 정보에 맞춰 비밀번호 필드에 데이터를 추가 합니다.
        for _ in  0 ..< aCount
        {
            self.pwField.text!.append("*")
        }
        self.pwFieldClearBtn.isHidden = !self.pwField.text!.isValid
        /// 입력 여부가 있을경우 데이터를 저장 합니다.
        if finished
        {
            /// 로그인시 사용할 보안 비밀번호 정보를 저장합니다.
            self.xkindexedInputText = xkPasswordTextField.getDataE2E()
        }
        
        /// 로그인 버튼 활성화 여부를 체크 합니다.
        self.setLoginBtn()
        
    }
     
}



//MARK: - XKTextFieldDelegate
extension LoginViewController : XKTextFieldDelegate{
    func keypadInputCompleted(_ aCount: Int) {
        self.mainKeypadInputCompleted(aCount,finished: true)
    }
    
    
    func keypadE2EInputCompleted(_ aSessionID: String!, token aToken: String!, indexCount aCount: Int) {
        Slog("ABC keypadE2EInputCompleted aSessionID \(aSessionID) aToken \(aToken) aCount \(aCount)")
        self.mainKeypadInputCompleted(aCount,finished: true,tuple: (aSessionID, aToken ) )
        xkPasswordTextField.cancelKeypad()
        self.view.endEditing(true)
    }
    
    func keypadCanceled() {
        Slog("ABC keypadCanceled ")
        self.setResignFirstResponder()
    }
    
    func textFieldShouldDeleteCharacter(_ textField: XKTextField!) -> Bool {
        Slog("ABC textFieldShouldDeleteCharacter length:\(String(describing: textField.text?.count))")
        self.mainKeypadInputCompleted((textField.text?.count)!)
        return true
    }
    
    func textField(_ textField: XKTextField!, shouldChangeLength length: UInt) -> Bool {
        Slog("ABC shouldChangeLength  \(length) ")
        if(textField == xkPasswordTextField)
        {
            // 최대 자리수 6자리
            if length == PW_MAX_LEN
            {
                let aSessionID  = xkPasswordTextField.getSessionIDE2E()
                let aToken      = xkPasswordTextField.getTokenE2E()
                mainKeypadInputCompleted(Int(length),finished: true,tuple: (aSessionID, aToken ) as? (String, String) )
                xkPasswordTextField.cancelKeypad()
                self.setResignFirstResponder()
            }
            else
            {
                mainKeypadInputCompleted(Int(length))
            }
        }
        return true
    }
    
    
    
    func textFieldSessionTimeOut(_ textField: XKTextField!) {
        Slog("ABC textFieldSessionTimeOut ")
        textField.cancelKeypad();
        /// 세션만료 안내 팝업 오픈 입니다.
        CMAlertView().setAlertView(detailObject: "보안 세션이 만료되었습니다.\n다시 실행해 주세요." as AnyObject, cancelText: "확인") { event in
            self.setResignFirstResponder()
        }
    }
    
    
}

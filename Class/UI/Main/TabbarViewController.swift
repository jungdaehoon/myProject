//
//  TabbarViewController.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/20.
//

import UIKit

/**
 노티 이벤트 이름을 가집니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
 */
extension Notification.Name {
    /// PUSH 이벤트 발생시 입니다.
    static let PUSH_EVENT              = Notification.Name("PUSH_EVENT")
    /// 딥링크로 앱 실행 입니다.
    static let DEEP_LINK               = Notification.Name("DEEP_LINK")
}


/**
 텝 별 인덱스 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.21
 */
enum TAB_STATUS : Int {
    /// 월렛 탭 인덱스 입니다.
    case wallet     = 0
    /// 혜택 탭 인덱스 입니다.
    case benefit    = 1
    /// 홈 탭 인덱스 입니다.
    case home       = 2
    /// 금융 탭 인덱스 입니다.
    case finance    = 3
    /// 전체 탭 인덱스 입니다.
    case allmenu    = 4
}


/**
 메인 탭바 컨트롤러 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
 */
class TabbarViewController: UITabBarController {
    var viewModel                       : BaseViewModel = BaseViewModel()
    /// 하단 탭바 뷰어입니다.
    @IBOutlet weak var baseTabbarView   : BaseTabBarView!
    /// 최초 앱 실행시 로그인 페이지 활성화 여부 입니다.
    var loginDisplayFirst               : Bool = false
    
    
    
    // MARK: - override
    override var selectedViewController: UIViewController? {
        didSet {
            tabChangedTo(selectedIndex: selectedIndex)
        }
    }
    
    // Override selectedIndex for Programmatic changes
    override var selectedIndex: Int {
        didSet {
            tabChangedTo(selectedIndex: selectedIndex)
        }
    }
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        TabBarView.tabbar = self
        /// 기본 쉐도우 라인을 초기화 합니다.
        UITabBar.clearShadow()
        /// 탭바 상단 쉐도우 라인을 추가 합니다.
        tabBar.layer.applyShadow(color: .gray, alpha: 0.2, x: 0, y: 0, blur: 12)
        /// Notification 관련 이벤트를 연결 합니다.
        self.setNotification()
        /// 로그아웃 여부를 체크 합니다.
        BaseViewModel.shared.$logOut.sink { value in
            /// 로그인 최초 디스플레이 이후에 적용 됩니다.
            if self.loginDisplayFirst || !value { return }
            /// 로그인 페이지를 오픈 합니다.
            self.setDisplayLogin( animation: true ) { success in
                if success
                {
                    /// 로그아웃을. false 변경 합니다.
                    BaseViewModel.shared.logOut = false
                    /// 탭 인덱스를 기본 홈으로 설정 합니다.
                    self.selectedIndex          = 2
                }
            } puchCompletion: {
                
            }
        }.store(in: &self.viewModel.cancellableSet)
        
        /// 딥링크 URL 이벤트 입니다.
        BaseViewModel.shared.$deepLinkUrl.sink { url in
            /// 로그인 최초 디스플레이 이후에 적용 됩니다.
            if self.loginDisplayFirst || !url.isValid { return }
            /// 앱 시작시 받을수 있는 딥링크 데이터를 초기화 합니다.
            BaseViewModel.shared.didDeepLinkUrl = ""
            /// 로그인 정보가 있는지를 체크 합니다.
            if let login = BaseViewModel.loginResponse
            {
                if login.islogin!
                {
                    /// 해당 URL 로 이동합니다.
                    if NC.S(url).isValid
                    {
                        /// 진행중인 탭 인덱스를 초기화 합니다.
                        self.setIngTabToRootController()
                        /// 탭 화면을 홈으로 이동하며 DeepLink 연동 페이지로 이동합니다.
                        self.setSelectedIndex(.home, object: url)
                        BaseViewModel.shared.deepLinkUrl = ""
                    }
                }
                else
                {
                    /// 로그인 페이지를 오픈 합니다.
                    self.setDisplayLogin { success in
                        /// 딥링크 URL 을 다시 넘깁니다.
                        BaseViewModel.shared.deepLinkUrl = url
                    } puchCompletion: {
                        
                    }
                }
            }
        }.store(in: &self.viewModel.cancellableSet)
        
        /// 푸시 URL 링크 입니다.
        BaseViewModel.shared.$pushUrl.sink { url in
            /// 로그인 최초 디스플레이 이후에 적용 됩니다.
            if self.loginDisplayFirst || !url.isValid  { return }
            /// 앱 시작시 받을수 있는 PUSH 데이터를 초기화 합니다.
            BaseViewModel.shared.didPushUrl = ""
            /// 로그인 정보가 있는지를 체크 합니다.
            if let login = BaseViewModel.loginResponse {
                if login.islogin!
                {
                    /// 해당 URL 로 이동합니다.
                    if NC.S(url).isValid
                    {
                        /// 진행중인 탭 인덱스를 초기화 합니다.
                        self.setIngTabToRootController()
                        /// 탭 화면을 홈으로 이동하며  PUSH 연동 페이지로 이동합니다.
                        self.setSelectedIndex( .home, object: url)
                        /// PUSH 에서 받은 연결 정보를 초기화 합니다.
                        BaseViewModel.shared.pushUrl = ""
                    }
                }
                else
                {
                    /// 로그인 페이지를 오픈 합니다.
                    self.setDisplayLogin { success in
                        /// 딥링크 URL 을 다시 넘깁니다.
                        BaseViewModel.shared.pushUrl = url
                    } puchCompletion: {
                        
                    }
                }
            }
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("TabbarViewController viewDidAppear")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        /// 로그인 페이지 디스플레이 할지를 체크 합니다.
        if self.loginDisplayFirst
        {
            /// 로그인 페이지를 오픈 합니다.
            self.setDisplayLogin(gudieViewEnabled: true) { success in
                if success
                {
                    /// 로그인 디스플레이를 하지 않도록 합니다.
                    self.loginDisplayFirst = false
                }
            } puchCompletion: {
                BecomeActiveView().hide()
            }
        }
        /// 로그인 이후 진입 경우 입니다.
        else
        {
            /// 닉네임과 유저 넘버가 동일한 경우닉네임 변경 페이지 이동을 체크 합니다.
            if let login = BaseViewModel.loginResponse
            {
                if login.nickname_ch!
                {
                    self.view.setDisplayWebView( WebPageConstants.URL_CHANGE_NICKNAME, modalPresent: true, titleBarHidden: true)
                }
            }
        }
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     탭 아이템  활성화 여부를 받아 활성화 합니다..   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.25
     - Parameters:
        - selectedIndex : 탭 변경 인덱스 정보 입니다.
     - returns :False
     */
    func tabChangedTo(selectedIndex: Int) {
        /// 탭 인덱스 정보를 커스텀 탭 바에 넘깁니다.
        self.baseTabbarView.tabbar!.setChangePage(selectedIndex + 10)
    }
    
    
    /**
     로그인 페이지 디스플레이 입니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.24
     - Parameters:
        - animation : 디스플레이시 애니 효과 적용 여부 입니다.
        - gudieViewEnabled : 가이드 디스플레이 여부 입니다.
        - completion : 로그인 정상 처리시 여부 콜백 입니다.
        - puchCompletion : 로그인 페이지 정상 호출시 콜백 입니다.
     - returns :False
     */
    func setDisplayLogin( animation : Bool = false, gudieViewEnabled : Bool = false, completion : (( _ success : Bool ) -> Void )? = nil, puchCompletion: @escaping () -> Void ){
        let viewController              = LoginViewController.init( completion: completion )
        viewController.guideViewEnabled = gudieViewEnabled
        self.pushController(viewController, animated: animation, animatedType: .up, completion: puchCompletion)        
    }
    
    
    /**
     Notification 관련 이벤트를 연결 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.23
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setNotification(){
        /// 백그라운드에서 올라오는 경우 이벤트를 연결 합니다.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBackground), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    
    
    // MARK: - NotificationCenter
    /**
     앱 백그라운드 이동하는 경우 입니다.
     - Date : 2023.04.04
     - Throws:False
     - returns:False
     */
    @objc func applicationBackground(){
        BecomeActiveView().show()
    }
    
    
    /**
     앱 백그라운드 에서 호출되는 경우 입니다.
     - Date : 2023.04.04
     - Throws:False
     - returns:False
     */
    @objc func applicationForeground(){
        BecomeActiveView().hide()
    }
}



extension UITabBarController
{
    
    func setIngTabToRootController(){
        /// 이전 진행중인 ViewController 을 초기화 합니다.
        if let viewController = self.viewControllers![self.selectedIndex] as? BaseViewController
        {
            viewController.popToRootController(animated: false)
        }
    }
    
    /**
     텝 이동시 해당 텝에서 체크 할 데이터를 추가합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.24
     - Parameters:
        - tabIndex      : 이동할 탭 넘버 입니다.
        - object        : 추가할 데이터 입니다.
        - updateCookies : 탭 이동시 쿠키 값을 업로드 할지 여부를 받습니다.
     - returns :False
     */
    func setSelectedIndex( _ tabIndex : TAB_STATUS, object : Any? = nil, updateCookies : Bool = false ){
        if object != nil
        {
            Slog("setSelectedIndex : \(tabIndex.rawValue)")
            switch tabIndex
            {
                /// 월렛 입니다.
            case .wallet :
                break;
                /// 혜택 입니다.
            case .benefit :
                break;
                /// 홈 입니다.
            case .home :
                
                
                if let home = self.viewControllers![tabIndex.rawValue] as? HomeViewController
                {
                    if object is String,
                       let value = object as? String
                    {
                        home.loadMainURL(value, updateCookies: updateCookies)
                    }
                }
                break;
                /// 금융 입니다.
            case .finance :
                //let remittance = self.viewControllers![selectedIndex] as! RemittanceViewController
                //remittance._viewModel.displayData = object
                break;
                /// 전체 입니다.
            case .allmenu :
                break;
            }
        }
        self.selectedIndex = tabIndex.rawValue
    }
}








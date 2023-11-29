//
//  TabbarViewController.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/20.
//

import UIKit

/**
 노티 이벤트 이름을 가집니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.20
 */
extension Notification.Name {
    /// PUSH 이벤트 발생시 입니다.
    static let PUSH_EVENT              = Notification.Name("PUSH_EVENT")
    /// 딥링크로 앱 실행 입니다.
    static let DEEP_LINK               = Notification.Name("DEEP_LINK")
}


/**
 텝 별 인덱스 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.21
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
 메인 탭바 컨트롤러 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.20
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
        
        /// 네트워크 사용 가능 여부를 체크 합니다.
        BaseViewModel.shared.$isNetConnected.sink { checking in
            /// 네트워크 체킹 타입 경우인지를 체크 합니다.
            if checking == .checking
            {
                /// 네트워크 사용 불가능 경우 입니다.
                if BaseViewModel.isNetworkCheck() == .fail
                {
                    /// 네트워크 연결 불가능 타입 설정 합니다.
                    BaseViewModel.shared.isNetConnected = .fail
                    /// 로딩바 디스플레이 중일 경우 히든 처리 합니다.
                    LoadingView.default.hide()
                    /// 네트워크 사용 불가능으로 안내 팝업을 오픈 합니다.
                    CMAlertView().setAlertView( detailObject: NETWORK_ERR_MSG_DETAIL as AnyObject, cancelText: "확인") {  result in
                        HttpErrorPop().show()
                    }
                }
                else
                {
                    /// 네트워크 연결 가능 타입 설정 합니다.
                    BaseViewModel.shared.isNetConnected = .connecting
                }
            }
        }.store(in: &BaseViewModel.shared.cancellableSet)
        
        /// 재로그인 이벤트 입니다.
        BaseViewModel.shared.$reLogin.sink { value in
            /// 로그인 최초 디스플레이 이후에 적용 됩니다.
            if self.loginDisplayFirst || !value { return }
            /// 진행중인 탭 인덱스를 초기화 합니다.
            self.setIngTabToRootController()
            /// 로그인 페이지를 오픈 합니다.
            self.setDisplayLogin( animation: true ) { success in
                if success
                {
                    /// 재로그인 요청을 비활성화 합니다.
                    BaseViewModel.shared.reLogin = false                    
                    /// 메인 홈으로 이동 합니다.
                    TabBarView.setReloadSeleted(pageIndex: 2)
                }
            } puchCompletion: {
                
            }
        }.store(in: &BaseViewModel.shared.cancellableSet)
        
        /// 딥링크 URL 이벤트 입니다.
        BaseViewModel.shared.$deepLinkUrl.sink { url in
            /// 로그인 최초 디스플레이 이후에 적용 됩니다.
            if self.loginDisplayFirst || !url.isValid { return }
            /// 앱 시작시 받을수 있는 딥링크 데이터를 초기화 합니다.
            BaseViewModel.shared.saveDeepLinkUrl = ""
            /// 로그인 정보가 있는지를 체크 합니다.
            if BaseViewModel.isLogin()
            {
                /// 해당 URL 로 이동합니다.
                if NC.S(url).isValid
                {
                    /// 진행중인 탭 인덱스를 초기화 합니다.
                    self.setIngTabToRootController()
                    /// 탭 화면을 홈으로 이동하며 DeepLink 연동 페이지로 이동합니다.
                    self.setSelectedIndex(.home, seletedItem: WebPageConstants.getDomainURL(url))
                    /// 딥링크 연결 정보를 초기화 합니다.
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
        }.store(in: &BaseViewModel.shared.cancellableSet)
        
        /// 푸시 URL 링크 입니다.
        BaseViewModel.shared.$pushUrl.sink { url in
            /// 로그인 최초 디스플레이 이후에 적용 됩니다.
            if self.loginDisplayFirst || !url.isValid  { return }
            /// 앱 시작시 받을수 있는 PUSH 데이터를 초기화 합니다.
            BaseViewModel.shared.savePushUrl = ""
            /// 로그인 상태 인지를 체크 합니다.
            if BaseViewModel.isLogin()
            {
                /// 해당 URL 로 이동합니다.
                if NC.S(url).isValid
                {
                    Slog("push url : \(NC.S(url))")
                    /// 이동할 URL 정보가. 엘포인트 타입인지를 체크 합니다.
                    if url.contains("/lpoint/")
                    {
                        self.setIngViewController(url: url)
                    }
                    else
                    {
                        /// 진행중인 탭 인덱스를 초기화 합니다.
                        self.setIngTabToRootController()
                        /// 탭 화면을 홈으로 이동하며  PUSH 연동 페이지로 이동합니다.
                        self.setSelectedIndex( .home, seletedItem: WebPageConstants.getDomainURL(url))
                    }
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
        }.store(in: &BaseViewModel.shared.cancellableSet)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Slog("TabbarViewController viewDidAppear")
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
        else
        {
            BecomeActiveView().hide()
        }
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     탭 아이템  활성화 여부를 받아 활성화 합니다..   ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.25
     - Parameters:
        - selectedIndex : 탭 변경 인덱스 정보 입니다.
     - Returns:False
     */
    func tabChangedTo(selectedIndex: Int) {
        /// 탭 인덱스 정보를 커스텀 탭 바에 넘깁니다.
        self.baseTabbarView.tabbar!.setChangePage(selectedIndex + 10)
    }
    
    
    /**
     로그인 페이지 디스플레이 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.24
     - Parameters:
        - animation : 디스플레이시 애니 효과 적용 여부 입니다.
        - gudieViewEnabled : 가이드 디스플레이 여부 입니다.
        - completion : 로그인 정상 처리시 여부 콜백 입니다.
        - puchCompletion : 로그인 페이지 정상 호출시 콜백 입니다.
     - Returns:False
     */
    func setDisplayLogin( animation : Bool = false, gudieViewEnabled : Bool = false, completion : (( _ success : Bool ) -> Void )? = nil, puchCompletion: @escaping () -> Void ){
        let viewController              = LoginViewController.init( completion: completion )
        viewController.guideViewEnabled = gudieViewEnabled
        self.pushController(viewController, animated: animation, animatedType: .up, completion: puchCompletion)        
    }
    
    
    /**
     Notification 관련 이벤트를 연결 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.23
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setNotification(){
        /// 백그라운드에서 올라오는 경우 이벤트를 연결 합니다.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBackground), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    
    
    // MARK: - NotificationCenter
    /**
     앱 백그라운드 이동하는 경우 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.04
     - Throws:False
     - returns:False
     */
    @objc func applicationBackground(){
        BecomeActiveView().show()
        if BaseViewModel.getSessionMaxTime() > 0
        {
            BaseViewModel.appBackgroundSaveTimer = Int(Date().timeIntervalSince1970)
            /// 세션 체크를 대기 합니다.
            BaseViewModel.isSssionType = .wait
            Slog("Date().timeIntervalSince1970 Int : \(Int(Date().timeIntervalSince1970))")
        }        
    }
    
    
    /**
     앱 백그라운드 에서 호출되는 경우 입니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.04
     - Throws:False
     - returns:False
     */
    @objc func applicationForeground(){
        BecomeActiveView().hide()
        if BaseViewModel.getSessionMaxTime() > 0
        {
            if BaseViewModel.appBackgroundSaveTimer > 0
            {
                /// 백그라운드 대기했던 오버 타임 입니다.
                BaseViewModel.backgroundOverTimer = Int(Date().timeIntervalSince1970) - BaseViewModel.appBackgroundSaveTimer
                /// 총 오버 타임을 추가 합니다.
                let overTime = BaseViewModel.backgroundOverTimer + BaseViewModel.ingSessionSaveTimer
                /// 최대 백스 타임보다 클경우 로그아웃 진행 합니다.
                if overTime > BaseViewModel.getSessionMaxTime()
                {
                    /// PUSH/DEEPLINK 들어올 경우 로그아웃 여부를 체크하기 위해 false 값을 선언 합니다.
                    BaseViewModel.loginResponse!.islogin = false
                    BaseViewModel.backgroundOverTimer    = 0
                    BaseViewModel.appBackgroundSaveTimer = 0
                    BaseViewModel.ingSessionSaveTimer    = 0
                    BaseViewModel.isSssionType           = .exitLogout
                    Slog("Over Time : \(Int(Date().timeIntervalSince1970) - BaseViewModel.appBackgroundSaveTimer)")
                }
                else
                {
                    BaseViewModel.appBackgroundSaveTimer = 0
                    BaseViewModel.ingSessionSaveTimer    = 0
                    /// 세션 체크를 다시 시작 합니다.
                    BaseViewModel.isSssionType           = .start
                    
                }
                Slog("Ing Time : \(overTime)")
            }
        }
    }
}



extension UITabBarController
{
    /**
     현 진행중인 안내 뷰어 를 전부 초기화 합니다. ( J.D.H VER : 2.0.0 )
     - Description: UIApplication.shared.windows 상에 추가된 UIView(BaseView) 타입의 모든 안내 팝업류는 전부 삭제 합니다.
     - Date: 2023.05.17
     - Parameters:False
     - Returns:False
     */
    func setCommonViewRemove(){
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is BaseView { $0.removeFromSuperview() }
            })
        }
    }
    
    
    /**
     현 진행중인 페이지에서 url 페이지로 이동 합니다. ( J.D.H VER : 2.0.7 )
     - Description: Lpoint 에서 사용으로 lPoint 페이지에서 PUSH 받을경우 "결제완료" 등 관련 페이지 이동시 현 페이지에서 전체화면 web 페이지를 오픈 하도록 합니다.
     - Date: 2023.11.28
     - Parameters:
        - url: 페이지 이동 할 URL 정보 입니다.
     - Returns:False
     */
    func setIngViewController( url : String? ){
        /// 이전 진행중인 ViewController 을 초기화 합니다.
        if let viewController = self.viewControllers![self.selectedIndex]  as? BaseViewController,
           let pageUrl = url {
            if let navigation = viewController.navigationController,
               let contoller  = navigation.ingViewcontroller as? FullWebViewController {
                if let webview  = contoller.webView,
                   let url      = webview.url {
                    Slog("url.absoluteString : \(url.absoluteString)")
                    /// 현 페이지가 lpoint 페이지 인지를 체크 합니다.
                    if url.absoluteString.contains("/lpoint/") {
                        contoller.view.setDisplayWebView( WebPageConstants.getDomainURL(pageUrl) , modalPresent: true )
                        return
                    }
                }
            }
            /// 진행중인 탭 인덱스를 초기화 합니다.
            self.setIngTabToRootController()
            /// 탭 화면을 홈으로 이동하며  PUSH 연동 페이지로 이동합니다.
            self.setSelectedIndex( .home, seletedItem: WebPageConstants.getDomainURL(pageUrl))
        }
    }
    
    
    /**
     현 진행중인 페이지를 root 페이지로 초기화 합니다. ( J.D.H VER : 2.0.0 )
     - Description: Root 페이지 이동시 현 보여지는 페이지와 이전 연결되었던 모든 ViewController/UIView 페이지를 전부 삭제 후 Root 페이지로 이동 합니다.
     - Date: 2023.05.17
     - Parameters:False
     - Returns:False
     */
    func setIngTabToRootController(){
        /// 진행중인 안내 뷰어를 전부 히든 처리 합니다.
        self.setCommonViewRemove()
        /// 이전 진행중인 ViewController 을 초기화 합니다.
        if let viewController = self.viewControllers![self.selectedIndex] as? BaseViewController
        {
            viewController.popToRootController(animated: false)
        }
    }
    
    
    /**
     하단 탭바 위치를 이동합니다.  ( J.D.H VER : 2.0.0 )
     - Description      : 탭을 이동시 추가 정보를 받아 디스플레이 할 수 있으며, 기본 위치 정보를 넘길 경우 해당 위치의 기본 데이터가 새로고침 됩니다. 추가 정보가 있는 경우에는 해당 정보가 정상 처리된 후 "completion" 콜백으로 최종 처리 이벤트를 받을 수 있습니다. 이벤트에는 탭 이동된 "BaseViewController" 정보를 파라미터로 받습니다.
     - Date: 2023.04.24
     - Parameters:
        - tabIndex      : 이동할 탭 넘버 입니다.
        - seletedItem   : 추가할 데이터 입니다.
        - updateCookies : 탭 이동시 추가한 URL 정보가 디스플레이 되면 쿠키 값을 업로드 할지 여부를 받습니다. ( 추가한 데이터가 있을 경우에만 사용 가능 합니다. )
        - completion    : 탭 이동후 추가한 URL 정보가 디스플레이 되면 호출 됩니다. ( 추가한 데이터가 있을 경우에만 사용 가능 합니다. )
     - Returns:False
     */
    func setSelectedIndex( _ tabIndex : TAB_STATUS,
                           seletedItem : Any? = nil,
                           updateCookies : Bool = false,
                           completion : (( _ controller : BaseViewController ) -> Void )? = nil ){
        /// 탭 이동시 아이템이 있을 경우 아이템 데이터 우선으로 처리 합니다.
        if let tabitem = seletedItem
        {
            Slog("setSelectedIndex : \(tabIndex.rawValue), tabitem : \(tabitem)")
            switch tabIndex
            {
                /// 홈 입니다.
                case .home :
                    if let home = self.viewControllers![tabIndex.rawValue] as? HomeViewController
                    {
                        /// 탭 이동시 아이템 정보가 문자형태인지를 체크 합니다.
                        if tabitem is String,
                           NC.S(tabitem as? String).isValid
                        {
                            /// 홈 탭으로 먼저 이동 합니다.
                            TabBarView.setReloadSeleted(pageIndex: tabIndex.rawValue)
                            /// 탭 이동시 해당 item 위치로 이동 합니다.
                            home.loadMainURL(NC.S(tabitem as? String), updateCookies: updateCookies) { success in
                                if completion != nil
                                {
                                    completion!(home)
                                }
                            }
                            return
                        }
                    }
                    break
                default:break
            }
        }
        /// 아이템이 없을 경우 기본 탭 데이터를 호출 합니다.
        else
        {
            /// 해당 탭 인덱스의 Controller 을 가져 옵니다.
            if let contrller = self.viewControllers![tabIndex.rawValue] as? BaseViewController
            {
                /// 해당 탭의 웹뷰 초기화 여부를 체크 합니다.
                if let _ = contrller.webView
                {
                    /// 해당 탭 실 데이터를 초기화 합니다.
                    contrller.setDisplayData()
                }
            }
        }
        /// 탭을 이동 합니다.
        TabBarView.setReloadSeleted(pageIndex: tabIndex.rawValue)
    }
}








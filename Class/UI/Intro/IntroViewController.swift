//
//  IntroViewController.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/20.
//

import UIKit

/**
 입 최초 실행시 인트로 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
 */
class IntroViewController: BaseViewController {

    var viewModel : IntroModel = IntroModel()
    /// 앱 접근 권한 안내 입니다.
    @IBOutlet weak var permissionInfoView   : PermissionInfoView!
    /// 로고 뷰어 입니다.
    @IBOutlet weak var logoView             : UIView!
    /// 로고 애니 효과 뷰어 입니다.
    var aniView                             : LottieAniView?
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.delegate = self
        /// 로띠 뷰어를 추가합니다.
        self.aniView = LottieAniView(frame: CGRect(origin: .zero, size: self.logoView.frame.size))
        self.aniView!.setAnimationView(name: "splash", loop: true)
        self.logoView.addSubview(self.aniView!)
        self.aniView!.play()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 네트워크가 사용 가능한지 여부를 체크 합니다.
        self.viewModel.isConnectedToNetwork().sink { [self] ret in
            switch ret {
            case .checking:
                /// 네트워크 체크를 요청 합니다.
                viewModel.isNetworkChecking.send(true)
                break;
            case .connecting:
                /// 네트워크 체킹을 종료 합니다.
                viewModel.isNetworkChecking.send(completion: .finished)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.setAppChecking()
                })
                
                break;
            case .fail:
                /// 네트워크 사용 불가능으로 안내 팝업을 오픈 합니다.
                CMAlertView().setAlertView(titleText: "네트워크 연결 상태가 좋지\n않습니다", detailObject: "휴대폰 연결 상태를 확인해주세요." as AnyObject, cancelText: "확인") { event in
                    /// 시나리오상 앱 강제 종료로 되어있어 진행 ... 체크가 필요해 보입니다.
                    exit(0)
                }
                break;
            }
        }.store(in: &cancellableSet)
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     앱 기본 체크 사항을 확인 하고 디스플레이 합니다..  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setAppChecking()
    {
        /// 앱 추적 (IDFA) 허용 여부를 요청 합니다.
        self.viewModel.isTrackingAuthorization().sink { success in
            /// 앱 실드 체크 합니다.
            self.viewModel.getAppShield().sink { appShield in
                /// error 이 아닌 경우 정상 처리 합니다.
                if appShield.error != nil
                {
                    DispatchQueue.main.async(execute: {
                        /// 서비스 불가 안내 뷰어를 오픈 합니다.
                        ServiceErrorPop().show()
                    })
                }
                /// 앱 실드 정상처리 입니다.
                else
                {
                    /// 앱 시작시 기본 정보를 요청합니다.
                    self.viewModel.setAppStart().sink { result in
                        /// 서비스 불가 안내 뷰어를 오픈 합니다.
                        ServiceErrorPop().show()
                    } receiveValue: { response in
                        if let data = BaseViewModel.appStartResponse!._data
                        {
                            /// 버전 정보가 있는지를 체크 합니다.
                            if let version = data._versionInfo
                            {
                                /// 서버 버전이 앱 버전보다 높을 경우 업데이트 여부를 체크 합니다.
                                if version._version! > APP_VERSION
                                {
                                    /// 강제 업데이트 여부가 "N" 경우 안내 후 진행 합니다.
                                    if version._compulsion_update == "N"
                                    {
                                        /// 업데이트 안내 팝업 입니다.
                                        let alert = CMAlertView().setAlertView( detailObject: version._popup_msg as AnyObject )
                                        alert?.addAlertBtn(btnTitleText: "앱 업데이트", completion: { result in
                                            version._market_url!.openUrl()
                                        })
                                        alert?.addAlertBtn(btnTitleText: "다음에하기", completion: { result in
                                            /// 접근 권한 안내 팝업 오픈 합니다. ( J.D.H  VER : 1.0.0 )
                                            self.permissionInfoView.setOpenView { value in
                                                /// 접근권한 "확인" 일 경우 입니다.
                                                if value == true
                                                {
                                                    self.setOKPayStart()
                                                }
                                            }
                                        })
                                        alert?.show()
                                        return
                                    }
                                    /// 강제 업데이트 입니다.
                                    else
                                    {
                                        /// 업데이트 안내 팝업 입니다.
                                        let alert = CMAlertView().setAlertView( detailObject: version._popup_msg as AnyObject )
                                        alert?.addAlertBtn(btnTitleText: "앱 업데이트", completion: { result in
                                            version._market_url!.openUrl()
                                        })
                                        alert?.addAlertBtn(btnTitleText: "취소", completion: { result in
                                            exit(0)
                                        })
                                        alert?.show()
                                        
                                    }
                                    return
                                }
                            }
                        }
                                            
                        /// 접근 권한 안내 팝업 오픈 합니다. ( J.D.H  VER : 1.0.0 )
                        self.permissionInfoView.setOpenView { value in
                            /// 접근권한 "확인" 일 경우 입니다.
                            if value == true
                            {
                                self.setOKPayStart()
                            }
                        }
                    }.store(in: &self.cancellableSet)
                }
            }.store(in: &self.cancellableSet)
        }.store(in: &self.viewModel.cancellableSet)
    }

    
    /**
     OKPay 앱을 시작 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Throws : False
     - returns :False
     */
    func setOKPayStart() {
        /// 이전 유저 정보가 있는지를 체크하고 가져 옵니다.
        if let custItem = SharedDefaults.getKeyChainCustItem()
        {
            /// 자동 로그인 여부를 체크 합니다.
            if  custItem.auto_login,
                custItem.token != nil
            {
                /// 자동로그인을 요청 합니다.
                self.viewModel.setAutoLogin().sink { result in
                    self.setMainDisplay( loginEnabled: true )
                } receiveValue: { response in
                    if response != nil
                    {
                        Slog("NC.S(response!.code) : \(NC.S(response!.code))")
                        if NC.S(response!.code) == LOGIN_CODE._code_0000_.rawValue
                        {
                            /// 정상 로그인된 정보를 KeyChainCustItem 정보에 세팅 합니다.
                            self.viewModel.setKeyChainCustItem(NC.S(custItem.user_hp)).sink { success in
                                if success
                                {
                                    /// 로그인 여부를 활성화 합니다.
                                    BaseViewModel.loginResponse!.islogin = true
                                    /// FCM PUSH Token 정보를 업로드 합니다.
                                    self.viewModel.setFcmTokenRegister().sink { result in
                                        /// 로그인 정상처리로 메인 페이지로 이동합니다.
                                        self.setMainDisplay()
                                    } receiveValue: { response in
                                        /// 로그인 정상처리로 메인 페이지로 이동합니다.
                                        self.setMainDisplay()
                                    }.store(in: &self.viewModel.cancellableSet)
                                }
                            }.store(in: &self.viewModel.cancellableSet)
                        }
                        else
                        {
                            /// 자동 로그인을 비활성화 합니다.
                            custItem.auto_login = false
                            SharedDefaults.setKeyChainCustItem(custItem)
                            self.setMainDisplay( loginEnabled: true )
                        }
                    }
                }.store(in: &self.viewModel.cancellableSet)
                return
            }
            self.setMainDisplay( loginEnabled: true )
        }
        else
        {
            self.setMainDisplay( loginEnabled: true )
        }
    }
    
    
    /**
     메인 화면 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.04
     - Parameters:
        - loginEnabled : 로그인 페이지 디스플레이 여부를 받습니다.
     - Throws : False
     - returns :False
     */
    func setMainDisplay( loginEnabled : Bool = false ){
        let storyboard                          = UIStoryboard(name: "Main", bundle: nil)
        let tabController                       = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        /// 최초 진입을 홈으로 설정 합니다. ( 기본 설정은 0 번으로 진행 됩니다. )
        tabController.selectedIndex             = 2
        if loginEnabled == true
        {
            /// 로그인 디스플레이로 기본 배경 뷰어를 디스플레이 합니다.
            BecomeActiveView().show()
            tabController.loginDisplayFirst     = true
        }
        self.aniView!.stop()
        /// 현 페이지를 탭바 컨트롤로 변경 합니다.
        self.replaceController(viewController: tabController, animated: false) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                /// 자동 로그인으로 딥링크나 PUSH정보의 외부 데이터로 앱이 실행 되는 경우 입니다.
                if loginEnabled == false,
                   let link = BaseViewModel.shared.getInDataAppStartURL(),
                   link.isValid
                {
                    /// 메인 탭 이동 하면서 외부 데이터에서 받은 URL 페이지로 이동합니다.
                    tabController.setSelectedIndex(.home, object: link)
                }
                else
                {
                    /// 메인 탭 이동하면서 메인 페이지를 디스플레이 합니다.
                    tabController.setSelectedIndex(.home, object: WebPageConstants.URL_MAIN)
                }
                
            })
        }
    }
}



// MARK: - UINavigationControllerDelegate
extension IntroViewController : UINavigationControllerDelegate
{
    /// UINavigationControllerDelegate push/pop 애니메이션 효과를 추가 합니다.
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        /// 페이지 종료시 입니다.
        if operation == .pop
        {
            return NavigationControllerAnimated(popAnimation: navigationController.popAnimation! )
        }
        /// 기본 왼쪽으로 나오는 뷰어면 기존 지원 애니를 사용하도록 합니다.
        if navigationController.pushAnimation! == .left { return nil }
        /// 페이지 진입시 입니다.
        return NavigationControllerAnimated(pushAnimation: navigationController.pushAnimation! )
    }

}


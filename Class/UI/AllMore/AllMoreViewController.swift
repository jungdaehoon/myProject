//
//  AllMoreViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit
import WebKit



/**
 전체 (더보기) 페이지 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
*/
class AllMoreViewController: BaseViewController {

    /// 웹 페이지 디스플레이 뷰어 입니다.
    @IBOutlet weak var webDisplayView: UIView!
    /// 전체를 디스플레이할 스크롤 뷰어 입니다.
    @IBOutlet weak var scrollView   : UIScrollView!
    /// 전체를 디스플레이할 아이템 별 추가할 스텍 뷰어 입니다.
    @IBOutlet weak var stackView    : UIStackView!
    /// 뷰 모델 입니다.
    var viewModel                   : AllMoreModel = AllMoreModel()
    /// 화면 데이터 새로고침 컨트롤 입니다.
    var refreshControl              : UIRefreshControl?
    /// 최상단 유저 정보 뷰어 입니다.
    var topUserInfoView             : TopUserInfoView?
    /// 머니/포인트 정보 뷰어 입니다.
    var pointItemView               : PointItemView?
    /// 이번달 결제 정보 입니다.
    var monthInfo                   : AllMoreMenuListView?
    /// 현금영수증 정보 입니다.
    var cashReceiptInfo             : AllMoreMenuListView?
    /// 결제 서비스 입니다.
    var payServiceInfo              : AllMoreMenuListView?
    /// 혜택 메뉴 입니다.
    var boonInfo                    : AllMoreMenuListView?
    /// 이용안내 메뉴 입니다.
    var okPayServiceInfo            : AllMoreMenuListView?
    /// 최하단 로그아웃 뷰어 입니다.
    var bottomLogOutView            : BottomLogOutView?
    /// 베너 뷰어 입니다.
    var bannerView                  : BannerView?
    
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 기본 화면을 먼저 디스플레이 합니다.
        self.setDisplayView()
        self.initWebView(self.webDisplayView, target: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.viewModel.allModeResponse == nil
        {
            /// 서버에 화면 디스플레이 데이터 정보를 요청 합니다.
            self.setDisplayData()
        }        
    }
    

    
    //MARK: - 지원 메서드 입니다.
    /**
     전체 탭 페이지에 웹뷰를 히든 처리 하며 초기화 합니다.
     - Date : 2022.04.17
     */
    func setInitWebView()
    {
        /// 배경 전체 탭 컬러값으로 변경 합니다.
        self.view.backgroundColor    = UIColor(hex: 0xF6F6F6)
        /// 웹뷰 히던 여부 값을 true 변경 합니다.
        self.isWebViewHidden         = true
        /// 화면 데이터 요청후 디스플레이로 웹뷰 화면을 히든처리 힙니다.
        self.webDisplayView.isHidden = self.isWebViewHidden
        /// 웹 화면 케시를 전부 삭제 합니다.
        self.messageHandler!.setWebViewClearCache()
        /// 화면을 초기화 합니다.
        self.webView!.load(URLRequest(url: URL(string: "about:blank")!))
    }
    
    
    /**
     화면 유닛 데이터를 가져와 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.03.16
     */
    override func setDisplayData(){
        /// 전체 탭 페이지에 웹뷰를 히든 처리 하며 초기화 합니다.
        self.setInitWebView()
        /// 서버에 전제 상세 데이터를 요청 합니다.
        self.viewModel.getAllMoreInfo().sink { result in
            
        } receiveValue: { response  in
            if response != nil
            {
                self.scrollView.contentOffset = .zero
                /// 서버에서 받은 데이터 기준으로 한번더 디스플레이 합니다.
                self.setDisplayView()
            }
            
        }.store(in: &cancellableSet)
    }
    
    
    /**
     "전체" 탭에 하단 메뉴 디스플레이 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.21
     - Parameters:False
     - Throws : False
     - returns : False
     */
    func setDisplayView()
    {
        /// 최상단 뷰어를 디스플레이 합니다.
        if self.topUserInfoView == nil
        {
            self.topUserInfoView = TopUserInfoView.instanceFromNib()
            self.stackView.addArrangedSubview(self.topUserInfoView!)
        }
        else
        {
            /// 최상단 유저 정보 디스플레에 데이터를 추가합니다.
            self.topUserInfoView?.setDisplay(self.viewModel)
        }
        
        /// 연결출금 및 포인트 머니 관련 뷰어를 추가합니다.
        if self.pointItemView == nil
        {
            self.pointItemView                              = PointItemView.instanceFromNib()
            self.stackView.addArrangedSubview(self.pointItemView!)
        }
        else
        {
            self.pointItemView?.setDisplay(self.viewModel)
        }
        
        /// 이번달 관련 정보 뷰어를 추가합니다.
        if self.monthInfo == nil
        {
            self.monthInfo                                  = AllMoreMenuListView.instanceFromNib()
            var menus : [AllModeMenuListInfo]               = []
            menus.append(self.viewModel.getMenuInfo(title: "이번달 결제", subTitle: "0원", menuType: .rightimg))
            menus.append(self.viewModel.getMenuInfo(title: "이번달 적립", subTitle: "0원", menuType: .rightimg))
            self.monthInfo!.setDisplay(menus: menus)
            self.stackView.addArrangedSubview(self.monthInfo!)
        }
        else
        {
            let result = self.viewModel.allModeResponse!.result!
            var menus : [AllModeMenuListInfo]               = []
            menus.append(self.viewModel.getMenuInfo(title: "이번달 결제", subTitle: "\(result._current_month_pay_amt!.addComma())원", menuType: .rightimg))
            menus.append(self.viewModel.getMenuInfo(title: "이번달 적립", subTitle: "\(result._current_month_save_amt!.addComma())원", menuType: .rightimg))
            
            /// 화면 다시 디스플레이 요청 합니다.
            self.monthInfo!.reloadDisplay(menus, viewModel: self.viewModel)
        }
        
        
        /* /// 현 버전에서는 사용 하지 않습니다.
        /// 현금 영수증 관련 뷰어를 추가 합니다.
        if self.cashReceiptInfo == nil
        {
            self.cashReceiptInfo                    = AllMoreMenuListView.instanceFromNib()
            var menus : [AllModeMenuListInfo]       = []
            menus.append(self.viewModel.getMenuInfo(title: "현금영수증 정보", menuType: "text"))
            self.cashReceiptInfo!.setDisplay(titleName: "현금영수증", menus: menus)
            self.stackView.addArrangedSubview(self.cashReceiptInfo!)
        }
         */
        
        /// 결제서비스 영역 뷰어를 추가합니다.
        if self.payServiceInfo  == nil
        {
            self.payServiceInfo                             = AllMoreMenuListView.instanceFromNib()
            var menus : [AllModeMenuListInfo]               = []
            /// OK마켓 정보를 체크 합니다.
            if self.viewModel.isAppMenuList(menuID: .ID_GIFTYCON)
            {
                menus.append(self.viewModel.getMenuInfo(title: "OK마켓" ))
            }
            /// 제로페이 QR 결제 정보를 체크 합니다.
            //if self.viewModel.isAppMenuList(menuID: .ID_ZERO_QR)
            //{
                menus.append(self.viewModel.getMenuInfo(title: "제로페이 QR", subiCon: "NEW!", menuType: .rightimg))
            //}
            /// 제로페이 상품권 정보를 체크 합니다.
            if self.viewModel.isAppMenuList(menuID: .ID_ZERO_GIFT)
            {
                menus.append(self.viewModel.getMenuInfo(title: "제로페이 상품권",subiCon: "NEW!", menuType: .rightimg))
            }
            self.payServiceInfo!.setDisplay(titleName: "결제서비스", menus: menus)
            self.stackView.addArrangedSubview(self.payServiceInfo!)
        }
        else
        {
            self.payServiceInfo!.setDisplay(self.viewModel)
        }
        
        /// 중간 배너 뷰어를 추가 합니다.
        if self.bannerView == nil
        {
            self.bannerView                                 = BannerView.instanceFromNib()
            self.stackView.addArrangedSubview(self.bannerView!)
        }
        else
        {
            self.bannerView!.viewModel = self.viewModel
        }
        
        /// 혜택 뷰어를 추가합니다.
        if self.boonInfo == nil
        {
            self.boonInfo                                   = AllMoreMenuListView.instanceFromNib()
            var menus : [AllModeMenuListInfo]               = []
            menus.append(self.viewModel.getMenuInfo(title: "만보Go", menuType: .rightimg ))
            menus.append(self.viewModel.getMenuInfo(title: "올림pick", menuType: .rightimg ))
            /// 친구추천 정보를 체크 합니다.
            if self.viewModel.isAppMenuList(menuID: .ID_RECOMMEND_USER)
            {
                menus.append(self.viewModel.getMenuInfo(title: "친구추천",subiCon: "UPDATE!", menuType: .rightimg))
            }
            menus.append(self.viewModel.getMenuInfo(title: "뿌리Go",menuType: .rightimg))
            self.boonInfo!.setDisplay(titleName: "혜택", menus: menus)
            self.stackView.addArrangedSubview(self.boonInfo!)
        }
        else
        {
            /// 뷰모델을 연갈 합니다.
            self.boonInfo!.setDisplay(self.viewModel)
        }
        
        /// 이용안내 관련 뷰어를 추가합니다.
        if self.okPayServiceInfo == nil
        {
            self.okPayServiceInfo                           = AllMoreMenuListView.instanceFromNib()
            var menus : [AllModeMenuListInfo]               = []
            /// 이벤트 정보를 체크 합니다.
            if self.viewModel.isAppMenuList(menuID: .ID_EVENT)
            {
                menus.append(self.viewModel.getMenuInfo(title: "이벤트", menuType: .rightimg ))
            }
            /// 카카오 연동 페이지로 내부 URL 고정입니다.
            menus.append(self.viewModel.getMenuInfo(title: "고객센터", menuType: .rightimg ))
            /// FAQ 정보를 체크 합니다.
            if self.viewModel.isAppMenuList(menuID: .ID_FAQ)
            {
                menus.append(self.viewModel.getMenuInfo(title: "FAQ", menuType: .rightimg ))
            }
            /// 서비스안내 정보를 체크 합니다.
            if self.viewModel.isAppMenuList(menuID: .ID_POINT)
            {
                menus.append(self.viewModel.getMenuInfo(title: "서비스안내", menuType: .rightimg ))
            }
            /// 공지사항 정보를 체크 합니다.
            if self.viewModel.isAppMenuList(menuID: .ID_NOTICE)
            {
                menus.append(self.viewModel.getMenuInfo(title: "공지사항", menuType: .rightimg ))
            }
            self.okPayServiceInfo!.setDisplay(titleName: "이용안내", menus: menus)
            self.stackView.addArrangedSubview(self.okPayServiceInfo!)
        }
        else
        {
            self.okPayServiceInfo!.setDisplay(self.viewModel)
        }
        
        /// 최하단 로그아웃 뷰어 입니다.
        if self.bottomLogOutView == nil
        {
            self.bottomLogOutView                           = BottomLogOutView.instanceFromNib()
            self.stackView.addArrangedSubview(self.bottomLogOutView!)
        }
        else
        {
            self.bottomLogOutView!.viewModel                = self.viewModel
        }
        
        /// 새로고침 여부를 최초 한번 추가 합니다.
        if self.refreshControl == nil
        {
            self.scrollView.refreshControl = self.getRefreshController()
        }
        
        /// 새로고침 중인지를 체크 합니다.
        if self.refreshControl!.isRefreshing == true
        {
            /// 새로 고침 UI 중단 합니다.
            self.refreshControl!.endRefreshing()
        }
    }
    
    
    
    
    
    /**
     내자산 뷰어 새로고침 컨트롤러를 생성 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.17
     - returns :
        - UIRefreshControl
            + 내 자산 정보 새로고침 컨트롤을 리턴 합니다.
     */
    func getRefreshController() -> UIRefreshControl
    {
        self.refreshControl                  = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        self.refreshControl!.backgroundColor = .clear
        self.refreshControl!.tintColor       = .gray
        self.refreshControl!.isHidden        = true
        return self.refreshControl!
    }
    
    
    /**
     내자산 뷰어 새로고침 이벤트 요청 액션 입니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.17
     - Parameters:
        - refresh : 내자산 새로고침 컨트롤러 입니다.
     - returns :False
     */
    @objc func refreshTable(refresh : UIRefreshControl)
    {
        /// 화면 데이터를 요청하여 디스플레이 합니다.
        self.setDisplayData()
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        /// 설정 URL 정보를 가져와 해당 페이지로 이동합니다.
        self.viewModel.getAppMenuList(menuID: .ID_SETTING).sink { url in
            self.view.setDisplayWebView(url)
        }.store(in: &self.viewModel.cancellableSet)
    }
}



//MARK: - UIScrollViewDelegate
extension AllMoreViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        /// 베너 뷰어에 스크롤 정보를 넘깁니다.
        self.bannerView?.scrollViewDidScroll(scrollView)
    }
}



// MARK: - WKNavigationDelegate
extension AllMoreViewController {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        
        preferences.preferredContentMode = .mobile
        
        let request = navigationAction.request
        let optUrl = request.url
        let optUrlScheme = optUrl?.scheme
        
        guard let url = optUrl, let scheme = optUrlScheme
            else {
                return decisionHandler(.cancel, preferences)
        }
        
        Slog("url : \(url)")

        /// 중간 중단으로 메인 페이지 이동 URL 확인 경우 입니다. ( 추후 WebToApp 으로 변경예정 )
        if url.description.contains("matcs/main.do")
        {
            /// 전체 탭 페이지에 웹뷰를 히든 처리 하며 초기화 합니다.
            self.setInitWebView()
            decisionHandler(.cancel, preferences)
            return
        }
        
        
        if( scheme != "http" && scheme != "https" ) {
            if( scheme == "ispmobile" && !UIApplication.shared.canOpenURL(url) ) {  //ISP 미설치 시
                "http://itunes.apple.com/kr/app/id369125087?mt=8".openUrl()
            } else if( scheme == "kftc-bankpay" && !UIApplication.shared.canOpenURL(url) ) {    //BANKPAY 미설치 시
                "http://itunes.apple.com/us/app/id398456030?mt=8".openUrl()
            } else {
                if( UIApplication.shared.canOpenURL(url) ) {
                    url.description.openUrl()
                } else {
                    //1. App 미설치 확인
                    //2. info.plist 내 scheme 등록 확인
                }
            }
        }
        decisionHandler(.allow, preferences)
    }
}


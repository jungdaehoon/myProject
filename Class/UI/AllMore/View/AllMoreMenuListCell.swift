//
//  AllMoreMenuListCell.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit

/**
 아이콘 타입 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.07
 
        + not     : 디스플레이 하지 않습니다.
        + new     : "NEW!" 아이콘을 디스플레이 합니다.
        + update. : "update!" 아이콘을 디스플레이 합니다.
 */
enum typeIconStatus {
    /// 디스플레이 하지 않습니다.
    case not
    /// "new!" 아이콘을 디스플레이 합니다.
    case new
    /// "update!" 아이콘을 디스플레이 합니다.
    case update
}

/**
 전체 탭 뷰어 ( 이번달 결제/적립부터 이용안내 까지 영역 ) 의 셀 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.07
 */
class AllMoreMenuListCell: UITableViewCell {

    var viewModel : AllMoreModel?
    /// 타이틀 문구 입니다.
    @IBOutlet weak var titleName    : UILabel!
    /// 오른쪽 안내 정보 문구 입니다.
    @IBOutlet weak var subTitle     : UILabel!
    /// 타이틀 문구 오른쪽 안내 아이콘 입니다. ( "new!", "update!" )
    @IBOutlet weak var typeiConView : UIView!
    /// 타이틀 문구 오른쪽 안내 아이콘 문구 입니다. ( "new!", "update!" )
    @IBOutlet weak var typeiConText : UILabel!
    /// 오른쪽 "등록" 문구 입니다.
    @IBOutlet weak var rightSubText : UIView!
    /// 오른쪽 이동 아이콘 이미지 입니다.
    @IBOutlet weak var rightImage: UIImageView!
    /// 셀 선택시 버튼 입니다.
    @IBOutlet weak var seletedBtn: UIButton!
    
    /// 타이틀 오른쪽 아이콘 디스플레이 여부 입니다.
    var typeIConStatus              : typeIconStatus = .not
    /// 인포 정보 입니다.
    var menuInfo                    : AllModeMenuListInfo?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     메뉴 인포정보를 받아 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.07
     - Parameters:
        - menuInfo : 메뉴 리스트 인포 정보 입니다.
        - viewModel : 뷰 모델을 받습니다.
     - Throws: False
     - Returns:False
     */
    func setDisplay( _ menuInfo : AllModeMenuListInfo, viewModel : AllMoreModel? )
    {
        /// 모델 정보를 받습니다.
        self.viewModel = viewModel
        /// 타이틀 정보를 추가 디스플레이 합니다.
        self.titleName.text = menuInfo.title
        
        switch menuInfo.menuType
        {
            /// 문구를 디스플레이 합니다.
            case .text:
                self.rightImage.isHidden    = true
                self.rightSubText.isHidden  = false
            /// 오른쪽 이동 이미지를 디스플레이 합니다.
            case .rightimg:
                self.rightImage.isHidden    = false
                self.rightSubText.isHidden  = true
            default:break
        }
        
        /// 오른쪽 서브로 디스플레이할 문구가 있는지를 체크 합니다.
        if menuInfo.subTitle!.count > 0
        {
            /// 추가 정보를 디스플레이 하도록 활성화 합니다.
            self.subTitle.isHidden  = false
            /// 오른쪽 서브에 문구를 추가 합니다.
            self.subTitle.text      = menuInfo.subTitle!
        }
        else
        {
            /// 추가 정보를 디스플레이 하도록 비 활성화 합니다.
            self.subTitle.isHidden = true
        }
                
        /// 타이틀 오른쪽 디스플레이할 아이콘 문구가 있는지를 체크 합니다.
        if menuInfo.subiCon!.count > 0
        {
            /// 타이틀 문구 오른쪽 아이콘을 활성화 합니다.
            self.typeiConView.isHidden  = false
            /// 타이틀 아이콘의 문구를 추가합니다.
            self.typeiConText.text      = menuInfo.subiCon!
            /// 문구를 디스플레이 합니다.
            if menuInfo.subiCon! == "NEW!"
            {
                self.typeiConView.backgroundColor = .OKColor
            }
            /// 오른쪽 이동 이미지를 디스플레이 합니다.
            else
            {
                self.typeiConView.backgroundColor = UIColor(red: 255/255, green: 129/255, blue: 37/255, alpha: 1.0)
            }
        }
        else
        {
            /// 타이틀 문구 오른쪽 아이콘을 비 활성화 합니다.
            self.typeiConView.isHidden  = true
        }
        
        
        if menuInfo.title == "이번달 결제"
        {
            if let model = self.viewModel
            {
                let result              = model.allModeResponse!.result!
                let attributedString    = NSMutableAttributedString(string: "이번달 결제 \(result._current_month_pay_cnt!)건", attributes: [
                  .font: UIFont(name: "Pretendard-Medium", size: 16.0)!
                ])
                attributedString.addAttribute(.font, value: UIFont(name: "Pretendard-SemiBold", size: 16.0)!, range: NSRange(location: 6, length: 3))
                self.titleName.attributedText = attributedString                
            }
        }

        /// 현 메뉴정보를 넘깁니다.
        self.menuInfo = menuInfo
        /// 선택시 하이라이트 배경입니다.
        self.seletedBtn.setBackgroundImage(UIColor(hex: 0xEEEEEE).createImageFromUIColor(), for: .highlighted)
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        Slog("title name : \(self.menuInfo!.title!)")
        if let model = self.viewModel {
            if self.menuInfo!.title! == "이번달 결제"
            {
                /// 결제 페이지는 추후 개발 후 연동 예정 입니다.
                self.setDisplayWebView(WebPageConstants.URL_TOTAL_PAY_LIST)
            }
            
            if self.menuInfo!.title! == "OK마켓"
            {
                ///  OK마켓 URL 정보를 가져 옵니다.
                model.getAppMenuList(menuID: .ID_GIFTYCON).sink(receiveValue: { url in
                    if url.isValid
                    {
                        self.setDisplayWebView( url )
                    }
                }).store(in: &model.cancellableSet)
            }
            
            if self.menuInfo!.title! == "제로페이 QR"
            {
                /// 간편 결제 인증 처리 팝업 입니다.
                self.setZeroPayTermsViewDisplay()
            }
         
            if self.menuInfo!.title! == "제로페이 상품권"
            {
                /// 제로페이 상품권 URL 정보를 가져 옵니다.
                model.getAppMenuList(menuID: .ID_ZERO_GIFT).sink(receiveValue: { url in
                    if url.isValid
                    {
                        self.setDisplayWebView( url, modalPresent: true, pageType: .zeropay_type , titleBarHidden: true )
                    }
                }).store(in: &model.cancellableSet)
            }
            if self.menuInfo!.title! == "거래내역"
            {
                self.setDisplayWebView(WebPageConstants.URL_ACCOUNT_TRANSFER_LIST)
            }
            
            if self.menuInfo!.title! == "OK머니 충전"
            {
                self.setDisplayWebView(WebPageConstants.URL_RECHARE_MONEY)
            }
            
            if self.menuInfo!.title! == "OK머니 송금"
            {
                self.setDisplayWebView(WebPageConstants.URL_REMITTANCE_MONEY)
            }
            
            if self.menuInfo!.title! == "OK머니 받기"
            {
                self.setDisplayWebView(WebPageConstants.URL_MYP_RECEIVE)
            }
            
            if self.menuInfo!.title! == "보유중인 NFT"
            {
                self.setDisplayWebView(WebPageConstants.URL_NFT_OWN_LIST)
            }
            
            if self.menuInfo!.title! == "NFT 거래내역"
            {
                self.setDisplayWebView(WebPageConstants.URL_NFT_TRANS_LIST)
            }
            
            if self.menuInfo!.title! == "발행한 NFT"
            {
                self.setDisplayWebView(WebPageConstants.URL_NFT_ISSUED_LIST)
            }
            
            if self.menuInfo!.title! == "수집한 NFT"
            {
                self.setDisplayWebView(WebPageConstants.URL_NFT_COLLECTED_LIST)
            }
            
            if self.menuInfo!.title! == "만보Go"
            {
                self.toPedometerPage()
            }
            
            if self.menuInfo!.title! == "올림pick"
            {
                self.setDisplayWebView(WebPageConstants.URL_OLIMPICK_LIST)
            }
            
            if self.menuInfo!.title! == "친구추천"
            {
                /// 친추추천 URL 정보를 가져 옵니다.
                model.getAppMenuList(menuID: .ID_RECOMMEND_USER).sink(receiveValue: { url in
                    if url.isValid
                    {
                        self.setDisplayWebView( url )
                    }
                }).store(in: &model.cancellableSet)
            }
            
            if self.menuInfo!.title! == "뿌리Go"
            {
                self.setDisplayWebView(WebPageConstants.URL_MY_RELATIONSHIP)
            }
            
            if self.menuInfo!.title! == "이벤트"
            {
                /// 이벤트 URL 정보를 가져 옵니다.
                model.getAppMenuList(menuID: .ID_EVENT).sink(receiveValue: { url in
                    if url.isValid
                    {
                        self.setDisplayWebView( url )
                    }
                }).store(in: &model.cancellableSet)
            }
            
            if self.menuInfo!.title! == "고객센터"
            {
                WebPageConstants.URL_KAKAO_CONTACT.openUrl()
            }
            
            if self.menuInfo!.title! == "FAQ"
            {
                /// FAQ URL 정보 입니다.
                model.getAppMenuList(menuID: .ID_FAQ).sink(receiveValue: { url in
                    if url.isValid
                    {
                        self.setDisplayWebView( url )
                    }
                }).store(in: &model.cancellableSet)
            }
            
            if self.menuInfo!.title! == "OK포인트 안내"
            {
                /// OK포인트 안내 (서비스안내) URL 입니다.
                model.getAppMenuList(menuID: .ID_POINT).sink(receiveValue: { url in
                    if url.isValid
                    {
                        self.setDisplayWebView( url )
                    }
                }).store(in: &model.cancellableSet)
            }
            
            if self.menuInfo!.title! == "공지사항"
            {
                /// 공지사항 URL 입니다.
                model.getAppMenuList(menuID: .ID_NOTICE).sink(receiveValue: { url in
                    if url.isValid
                    {
                        self.setDisplayWebView( url )
                    }
                }).store(in: &model.cancellableSet)
            }
        }
    }
}



extension AllMoreMenuListCell
{
    //MARK: - 지원 메서드 입니다.
    /**
     제로페이 결제 페이지로 이동 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.07
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func toQRZeroPayPage()
    {
        /// 제로페이 선택 안내 팝업 디스플레이 합니다.
        OKZeroPayTypeBottomView().setDisplay { event in
            switch event
            {
                /// 결제 페이지로 이동 합니다.
                case .paymeny:
                    let viewController = OkPaymentViewController()
                    viewController.modalPresentationStyle = .overFullScreen
                    self.pushViewController(viewController, animated: true, animatedType: .up)
                    break
                    /// 제로페이 가맹점 검색 네이버 지도 페이지로 이동합니다.
                case .location:
                    /// 제로페이 가맹점 검색 URL 입니다.
                    let urlString = "https://map.naver.com/v5/search/%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4%20%EA%B0%80%EB%A7%B9%EC%A0%90?c=15,0,0,0,dh".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                        /// 제로페이 가맹점 네이버 지도를 요청 합니다.
                    self.setDisplayWebView(urlString!, modalPresent: true, animatedType: .left, titleName: "가맹점 찾기", titleBarType: 1, titleBarHidden: false)
                    break
                default:break
            }
        }
        return
    }
    
    
    /**
     만보고 페이지로 이동 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.20
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func toPedometerPage()
    {
        /// 만보기 접근 권한을 체크 합니다.
        HealthKitManager.healthCheck { value in
            /// 사용 가능합니다.
            if value
            {
                /// 만보기 약관 동의 여부를 체크 합니다.
                self.viewModel?.getPTTermAgreeCheck().sink(receiveCompletion: { result in
                    
                }, receiveValue: { response  in
                    if response != nil
                    {
                        /// 약관 동의 여부를 체크 합니다.
                        if self.viewModel!.PTAgreeResponse!.data!.pedometer_use_yn! == "N"
                        {
                            /// 약관동의 여부를 "N" 변경 합니다.
                            SharedDefaults.default.pedometerTermsAgree = "N"
                            /// 약관 동의 "N" 으로 약관동의 팝업을 디스플레이 합니다.
                            self.setPedometerTermsViewDisplay()
                        }
                        else
                        {
                            /// 약관동의 여부를 "Y" 변경 합니다.
                            SharedDefaults.default.pedometerTermsAgree = "Y"
                            /// 만보고 페이지로 이동 합니다.
                            DispatchQueue.main.async {
                                if let controller = PedometerViewController.instantiate(withStoryboard: "Main")
                                {
                                    self.pushViewController(controller, animated: true, animatedType: .up)
                                }
                            }
                        }
                    }
                }).store(in: &self.viewModel!.cancellableSet)
            }
            else
            {
                /// 만보기 서비스 이용활성화를 위해 설정으로 이동 안내 팝업 오픈 입니다.
                CMAlertView().setAlertView(detailObject: "만보기 서비스이용을 위해  \n 건강앱에 들어가셔서 데이터 접근 권한을 허용해주세요." as AnyObject, cancelText: "확인") { event in
                    "x-apple-health://".openUrl()
                }
            }
        }
    }
    
    
    /**
     만보고 약관동의 페이지를 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.20
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setPedometerTermsViewDisplay()
    {
        let terms = [TERMS_INFO.init(title: "서비스 이용안내", url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S001"),
                     TERMS_INFO.init(title: "개인정보 수집·이용 동의",url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S002")]
        BottomTermsView().setDisplay( target: self.viewController, "도전! 만보GO 서비스를 이용하실려면\n이용약관에 동의해주세요",
                                     termsList: terms) { value in
            /// 동의/취소 여부를 받습니다.
            if value == .success
            {
                /// 약관동의 요청합니다.
                self.viewModel!.setPTTermAgreeCheck().sink { result in
                    
                } receiveValue: { response in
                    if response != nil
                    {
                        /// 약관동의가 정상처리 되었습니다
                        if response?.code == "0000"
                        {
                            
                            
                            /// 약관동의 여부를 "Y" 변경 합니다.
                            SharedDefaults.default.pedometerTermsAgree = "Y"
                            DispatchQueue.main.async {
                                if let controller = PedometerViewController.instantiate(withStoryboard: "Main")
                                {
                                    self.pushViewController(controller, animated: true, animatedType: .up)
                                }
                            }
                        }
                        /// 약관 동의 요청에 실패 하였습니다.
                        else
                        {
                            
                        }
                    }
                }.store(in: &self.viewModel!.cancellableSet)
            }
            else
            {
                
            }
        }
    }
    
    
    /**
     올림pick 약관동의 페이지를 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.16
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setOlimpickTermsViewDisplay()
    {
        let terms = [TERMS_INFO.init(title: "약관내용 보러가기", url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S001")]
        BottomTermsView().setDisplay( target: self.viewController, "올림pick 서비스를 이용하실려면\n이용약관에 동의해주세요",
                                     termsList: terms) { value in
            /// 동의/취소 여부를 받습니다.
            if value == .success
            {
                self.setDisplayWebView(WebPageConstants.URL_OLIMPICK_LIST)
            }
            else
            {
                
            }
        }
        
    }
    
    
    /**
     제로페이 약관동의 페이지를 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.16
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setZeroPayTermsViewDisplay()
    {
        /// 제로페이 약관 동의 체크 입니다.
        self.viewModel!.getZeroPayTermsCheck().sink { result in
        } receiveValue: { model in
            if let check = model,
               let data = check._data {
                if data._didAgree!
                {
                    /// 제로페이 이동전 하단 팝업 오픈 합니다.
                    self.setBottomZeroPayInfoView()
                    return
                }
            }
            
            /// 약관 동의 팝업을 오픈 합니다.
            let terms = [TERMS_INFO.init(title: "제로페이 서비스 이용약관", url: WebPageConstants.URL_ZERO_PAY_AGREEMENT + "?terms_cd=S001"),
                         TERMS_INFO.init(title: "개인정보 수집, 이용 동의",url: WebPageConstants.URL_ZERO_PAY_AGREEMENT + "?terms_cd=S002")]
            BottomTermsView().setDisplay( target: self.viewController, "제로페이 서비스를 이용하실려면\n이용약관에 동의해주세요",
                                         termsList: terms) { value in
                /// 동의/취소 여부를 받습니다.
                if value == .success
                {
                    /// 제로페이 약관에 동의함을 저장 요청 합니다.
                    self.viewModel!.setZeroPayTermsAgree().sink { result in
                    } receiveValue: { model in
                        if let agree = model,
                           agree.code == "0000"
                        {
                            /// 제로페이 이동전 하단 팝업 오픈 합니다.
                            self.setBottomZeroPayInfoView()
                        }
                    }.store(in: &self.viewModel!.cancellableSet)
                }
            }
            
        }.store(in: &self.viewModel!.cancellableSet)
    }
    
    
    /**
     제로페이 결제 이동 하단 팝업뷰를 오픈 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setBottomZeroPayInfoView()
    {
        /// 제로페이 선택 안내 팝업 디스플레이 합니다.
        OKZeroPayTypeBottomView().setDisplay { event in
            switch event
            {
                /// 결제 페이지로 이동 합니다.
                case .paymeny:
                    let viewController = OkPaymentViewController()
                    viewController.modalPresentationStyle = .overFullScreen
                    self.viewController.pushController(viewController, animated: true, animatedType: .up)
                    break
                    /// 제로페이 가맹점 검색 네이버 지도 페이지로 이동합니다.
                case .location:
                    /// 제로페이 가맹점 검색 URL 입니다.
                    let urlString = "https://map.naver.com/v5/search/%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4%20%EA%B0%80%EB%A7%B9%EC%A0%90?c=15,0,0,0,dh".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    /// 제로페이 가맹점 네이버 지도를 요청 합니다.
                    self.viewController.view.setDisplayWebView(urlString!, modalPresent: true, animatedType: .left, titleName: "가맹점 찾기", titleBarType: 1, titleBarHidden: false)
                    
                    break
                default:break
            }
        }
        return
    }
}


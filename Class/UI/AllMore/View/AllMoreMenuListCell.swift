//
//  AllMoreMenuListCell.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit

/**
 아이콘 타입 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
 
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
 전체 탭 뷰어 ( 이번달 결제/적립부터 이용안내 까지 영역 ) 의 셀 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
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
     메뉴 인포정보를 받아 디스플레이 합니다.
     - Date : 2023.03.07
     - Parameters:
        - menuInfo : 메뉴 리스트 인포 정보 입니다.
     - Throws : False
     - returns :False
     */
    func setDisplay( _ menuInfo : AllModeMenuListInfo )
    {
        
        
        /// 타이틀 정보를 추가 디스플레이 합니다.
        self.titleName.text = menuInfo._title
        
        /// 메뉴 타입정보가 있을 경우 디스플레이 합니다
        if menuInfo._menuType!.count > 0
        {
            /// 문구를 디스플레이 합니다.
            if menuInfo._menuType == "text"
            {
                self.rightImage.isHidden    = true
                self.rightSubText.isHidden  = false
            }
            /// 오른쪽 이동 이미지를 디스플레이 합니다.
            else
            {
                self.rightImage.isHidden    = false
                self.rightSubText.isHidden  = true
            }
        }
        
        /// 오른쪽 서브로 디스플레이할 문구가 있는지를 체크 합니다.
        if menuInfo._subTitle!.count > 0
        {
            /// 추가 정보를 디스플레이 하도록 활성화 합니다.
            self.subTitle.isHidden  = false
            /// 오른쪽 서브에 문구를 추가 합니다.
            self.subTitle.text      = menuInfo._subTitle!
        }
                
        /// 타이틀 오른쪽 디스플레이할 아이콘 문구가 있는지를 체크 합니다.
        if menuInfo._subiCon!.count > 0
        {
            /// 타이틀 문구 오른쪽 아이콘을 활성화 합니다.
            self.typeiConView.isHidden  = false
            /// 타이틀 아이콘의 문구를 추가합니다.
            self.typeiConText.text      = menuInfo._subiCon!
            /// 문구를 디스플레이 합니다.
            if menuInfo._subiCon! == "NEW!"
            {
                self.typeiConView.backgroundColor = UIColor(red: 255/255, green: 83/255, blue: 0/255, alpha: 1.0)
            }
            /// 오른쪽 이동 이미지를 디스플레이 합니다.
            else
            {
                self.typeiConView.backgroundColor = UIColor(red: 255/255, green: 129/255, blue: 37/255, alpha: 1.0)
            }
        }
        
        if menuInfo._title == "이번달 결제"
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
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        print("title name : \(self.menuInfo!._title!)")
        
        if self.menuInfo!._title! == "이번달 결제"
        {
            /// 결제 페이지는 추후 개발 후 연동 예정 입니다.
            self.setDisplayWebView(WebPageConstants.URL_TOTAL_PAY_LIST)
        }
        
        if self.menuInfo!._title! == "이번달 적립"
        {
            self.setDisplayWebView(WebPageConstants.URL_POINT_TRANSFER_LIST + "?tran_kn=1")
        }
        
        if self.menuInfo!._title! == "OK마켓"
        {
            self.setDisplayWebView(WebPageConstants.URL_GIFT_LIST)
        }
        if self.menuInfo!._title! == "제로페이 QR"
        {
            /// 인증 처리 팝업 입니다.
            self.setZeroPayTermsViewDisplay()
            
        }
        if self.menuInfo!._title! == "제로페이 상품권"
        {
            /// 전체 화면 제로페이 상품권 웹 페이지 디스플레이 입니다.
        }
        
        
        if self.menuInfo!._title! == "만보Go"
        {
            self.toPedometerPage()
        }
        if self.menuInfo!._title! == "올림pick"
        {
            self.setDisplayWebView(WebPageConstants.URL_OLIMPICK_LIST)
        }
        if self.menuInfo!._title! == "친구추천"
        {
            self.setDisplayWebView(WebPageConstants.URL_RECOMMEND_USER)
        }
        if self.menuInfo!._title! == "뿌리Go"
        {
            self.setDisplayWebView(WebPageConstants.URL_MY_RELATIONSHIP)
        }
        
        if self.menuInfo!._title! == "이벤트"
        {
            self.setDisplayWebView(WebPageConstants.URL_EVENT_LIST)
        }
        if self.menuInfo!._title! == "고객센터"
        {
            WebPageConstants.URL_KAKAO_CONTACT.openUrl()
        }
        if self.menuInfo!._title! == "FAQ"
        {
            self.setDisplayWebView(WebPageConstants.URL_FAQ_LIST)
        }
        if self.menuInfo!._title! == "서비스안내"
        {
            self.setDisplayWebView(WebPageConstants.URL_POINT_INFO)
        }
        if self.menuInfo!._title! == "공지사항"
        {
            self.setDisplayWebView(WebPageConstants.URL_NOTICE_LIST)
        }
        
    }
}



extension AllMoreMenuListCell
{
    //MARK: - 지원 메서드 입니다.
    /**
     제로페이 결제 페이지로 이동 합니다.
     - Date : 2023.03.07
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func toQRZeroPayPage()
    {
        let viewController = OkPaymentViewController()
        viewController.modalPresentationStyle = .overFullScreen
        self.viewController.present(viewController, animated: true)
    }
    
    
    /**
     만보고 페이지로 이동 합니다.
     - Date : 2023.03.20
     - Parameters:False
     - Throws : False
     - returns :False
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
                                let mainStoryboard          = UIStoryboard(name: "Main", bundle: nil)
                                let vc                      = mainStoryboard.instantiateViewController(withIdentifier: "pedometerVC") as? PedometerViewController
                                vc?.modalPresentationStyle  = .overFullScreen
                                self.viewController.navigationController?.pushViewController(vc!, animated: true)
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
     만보고 약관동의 페이지를 디스플레이 합니다.
     - Date : 2023.03.20
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setPedometerTermsViewDisplay()
    {
        let terms = [TERMS_INFO.init(title: "서비스 이용안내", url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S001"),TERMS_INFO.init(title: "개인정보 수집·이용 동의",url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S002")]
        BottomTermsView().setDisplay( target: self.viewController, "도전! 만보GO 서비스를 이용하실려면\n이용약관에 동의해주세요",
                                     termsList: terms) { value in
            /// 동의/취소 여부를 받습니다.
            if value == .success
            {
                /// 약관동의 처리를 요청합니다.
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
                                let mainStoryboard          = UIStoryboard(name: "Main", bundle: nil)
                                let vc                      = mainStoryboard.instantiateViewController(withIdentifier: "pedometerVC") as? PedometerViewController
                                vc?.modalPresentationStyle  = .overFullScreen
                                self.viewController.navigationController?.pushViewController(vc!, animated: true)
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
     올림pick 약관동의 페이지를 디스플레이 합니다.
     - Date : 2023.03.16
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setOlimpickTermsViewDisplay()
    {
        //URL_OLIMPICK_LIST
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
     제로페이 약관동의 페이지를 디스플레이 합니다.
     - Date : 2023.03.16
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setZeroPayTermsViewDisplay()
    {
        //URL_OLIMPICK_LIST
        let terms = [TERMS_INFO.init(title: "약관내용 보러가기", url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S001")]
        BottomTermsView().setDisplay( target: self.viewController, "제로페이 서비스를 이용하실려면\n이용약관에 동의해주세요",
                                     termsList: terms) { value in
            /// 동의/취소 여부를 받습니다.
            if value == .success
            {
                self.toQRZeroPayPage()
            }
            else
            {
                
            }
        }
        
    }
}


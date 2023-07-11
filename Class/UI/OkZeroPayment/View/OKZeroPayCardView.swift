//
//  OKZeroPayCardView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/28.
//

import UIKit

/**
 카드 뷰어에 버튼 이벤트 값 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.06.15
 */
enum CARD_BTN_EVENT : Int {
    /// 카드 금액 히든 이벤트 입니다.
    case payhidden      = 10
    /// 카드 금액 디스플레이 입니다.
    case paydisplay     = 11
    /// 은행 선택 버튼 입니다.
    case bankchoice     = 12
    /// 카드 선택 이벤트  입니다.
    case cardchoice     = 13
    /// 배너 선택 이벤트  입니다.
    case bannerchoice   = 14
    /// 하단 금액 온오프 입니다.
    case bottompayonoff = 15
    /// 전체 화면 디스플레이 입니다.
    case fullDisplay    = 16
}

/**
 디스플레이 타입  값 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.06.15
 */
enum DISPLAY_TYPE : Int {
    /// 카드  디스플레이 입니다.
    case okmoney    = 10
    /// 계좌 연결  디스플레이 입니다.
    case account    = 11
    /// 배너  디스플레이 입니다.
    case banner     = 12
}


/**
 제로페이 결제 가능 카드 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.04.28
 */
class OKZeroPayCardView: UIView {
    var viewModel : OKZeroViewModel = OKZeroViewModel()
    /// 배너 뷰어어 입니다.
    @IBOutlet weak var bannerView: UIView!
    /// 카드하단 디스플레이 안내 뷰어 입니다.
    @IBOutlet weak var bottomDisplayInfoView: UIView!
    /// 카드 하단 디스플레이시 잔액 보기/숨김 뷰어 입니다.
    @IBOutlet weak var bottomDisplayMoneyOnOff: UIView!
    /// 카드 하단 디스플레이시 보기/숨기 버튼 입니다.
    @IBOutlet weak var bottomDisplayMoneyOnoffBtn: UIButton!
    /// 카드 하단 디스플레이시 안내 문구 입니다.
    @IBOutlet weak var bottomDisplayInfoText: UILabel!
    /// 카드 하단 디스플레이시 타입 문구 입니다.
    @IBOutlet weak var bottomDisplayTypeText: UILabel!
    /// 카드 하단 디스플레이시 잔액 정보 입니다.
    @IBOutlet weak var bottomDisplayMoneyText: UILabel!
    /// 카드 하단 디스플레이시 잔액 디스플레이 뷰어 입니다.
    @IBOutlet weak var bottomDisplayMoneyView: UIView!
    /// 카드 하단 디스플레이시 "잔액숨김"  문구 입니다.
    @IBOutlet weak var bottomDisplayMoneyHiddenText: UILabel!
    /// 카드 하단 계좌 연결 카드 경우 상세 정보  입니다.
    @IBOutlet weak var bottomDisplayAccountInfoText: UILabel!
    /// 카드 하단 디스플레이시 배경 컬러 입니다.
    @IBOutlet weak var bottomDisplayCardBGColor: UILabel!
    /// 카드 모드일 경우 총 카드 뷰어 입니다.
    @IBOutlet weak var cardView: UIView!
    /// 카드 배경 컬러 입니다.
    @IBOutlet weak var cardBGColor: UILabel!
    
    /// 카드 타이틀 문구 입니다.
    @IBOutlet weak var titleText: UILabel!
    /// 카드 금액 정보 뷰어 입니다.
    @IBOutlet weak var payInfoView: UIView!
    /// 카드 금액 정보 입니다.
    @IBOutlet weak var payInfoMoney: UILabel!
    /// 카드 금액정보 "숨김" 선택시 디스플레이 뷰어 입니다.
    @IBOutlet weak var payHiddenView: UIView!
    /// 서브 상세 설명 정보 입니다.
    @IBOutlet weak var subInfoText: UILabel!
    /// 서브 상세 문구 위치 변경으로 상당 포지선을 가집니다.
    @IBOutlet weak var subInfoTextTop: NSLayoutConstraint!
    /// 연결 계좌 정보를 받습니다.
    @IBOutlet weak var accountInfoText: UILabel!
    /// 카드 그라데이션 배경 컬러값 저장 입니다.
    var saveBgColors : ( start : UIColor, end : UIColor)? = nil
    /// 디스플레이 타입을 받습니다.
    var displayType : DISPLAY_TYPE = .okmoney
    
    
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     카드 디스플레이 할 정보를 받아 설정 합니다. ( J.D.H VER : 1.0.0 )
     - Description:디스플레이 타입은 기본. "okmoney" 로 사용되며 배너 타입 경우 카드를 히든 처리 하며, 컬러값을 "setCardBGColor" 에 전달해 배경 컬러를 적용 합니다.
     - Date: 2023.06.15
     - Parameters:
        - displayType : 화면에 그려질 타입을 받습니다. ( default : okmoney )
        - colors : 그라데이션 적용할 컬러값을 받습니다.
        - model : 제로페이 간편결제 머니 상세 정보 모델을 받습니다.
     - Throws: False
     - Returns:False
     */
    func setDisplayView( displayType : DISPLAY_TYPE = .okmoney, colors : ( start : UIColor, end : UIColor)? = nil, model : ZeroPayOKMoneyResponse? = nil  ){
        self.setCardBGColor(colors: colors)
        switch displayType {
        case .okmoney:
            self.titleText.text         = "OK머니로 제로페이 결제"
            self.subInfoText.text       = "부족한 금액은 충전 후 결제 됩니다."
            if let okmoney = model,
               let data    = okmoney._data,
               let account = data._mainAccount
            {
                /// 계좌 미존재 여부 입니다.
                if account._hasNoMainAccount!
                {
                    /// 안내 정보를 디스플레이 합니다.
                    self.accountInfoText.text   = account._noMainAccountMsg!
                    return
                }
                
                /// 계좌 재인증 여부 입니다.
                if account._isNeedToReauthorize!
                {
                    /// 안내 정보를 디스플레이 합니다.
                    self.accountInfoText.text   = account._needToReAuthorizeMsg!
                    return
                }
                                
                /// 계좌 정보를 디스플레이 합니다.
                self.accountInfoText.text   = "\(account._bankName!) \(account._lastAccountNo!)"
            }
            self.accountInfoText.text   = ""
            break
        case .account:
            self.payInfoView.isHidden   = true
            self.payHiddenView.isHidden = true
            self.titleText.text         = "은행계좌에서 제로페이 결제"
            self.subInfoText.text       = "결제금액만큼 즉시 출금되어 결제됩니다."
            self.accountInfoText.text   = ""
            break
        case .banner:
            self.cardView.isHidden      = true
            self.bannerView.isHidden    = false
            break
        }
        
    }
    
    
    /**
     카드 디스플레이 할 정보를 받아 설정 합니다. ( J.D.H VER : 1.0.0 )
     - Description:디스플레이 타입은 기본. "okmoney" 로 사용되며 배너 타입 경우 카드를 히든 처리 하며, 컬러값을 "setCardBGColor" 에 전달해 배경 컬러를 적용 합니다.
     - Date: 2023.06.15
     - Parameters:
        - displayType : 화면에 그려질 타입을 받습니다. ( default : okmoney )
        - colors : 그라데이션 적용할 컬러값을 받습니다.
        - model : 제로페이 간편결제 머니 상세 정보 모델을 받습니다.
     - Throws: False
     - Returns:False
     */
    func setDisplayChange( bottomMode : Bool = true, model : ZeroPayOKMoneyResponse? = nil ){
        if let okmoney = model,
           let card = okmoney._data {
            if bottomMode == true
            {
                /// 하단 모드  정보를 받아 하단 모드 뷰어를 온오프 합니다.
                self.bottomDisplayInfoView.isHidden = false
                switch displayType {
                case .okmoney:
                    /// 계좌 연결 카드 상세 정보를 히든 처리 합니다.
                    self.bottomDisplayAccountInfoText.isHidden  = true
                    /// 카드 타입 문구를 디스플레이 합니다.
                    self.bottomDisplayTypeText.text            = "머니"
                    /// 카드 잔액 온오프 뷰어를 디스플레이 합니다.
                    self.bottomDisplayMoneyOnOff.isHidden       = false
                    /// 카드 안내 정보를 디스플레이 합니다.
                    self.bottomDisplayInfoText.text             = "부족한 금액은 충전 후 결제 됩니다."
                    if card._isBalanceShow!
                    {
                        /// 숨김 문구로 변경 합니다.
                        self.bottomDisplayMoneyOnoffBtn.setTitle("숨김", for: .normal)
                        /// 카드 잔액 정보 뷰어를 디스플레이 합니다.
                        self.bottomDisplayMoneyView.isHidden        = false
                        /// 카드 잔액정보를 추가합니다.
                        self.bottomDisplayMoneyText.text            = "\(card._balance!.addComma())"
                        /// 카드 "잔액 숨김" 뷰어를 히든 처리 합니다.
                        self.bottomDisplayMoneyHiddenText.isHidden  = true
                    }
                    else
                    {
                        /// 보기 문구로 변경 합니다.
                        self.bottomDisplayMoneyOnoffBtn.setTitle("보기", for: .normal)
                        /// 카드 잔액정보를 "잔액 숨김" 으로 변경 합니다.
                        self.bottomDisplayMoneyText.text            = "잔액 숨김"
                        /// 카드 잔액 정보 뷰어를 히든 처리 합니다.
                        self.bottomDisplayMoneyView.isHidden        = true
                        /// 카드 잔액정보 "잔액 숨김" 문구를 디스플레이 합니다.
                        self.bottomDisplayMoneyHiddenText.isHidden  = false
                    }
                    
                    break
                case .account:
                    /// 계좌 연결 카드 상세 정보를 디스플레이 합니다.
                    self.bottomDisplayAccountInfoText.isHidden  = false
                    /// 카드 타입 문구를 디스플레이 합니다.
                    self.bottomDisplayTypeText.text             = "출금"
                    /// 카드 잔액 정보 뷰어를 히든 처리 합니다.
                    self.bottomDisplayMoneyView.isHidden        = true
                    /// 카드 "잔액 숨김" 문구도 히든 처리 합니다.
                    self.bottomDisplayMoneyHiddenText.isHidden  = true
                    /// 카드 안내정보를 디스플레이 합니다.
                    self.bottomDisplayInfoText.text             = "결제금액만큼 즉시 출금되어 결제됩니다."
                    break
                case .banner:
                    self.cardView.isHidden      = true
                    self.bannerView.isHidden    = false
                    break
                }
                
            }
            else
            {
                /// 하단 모드  정보를 받아 하단 모드 뷰어를 온오프 합니다.
                self.bottomDisplayInfoView.isHidden = true
                switch displayType {
                case .okmoney:
                    /// 카드 잔앱 타입이 "보기" 경우 입니다.
                    if card._isBalanceShow!
                    {
                        /// 숨김 문구로 변경 합니다.
                        self.bottomDisplayMoneyOnoffBtn.setTitle("숨김", for: .normal)
                        /// 카드 잔액정보를 추가합니다.
                        self.payInfoMoney.text      = "\(card._balance!.addComma())"
                        self.payInfoView.isHidden   = false
                        self.payHiddenView.isHidden = true
                        
                    }
                    else
                    {
                        /// 숨김 문구로 변경 합니다.
                        self.bottomDisplayMoneyOnoffBtn.setTitle("보기", for: .normal)
                        self.payInfoView.isHidden   = true
                        self.payHiddenView.isHidden = false
                    }
                    break
                case .account:
                    break
                case .banner:
                    break
                }
                return
            }
        }
        
    }
    
    /**
     그라데이션 컬러값을 받아 카드 배경에 컬러를 추가 합니다. ( J.D.H VER : 1.0.0 )
     - Description: 그라데이션 컬러 값을 받아 배경 컬러를 적용하며, "colors" 를 "nil" 값으로 받을 경우 이전 "saveBgColors" 값을 활용하여 컬러값을 적용 하도록 합니다.
     - Date: 2023.06.15
     - Parameters:
        - colors : 그라데이션 적용할 컬러값을 받습니다.
     - Throws: False
     - Returns:False
     */
    func setCardBGColor( colors : ( start : UIColor, end : UIColor)? = nil ){
        if let bgColor = colors {
            self.saveBgColors = bgColor
            self.cardBGColor.frame = CGRect(origin: .zero, size: self.frame.size)
            self.cardBGColor.setGradientRightDownLeftTop(starColor: bgColor.start, endColor: bgColor.end)
            self.bottomDisplayCardBGColor.setGradientRightDownLeftTop(starColor: bgColor.start, endColor: bgColor.end)
        }
        else
        {
            if let bgColor = self.saveBgColors {
                self.cardBGColor.frame = CGRect(origin: .zero, size: self.frame.size)
                self.cardBGColor.setGradientRightDownLeftTop(starColor: bgColor.start, endColor: bgColor.end)
            }
        }
    }
    
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let event = CARD_BTN_EVENT(rawValue: (sender as AnyObject).tag) {
            switch event {
                case .payhidden, .paydisplay:
                    /// 잔액 정보 보기를 요청 합니다.
                    self.viewModel.setZeroPayMoneyHidden( hidden: event == .payhidden ? "Y" : "N" ).sink { result in
                        
                    } receiveValue: { model in
                        if let onoff = model,
                           onoff.code == "0000"{
                            /// 화면을 리로드 합니다.
                            self.setDisplayChange( bottomMode: false, model: OKZeroViewModel.zeroPayOKMoneyResponse )
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                    break
                case .bankchoice:
                    /// 은행 선택 페이지 입니다.
                    if self.displayType == .account
                    {
                        /// 제로페이 연결 은행 선택 입니다.
                    }
                    else
                    {
                        if let okmoney = OKZeroViewModel.zeroPayOKMoneyResponse,
                           let data    = okmoney._data,
                           let account = data._mainAccount
                        {
                            /// 계좌 미존재 여부 입니다.
                            if account._hasNoMainAccount!
                            {
                                self.setDisplayWebView(WebPageConstants.URL_OPENBANK_ACCOUNT_REGISTER, modalPresent: true, titleBarType: 2)
                                return
                            }
                            
                            /// 계좌 재인증 여부 입니다.
                            if account._isNeedToReauthorize!
                            {
                                /// 계좌 재인증 요청 합니다.
                                self.viewModel.setReBankAuth().sink { result in
                                    
                                } receiveValue: { response in
                                    
                                    if !response!.gateWayURL!.contains("{")
                                    {
                                        /// 오픈 뱅킹 웹 페이지를 디스플레이 합니다.
                                        let vc = HybridOpenBankViewController.init(pageURL: response!.gateWayURL! ) { value in
                                            if value.contains( "true" ) == true
                                            {
                                                TabBarView.setReloadSeleted(pageIndex: 4)
                                            }
                                        }
                                        self.viewController.pushController(vc, animated: true, animatedType: .up)
                                    }
                                    else
                                    {
                                        if response!.gateWayURL!.contains("O00")
                                        {
                                            let message: String = "계좌 등록 1년경과 시\n재인증이 필요해요."
                                            /// 계좌 재인증 안내 팝업을 오픈 합니다.
                                            CMAlertView().setAlertView(detailObject: message as AnyObject, cancelText: "확인") { event in
                                                self.setDisplayWebView(WebPageConstants.URL_TOKEN_REISSUE, modalPresent: true, titleBarType: 2)
                                            }
                                        }
                                    }
                                }.store(in: &self.viewModel.cancellableSet)
                                return
                            }
                                            
                            /// 계좌 선택 페이지 입니다.
                            BottomAccountListView().show { event in
                                switch event
                                {
                                case .add_account :
                                    self.setDisplayWebView(WebPageConstants.URL_OPENBANK_ACCOUNT_REGISTER, modalPresent: true, titleBarType: 2)
                                    break
                                case .account( let account ):
                                    if let account = account {
                                        /// 받은 계좌 정보로 서버에 카드 상세 정보를 요청 합니다.
                                    }
                                    break
                                }
                            }
                        }
                    }
                    break
                case .cardchoice, .bannerchoice:
                    /// 선탠된 카드에 현 카드정보를 넘깁니다.
                    OKZeroViewModel.zeroPayShared!.cardChoice  = self
                    OKZeroViewModel.zeroPayShared!.cardDisplay = .bottom
                    break
                case .bottompayonoff:
                    let hidden = self.bottomDisplayMoneyOnoffBtn.titleLabel!.text == "숨김" ? "Y" : "N"
                    /// 잔액 정보 보기/숨김 여부를 요청 합니다.
                    self.viewModel.setZeroPayMoneyHidden( hidden: hidden).sink { result in
                        
                    } receiveValue: { model in
                        if let onoff = model,
                           onoff.code == "0000" {
                            /// 화면을 리로드 합니다.
                            self.setDisplayChange( bottomMode: true, model: OKZeroViewModel.zeroPayOKMoneyResponse )
                        
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                    break
                case .fullDisplay:
                    OKZeroViewModel.zeroPayShared!.cardDisplay = .full
                    break
            }
        }
    }
    
    
}

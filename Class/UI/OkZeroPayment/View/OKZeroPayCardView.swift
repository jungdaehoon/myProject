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
    case payhidden  = 10
    /// 카드 금액 디스플레이 입니다.
    case paydisplay = 11
    /// 은행 선택 버튼 입니다.
    case bankchoice = 12
    /// 카드 선택 이벤트  입니다.
    case cardchoice = 13
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
    /// 배너 뷰어어 입니다.
    @IBOutlet weak var bannerView: UIView!
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
     카드 디스플레이 할 정보를 받아 설정 합니다.
     - Description:디스플레이 타입은 기본. "okmoney" 로 사용되며 배너 타입 경우 카드를 히든 처리 하며, 컬러값을 "setCardBGColor" 에 전달해 배경 컬러를 적용 합니다.
     - Date: 2023.06.15
     - Parameters:
        - displayType : 화면에 그려질 타입을 받습니다. ( default : okmoney )
        - colors : 그라데이션 적용할 컬러값을 받습니다.
     - Throws: False
     - Returns:False
     */
    func setDisplayView( displayType : DISPLAY_TYPE = .okmoney, colors : ( start : UIColor, end : UIColor)? = nil ){
        switch displayType {
        case .okmoney:
            self.titleText.text         = "OK머니로 제로페이 결제"
            self.subInfoText.text       = "부족한 금액은 충전 후 결제 됩니다."
            self.accountInfoText.text   = "OK저축은행 3456"
            break
        case .account:
            self.titleText.text         = "은행계좌에서 제로페이 결제"
            self.subInfoText.text       = "결제금액만큼 즉시 출금되어 결제됩니다."
            self.accountInfoText.text   = "신한은행 3456"
            break
        case .banner:
            self.cardView.isHidden      = true
            self.bannerView.isHidden    = false
            break
        }
        self.setCardBGColor(colors: colors)
    }
    
    
    
    /**
     그라데이션 컬러값을 받아 카드 배경에 컬러를 추가 합니다.
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
                case .payhidden:
                    self.payInfoView.isHidden   = true
                    self.payHiddenView.isHidden = false
                    break
                case .paydisplay:
                    self.payInfoView.isHidden   = false
                    self.payHiddenView.isHidden = true
                    break
                case .bankchoice:
                    /// 은행 선택 페이지 입니다.
                    if self.displayType == .account
                    {
                        /// 제로페이 연결 은행 선택 입니다.
                    }
                    else
                    {
                        /// 계좌 선택 페이지 입니다.
                    }
                    break
                case .cardchoice:
                    break
            }
            
        }
    }
    
    
}

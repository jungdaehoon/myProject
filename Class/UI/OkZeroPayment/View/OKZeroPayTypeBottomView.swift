//
//  OKZeroPayTypeBottomView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/03.
//

import UIKit



/**
 제로페이 페이지 버튼 타입 입니다. ( J.D.H VER : 2.0.7 )
 - Date: 2023.11.30
*/
enum ZEROPAY_TYPE_BOTTOM_BTN : Int {
    /// 페이지 종료 입니다.
    case page_exit      = 10
    /// 현장 결제 페이지로 이동합니다.
    case paymeny        = 11
    /// 제로페이 가맹점 매장 찾기 입니다.
    case location       = 12
    /// 자주하는 질문 입니다.
    case faq            = 13
    /// 상품권 페이지 이동 입니다.
    case gift           = 14
}


/**
 제로페이 서비스 안내 뷰어 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.28
 */
class OKZeroPayTypeBottomView: BaseView {

    @IBOutlet weak var bottomPopupHeight: NSLayoutConstraint!
    var bottomPopupMaxHeight          : CGFloat = 360
    /// 하단 팝업 뷰어 최대 높이 입니다.
    var safeBottomMaxHeight           : CGFloat = 376
    /// 제로페이 상품권 리스트 활성화 입니다.
    var giftEnabled                   : Bool = true
    /// 상품권 구매 버튼 높이 입니다.
    @IBOutlet weak var giftViewHeight : NSLayoutConstraint!
    /// 타입 선택시 이벤트 입니다.
    var btnEvent                      : (( _ event : ZEROPAY_TYPE_BOTTOM_BTN ) -> Void)? = nil
    /// 하단
    @IBOutlet weak var intoView       : UIView!
    /// 최하단 위치 포지션 입니다.
    @IBOutlet weak var safeBottom     : NSLayoutConstraint!
    
    
    
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
     제로페이 선택 안내 팝업을 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.05.03
     - Parameters:
        - completion : 페이지에서 이벤트를 리턴하는 CB 을 받습니다.
     - Throws: False
     - Returns:False
     */
    func setDisplay( giftEnabled : Bool = true,
                     completion : (( _ event : ZEROPAY_TYPE_BOTTOM_BTN ) -> Void)? = nil ) {
        self.giftEnabled = giftEnabled
        /// 상품권 이동 버튼을 히든 처리 합니다.
        if self.giftEnabled == false
        {
            self.giftViewHeight.constant    = 0
            self.bottomPopupHeight.constant = 324
            self.safeBottomMaxHeight        -= 56
        }
        
        self.btnEvent    = completion
        self.show()
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.7 )
     - Date: 2023.05.03
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show() {
        if let base = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            self.intoView.alpha = 0.0
            base.addSubview(self)
            DispatchQueue.main.async {
                /// 바코드 결제 위치로 선택 배경을 이동합니다.
                UIView.animate(withDuration:0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: .curveEaseOut) { [self] in
                    self.safeBottom.constant = 0
                    self.intoView.alpha = 1.0
                    self.layoutIfNeeded()
                } completion: { _ in
                    
                }
            }
        }
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H VER : 2.0.7 )
     - Date: 2023.05.03
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is OKZeroPayTypeBottomView
                {
                    let view = $0 as! OKZeroPayTypeBottomView
                    /// 바코드 결제 위치로 선택 배경을 이동합니다.
                    UIView.animate(withDuration:0.3, delay: 0.1,usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut) { [self] in
                        self.safeBottom.constant -= self.safeBottomMaxHeight
                        self.alpha = 0.0
                        self.layoutIfNeeded()
                    } completion: { _ in
                        view.removeFromSuperview()
                    }
                }
            })
        }
    }
    
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let type =  ZEROPAY_TYPE_BOTTOM_BTN(rawValue: (sender as AnyObject).tag)
        {
            switch type
            {
                /// 현
            case .page_exit:
                self.hide()
                return
            default:break
            }
            self.btnEvent!(type)
            self.hide()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

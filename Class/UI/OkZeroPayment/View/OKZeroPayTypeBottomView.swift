//
//  OKZeroPayTypeBottomView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/05/03.
//

import UIKit



/**
 제로페이 페이지 버튼 타입 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.05.03
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
    
}

/**
 제로페이 서비스 안내 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.28
 */
class OKZeroPayTypeBottomView: BaseView {

    /// 타입 선택시 이벤트 입니다.
    var btnEvent                    : (( _ event : ZEROPAY_TYPE_BOTTOM_BTN ) -> Void)? = nil
    
    
    
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
     제로페이 선택 안내 팝업을 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.03
     - Parameters:
        - completion : 페이지에서 이벤트를 리턴하는 CB 을 받습니다.
     - Throws : False
     - returns :False
     */
    func setDisplay( completion : (( _ event : ZEROPAY_TYPE_BOTTOM_BTN ) -> Void)? = nil ) {
        self.btnEvent = completion
        self.show()
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.03
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func show() {
        if let base = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     뷰어를 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.03
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is OKZeroPayTypeBottomView
                {
                    $0.removeFromSuperview()
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
                break
            case .paymeny:
                self.btnEvent!(.paymeny)
                self.hide()
                break
            case .location:
                self.btnEvent!(.location)
                self.hide()
                break
            case .faq:
                break
            }
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

//
//  ToastPopup.swift
//  FileManager
//
//  Created by OKPay on 2023/11/13.
//

import UIKit

class ToastPopup: UIView {
    static let shared       = ToastPopup.init()
    @IBOutlet weak var toastText: UILabel!
    /// 최대 유지 타임 입니다.
    static let WAITING_MAX_TIME            = 3.0
    /// 로딩 타이머 입니다.
    var waitingTimer                : Timer?
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        self.setToastView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setToastView()
    }
    

    func setToastView(){
        commonInit()
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.17
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), maxTime : CGFloat = ToastPopup.WAITING_MAX_TIME, text : String = "문서 정보를 가져오는 중입니다." ) {
        if let base = base {
            DispatchQueue.main.async {
                self.toastText.alpha  = 0.0
                self.toastText.text   = text
                self.waitingTimer       = Timer.scheduledTimer(timeInterval: maxTime,
                                             target: self, selector: #selector(self.timerAction),
                                             userInfo: nil,
                                             repeats: false)
                base.addSubview(self)
                
                /// 바코드 결제 위치로 선택 배경을 이동합니다.
                UIView.animate(withDuration:0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: .curveEaseOut) { [self] in
                    self.toastText.alpha = 1.0
                    self.layoutIfNeeded()
                } completion: { _ in
                    
                }
                
            }
        }
    }
    
    /**
     로딩 최대 타임 종료시 호출 하여 로딩바 히든 처리 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.17
     */
    @objc func timerAction() {
        self.hide()
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            if self.waitingTimer != nil
            {
                self.waitingTimer!.invalidate()
                self.waitingTimer = nil
            }
            /// 바코드 결제 위치로 선택 배경을 이동합니다.
            UIView.animate(withDuration:0.1, delay: 0.0, options: .curveEaseOut) { [self] in
                self.toastText.alpha = 0.0
                self.layoutIfNeeded()
            } completion: { _ in
                _ = base!.subviews.map({
                    if $0 is ToastPopup
                    {
                        $0.removeFromSuperview()
                    }
                })
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

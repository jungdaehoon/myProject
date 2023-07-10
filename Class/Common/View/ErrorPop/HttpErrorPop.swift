//
//  HttpErrorPop.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/07.
//

import UIKit


/**
 네트워크 연결 처리가 비정상일 경우 안내 뷰어 입니다.    ( J.D.H  VER : 1.0.0 )
 - Date: 2023.04.05
 */
class HttpErrorPop: BaseView {

    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        self.setErrorView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     뷰어를 초기화 하며 Xib 를 연결 합니다.    ( J.D.H  VER : 1.0.0 )
     - Date: 2023.04.05
     */
    func setErrorView(){
        commonInit()
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        if let base = base {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is HttpErrorPop
                {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    @IBAction func btn_action(_ sender: Any) {
        TabBarView.setReloadSeleted(pageIndex: 2)
    }
    
}

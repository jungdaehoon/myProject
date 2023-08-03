//
//  BottomLogOutView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit



/**
 최하단 로그아웃 페이지 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.07
*/
class BottomLogOutView: UIView {
    
    var viewModel : AllMoreModel?
    // MARK: - instanceFromNib
    class func instanceFromNib() -> BottomLogOutView {
        return UINib(nibName: "BottomLogOutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BottomLogOutView
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    // MARK: - 버튼 이벤트 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let alert = CMAlertView().setAlertView( detailObject: "로그아웃 하시겠습니까?" as AnyObject )
        alert?.addAlertBtn(btnTitleText: "취소", completion: { result in
            
        })
        alert?.addAlertBtn(btnTitleText: "확인", completion: { result in
            /// 로그아웃 데이터 처리 합니다.
            BaseViewModel.setLogoutData()            
        })
        alert?.show()
        
        
        
    }
}

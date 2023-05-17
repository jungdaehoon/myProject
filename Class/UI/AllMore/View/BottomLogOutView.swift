//
//  BottomLogOutView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit



/**
 최하단 로그아웃 페이지 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
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
            /// 로그아웃을 요청 합니다.
            self.viewModel?.setLogOut().sink(receiveCompletion: { result in
                
            }, receiveValue: { response in
                if response!.code == "0000"
                {
                    let custItem                            = SharedDefaults.getKeyChainCustItem()
                    custItem!.auto_login                    = false
                    SharedDefaults.setKeyChainCustItem(custItem!)
                    /// 재로그인 요청 합니다.
                    BaseViewModel.shared.reLogin             = true
                    /// 계좌 여부를 비활성화 합니다.
                    SharedDefaults.default.accountEnabled   = false
                }
                
            }).store(in: &self.viewModel!.cancellableSet)
        })
        alert?.show()
        
        
        
    }
}

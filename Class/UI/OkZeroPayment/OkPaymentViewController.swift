//
//  AllMoreViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//


import UIKit

/**
 제로페이 간편결제 페이지 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.07.10
*/
class OkPaymentViewController: UIViewController {
    /// 제로페이 간편결제 상세 페이지 입니다.
    @IBOutlet weak var zeroPayView: OKZeroPayView!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 제로페이 새로고침 여부를 체크 합니다.
        OKZeroViewModel.zeroPayShared!.$okZeroPayReload.sink { value in
            if value
            {
                /// 새로고침을 비활성화 합니다.
                OKZeroViewModel.zeroPayShared!.okZeroPayReload = false
                /// 제로페이 간편결제 상세 정보 디스플레이를 요청 합니다.
                self.zeroPayView.setZeroPayDisplay { success in
                    /// 비정상 처리시 페이지를 종료 합니다.
                    if success == false
                    {
                        self.popController(animated: false)
                    }
                }
            }
        }.store(in: &OKZeroViewModel.zeroPayShared!.cancellableSet)
    }

    
    
    // MARK: - setRelease
    override func setRelease() {
        super.setRelease()
        self.zeroPayView.setRelease()
        self.zeroPayView = nil
    }
}

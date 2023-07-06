//
//  AllMoreViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//


import UIKit

class OkPaymentViewController: UIViewController {
    /// 제로페이 간편결제 상세 페이지 입니다.
    @IBOutlet weak var zeroPayView: OKZeroPayView!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 제로페이 간편결제 상세 정보 디스플레이를 요청 합니다.
        self.zeroPayView.setZeroPayDisplay { success in
            /// 비정상 처리시 페이지를 종료 합니다.
            if success == false
            {
                self.popController(animated: false)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// okmoney 를 초기화 합니다.
        OKZeroViewModel.zeroPayOKMoneyResponse = nil
    }
}

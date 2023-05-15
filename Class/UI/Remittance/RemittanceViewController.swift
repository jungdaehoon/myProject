//
//  RemittanceViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit
import Combine


/**
 송금 페이지 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.21
*/
class RemittanceViewController: BaseViewController {

    var viewModel : RemittanceModel = RemittanceModel()
    @IBOutlet weak var webDisplayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWebView(self.webDisplayView, target: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.viewModel.selectAccountListResponse == nil
        {
            self.isAccount()
        }        
    }

    
    // MARK: - 지원 메서드 입니다.
    /**
     은행 계좌 정보를 체크합니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.22
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func isAccount()
    {
        self.viewModel.getSelectAccountList().sink { result in
            
        } receiveValue: { response in
            /// 정상 처리 경우 입니다.
            if response!._result!
            {
                /// 연결된 계좌 정보가있는 경우 입니다
                if response!._list!.count > 0
                {
                    /// 계좌 여부를 활성화 합니다.
                    SharedDefaults.default.accountEnabled = true
                    /// 대표 계좌 정보를 가집니다.
                    var mainAccount : Account? = nil
                    /// 받은 전체 계조 정보 중에 대표 계좌를 체크 합니다.
                    for account in response!._list!
                    {
                        /// 대표 계좌 여부를 체크 합니다.
                        if account._main_yn == "Y"
                        {
                            mainAccount = account
                            break
                        }
                    }
                    
                    /// 대표 계좌가 없을 경우 0번째 계좌를 넘깁니다.
                    if mainAccount == nil { mainAccount = response!._list![0] }
                    
                    /// 핀테크 이용 번호가 없을 경우 입니다.
                    if mainAccount!._fintech_use_num!.isEmpty
                    {
                        DispatchQueue.main.async {
                            self.view.setDisplayWebView( WebPageConstants.URL_OPENBANK_ACCOUNT_REGISTER, modalPresent: true, titleBarType: 2 ) { value in
                                switch value
                                {
                                case .pageClose:
                                    /// 하단 탭 홈으로 이동합니다.
                                    TabBarView.tabbar!.selectedIndex = 2
                                    return
                                default:break
                                }
                                self.isAccount()
                            }
                        }
                    }
                    else
                    {
                        /// 계좌 제인증 관련 여부를 체크 합니다.
                        if mainAccount!._acc_aggre_yn == "N" || mainAccount!._inquiry_agree_yn == "N" || mainAccount!._transfer_agree_yn == "N"
                        {
                            DispatchQueue.main.async {
                                /// 계좌 재인증 요청 합니다.
                                self.viewModel.setReBankAuth().sink { result in
                                    
                                } receiveValue: { response in
                                    
                                    if !response!.gateWayURL!.contains("{")
                                    {
                                        /// 오픈 뱅킹 웹 페이지를 디스플레이 합니다.
                                        let vc = HybridOpenBankViewController.init(pageURL: response!.gateWayURL! ) { value in
                                            /// 웹페이지에 오픈 뱅킹 처리관련 부분을 스크립트로 넘깁니다.
                                            self.webView!.evaluateJavaScript(value) { ( anyData , error) in
                                                if (error != nil)
                                                {
                                                    //self.hideHudView()
                                                    Slog("error___1")
                                                }
                                            }
                                        }
                                        self.present(vc, animated: true)
                                    }
                                    else
                                    {
                                        if response!.gateWayURL!.contains("O00")
                                        {
                                            let message: String = "계좌 등록 1년경과 시\n재인증이 필요해요."
                                            /// 계좌 재인증 안내 팝업을 오픈 합니다.
                                            CMAlertView().setAlertView(detailObject: message as AnyObject, cancelText: "확인") { event in
                                                self.view.setDisplayWebView(WebPageConstants.URL_TOKEN_REISSUE, modalPresent: true, titleBarType: 2) { value in
                                                    switch value
                                                    {
                                                    case .pageClose:
                                                        /// 하단 탭 홈으로 이동합니다.
                                                        TabBarView.tabbar!.selectedIndex = 2
                                                        return
                                                    default:break
                                                    }
                                                    self.isAccount()
                                                }
                                            }
                                        }
                                    }
                                }.store(in: &self.viewModel.cancellableSet)
                            }
                        }
                        /// 계좌 활성화 상태로 송금 페이지 이동합니다.
                        else
                        {
                            DispatchQueue.main.async {
                                self.loadMainURL(WebPageConstants.URL_REMITTANCE_MONEY)
                            }
                        }
                    }
                }
                /// 연결된 계좌 정보가 없는 경우 입니다.
                else
                {
                    DispatchQueue.main.async {
                        self.view.setDisplayWebView( WebPageConstants.URL_OPENBANK_ACCOUNT_REGISTER, modalPresent: true, titleBarType: 2 ) { value in
                            switch value
                            {
                            case .pageClose:
                                /// 하단 탭 홈으로 이동합니다.
                                TabBarView.tabbar!.selectedIndex = 2
                                return
                            default:break
                            }
                            self.isAccount()
                        }
                    }
                }
            }
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

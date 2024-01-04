//
//  PointItemView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit


/**
 현 머니/포인트 정보 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.07
*/
class PointItemView: UIView {
    /// 오픈 뱅킹 계좌 안내 문구 입니다.
    let OPEN_BANK_LINK      = "오픈 뱅킹 계좌를 연결하세요"
    /// 연결된 계좌 정보 없을 경우 문구 입니다.
    let NOT_BANK_LINK       = "계좌를 연결하세요"
    /// 계좌 인증이 만료되어 다시 인증요청 안내 문구 입니다.
    let RE_BACK_AUTH        = "은행계좌 인증하세요"
    
    var viewModel : AllMoreModel?
    /// OK머니 문구 입니다.
    @IBOutlet weak var okMoneyText      : UILabel!
    /// OK Point 문구 입니다.
    @IBOutlet weak var okPointText      : UILabel!
    /// 연결 출금 은행 계좌 입니다.
    @IBOutlet weak var bankingNumber    : UILabel!
    /// 연결된 NFT 카운트 정보 입니다.
    @IBOutlet weak var nftCount         : UILabel!
    
    
    
    // MARK: - instanceFromNib
    class func instanceFromNib() -> PointItemView {
        return UINib(nibName: "PointItemView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PointItemView
    }
    
    

    //MARK: - 지원 메서드 입니다.
    /**
     모델 데이터 기준으로 포인트 영역 디스플레이 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.08
     - Parameters:False
     - Throws: False
     - Returns: False
     */
    func setDisplay( _ model : AllMoreModel )
    {
        /// 모델 정보를 연결 합니다.
        self.viewModel = model
        /// 폰트 정보를 적용 합니다.
        self.nftCount.font      = UIFont(name: "Pretendard-SemiBold", size: 16.0)!
        self.bankingNumber.font = UIFont(name: "Pretendard-SemiBold", size: 16.0)!
        if let result = self.viewModel!.allModeResponse!.result {
            /// OK머니 정보입니다.
            self.okMoneyText.text   = "\(result._balance!.addComma())원"
            /// OK포인트 정보 입니다.
            self.okPointText.text   = "\(result._total_user_point!.addComma())원"
            /// NFT 보유 카운트 입니다.
            self.nftCount.text      = "\(result._own_nft_cnt!)개"
            /// 계좌 정보가 없는 경우입니다.
            if result._acc_no!.isEmpty
            {
                /// 오픈 뱅킹 사용여부를 체크 합니다.
                if result._openbank!
                {
                    /// 사용자 일련번호가 없을 경우 오픈 뱅킹 계좌 연결안내 입니다.
                    if result._user_seq_no!.isEmpty
                    {
                        self.bankingNumber.text = OPEN_BANK_LINK
                    }
                    /// 사용자 일련번호가 있을경우 계좌 연결 안내를 합니다.
                    else
                    {
                        self.bankingNumber.text = NOT_BANK_LINK
                    }
                }
                else
                {
                    self.bankingNumber.text = NOT_BANK_LINK
                }
            }
            /// 계좌 정보가 있는 경우입니다.
            else
            {
                /// 계좌 정보 마지막 정보 4자리를 디스플레이 용으로 사용 합니다.
                let accno = model.allModeResponse!.result!._acc_no!.count > 4 ? model.allModeResponse!.result!._acc_no!.right(4) : model.allModeResponse!.result!._acc_no!
                /// 오픈 뱅킹 사용여부를 체크 합니다.
                if result._openbank!
                {
                    /// 핀테크 이용 번호가 없을 경우 입니다.
                    if result._fintech_use_num!.isEmpty
                    {
                        /// 사용자 일련번호가 없을 경우 오픈 뱅킹 계좌 연결안내 입니다.
                        if result._user_seq_no!.isEmpty
                        {
                            self.bankingNumber.text = OPEN_BANK_LINK
                        }
                        /// 사용자 일련번호가 있을경우 계좌 연결 안내를 합니다.
                        else
                        {
                            self.bankingNumber.text = NOT_BANK_LINK
                        }
                    }
                    else
                    {
                        /// 계좌 제인증 관련 여부를 체크 합니다.
                        if result._acc_aggre_yn == "N" || result._inquiry_agree_yn == "N" || result._transfer_agree_yn == "N"
                        {
                            self.bankingNumber.text = RE_BACK_AUTH
                        }
                        else
                        {
                            self.bankingNumber.text = "\(model.allModeResponse!.result!._bank_nm!)\(accno)"
                        }
                    }
                }
                else
                {
                    self.bankingNumber.text = "\(model.allModeResponse!.result!._bank_nm!)\(accno)"
                }
            }
        }
    }
    
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let btn : UIButton  = sender as! UIButton
        if self.viewModel == nil { return }
        if let _ = self.viewModel!.allModeResponse!.result {
            switch btn.tag {
                /// OK머니 버튼 이벤트 입니다.
            case 10:
                BaseViewModel.setGAEvent(page: "전체서비스",area: "내정보",label: "OK머니")
                self.setDisplayWebView(WebPageConstants.URL_ACCOUNT_TRANSFER_LIST)
                break
                /// OK포인트 버튼 이벤트 입니다.
            case 11:
                BaseViewModel.setGAEvent(page: "전체서비스",area: "내정보",label: "OK포인트")
                self.setDisplayWebView(WebPageConstants.URL_POINT_TRANSFER_LIST)
                break
            case 12:
                
                var openBankUrl = ""
                /// 오픈 뱅킹 계좌 연결 경우 입니다.
                if self.bankingNumber.text == OPEN_BANK_LINK
                {
                    BaseViewModel.setGAEvent(page: "전체서비스",area: "내정보",label: "오픈 뱅킹 계좌연결")
                    openBankUrl = WebPageConstants.URL_OPENBANK_ACCOUNT_REGISTER
                }
                /// 연결된 계좌 정보가 없는 경우 입니다.
                else if self.bankingNumber.text == NOT_BANK_LINK
                {
                    BaseViewModel.setGAEvent(page: "전체서비스",area: "내정보",label: "은행 계좌연결")
                    openBankUrl = WebPageConstants.URL_ACCOUNT_REGISTER
                }
                /// 계좌 재인증 경우 입니다.
                else if self.bankingNumber.text == RE_BACK_AUTH
                {
                    BaseViewModel.setGAEvent(page: "전체서비스",area: "내정보",label: "은행 계좌인증")
                    /// 계좌 재인증 요청 합니다.
                    self.viewModel!.setReBankAuth().sink { result in
                        
                    } receiveValue: { response in
                        
                        if !response!.gateWayURL!.contains("{")
                        {
                            /// 오픈 뱅킹 웹 페이지를 디스플레이 합니다.
                            let vc = HybridOpenBankViewController.init(pageURL: response!.gateWayURL! ) { value in
                                if value.contains( "true" ) == true
                                {
                                    TabBarView.setReloadSeleted(pageIndex: 4)
                                }
                            }
                            self.viewController.pushController(vc, animated: true, animatedType: .up)
                        }
                        else
                        {
                            if response!.gateWayURL!.contains("O00")
                            {
                                let message: String = "계좌 등록 1년경과 시\n재인증이 필요해요."
                                /// 계좌 재인증 안내 팝업을 오픈 합니다.
                                CMAlertView().setAlertView(detailObject: message as AnyObject, cancelText: "확인") { event in
                                    self.setDisplayWebView(WebPageConstants.URL_TOKEN_REISSUE, modalPresent: true, titleBarType: 2) { value in
                                        TabBarView.setReloadSeleted(pageIndex: 4)
                                    }
                                }
                            }
                        }
                    }.store(in: &self.viewModel!.cancellableSet)
                    return
                }
                
                /// 오픈 뱅킹 이동 할 URL 정보가 있는지를 체크 합니다.
                if openBankUrl.isValid
                {
                    /// 오픈 뱅킹 페이지를 호출 합니다.
                    self.setDisplayWebView(openBankUrl, modalPresent: true, pageType: .openbank_type, titleBarType: 2) { value in
                        switch value
                        {
                        case .openBank( let success, _ ):
                            if success
                            {
                                TabBarView.setReloadSeleted(pageIndex: 4)
                            }
                            break
                        default:break
                        }
                    }
                    return
                }
                
                BaseViewModel.setGAEvent(page: "전체서비스",area: "내정보",label: "주계좌")
                /// 연결 계좌 리스트로 이동 합니다.
                self.setDisplayWebView( WebPageConstants.URL_MY_ACCOUNT_LIST, modalPresent: true, pageType: .openbank_type, titleName: "주계좌 관리", titleBarType: 2) { value in
                    /// 메인 계좌가 변경되는 경우 새로고침은 어떻게 할지 미정 입니다. 일단 새로고침 합니다.
                    TabBarView.setReloadSeleted(pageIndex: 4)
                }
                break
            case 13:
                BaseViewModel.setGAEvent(page: "전체서비스",area: "내정보",label: "NFT")
                self.setDisplayWebView(WebPageConstants.URL_NFT_TRANS_LIST)
                break
            default:break
            }
        }
    }
}

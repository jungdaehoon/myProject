//
//  BannerView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit



/**
 베너 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.07
*/
class BannerView: UIView {
    var viewModel : AllMoreModel?
    /// 애니 디스플레이 하는 뷰어 입니다.
    @IBOutlet weak var aniView: UIView!
    /// 스크롤 이동시 변경될 이미지 영역 입니다.
    @IBOutlet weak var aniImage: UIImageView!
    

    
    // MARK: - instanceFromNib
    class func instanceFromNib() -> BannerView {
        return UINib(nibName: "BannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BannerView
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     "전체" 탭 에서 스크롤시 이벤트 정보를 받습니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.08
     - Parameters:
        - scrollView : 스크롤 정보를 받습니다
     - Throws: False
     - Returns: False
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let maxHeight       = scrollView.contentSize.height - scrollView.frame.size.height
        let itemHeight      = maxHeight/11
        let index           = (scrollView.contentOffset.y)/itemHeight
        self.aniImage.image = UIImage(named: "bbannerImg\(Int(index))")
    }
    

    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let tabbar = TabBarView.tabbar {
            tabbar.setSelectedIndex(.finance)
        }
        
        
        /* /// 일단 금융 탭으로 이동 하도록 하며 아래는 주석 합니다.
        let result  = self.viewModel!.allModeResponse!.result!
        var openBankUrl = ""
         
        /// 오픈뱅킹 여부를 체크 합니다.
        if result._openbank!
        {
            if result._user_seq_no!.isEmpty
            {
                openBankUrl = WebPageConstants.URL_OPENBANK_ACCOUNT_REGISTER
            }
            else
            {
                openBankUrl = WebPageConstants.URL_ACCOUNT_REGISTER
            }
        }
        else
        {
            openBankUrl = WebPageConstants.URL_ACCOUNT_REGISTER
        }
        
        /// 오픈 뱅킹 페이지를 호출 합니다.
        self.setDisplayWebView(openBankUrl, modalPresent: true, pageType: .openbank_type, titleBarType: 2) { value in
        }
         */
        
    }    
}

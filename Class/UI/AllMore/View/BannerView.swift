//
//  BannerView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit



/**
 베너 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.07
*/
class BannerView: UIView {

    @IBOutlet weak var aniView: UIView!
    @IBOutlet weak var aniImage: UIImageView!
    var viewModel : AllMoreModel?

    // MARK: - instanceFromNib
    class func instanceFromNib() -> BannerView {
        return UINib(nibName: "BannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BannerView
    }
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     "전체" 탭 에서 스크롤시 이벤트 정보를 받습니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.08
     - Parameters:
        - scrollView : 스크롤 정보를 받습니다
     - Throws : False
     - returns : False
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let maxHeight       = scrollView.contentSize.height - scrollView.frame.size.height
        let itemHeight      = maxHeight/11
        let index           = (scrollView.contentOffset.y)/itemHeight
        print("maxHeight : \(maxHeight) itemHeight : \(itemHeight) index : \(index)")
        self.aniImage.image = UIImage(named: "bbannerImg\(Int(index))")
    }
    

    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let result = self.viewModel!.allModeResponse!.result!
        /// 오픈뱅킹 여부를 체크 합니다.
        if result._openbank!
        {
            if result._user_seq_no!.isEmpty
            {
                self.setDisplayWebView(WebPageConstants.URL_OPENBANK_ACCOUNT_REGISTER)
            }
            else
            {
                self.setDisplayWebView(WebPageConstants.URL_ACCOUNT_REGISTER)
            }
        }
        else
        {
            self.setDisplayWebView(WebPageConstants.URL_ACCOUNT_REGISTER)
        }
    }
    
    
    /**
     링크 기준으로 전체 화면 웹뷰를 디스플레이 합니다.
     - Date : 2023.03.21
     - Parameters:
        - linkUrl : 연결할 페이지 URL 정보 입니다.
     - Throws : False
     - returns :False
     */
    func setDisplayWebView( _ linkUrl : String = "" ) {        
        /// 전체 웹뷰를 호출 합니다.
        let webview =  FullWebViewController.init(pageURL: linkUrl) { cbType in
            switch cbType
            {
            case .urlLink(let url):
                /// 전체 웹뷰에서 페이지 종료시 전달 하는 정보를 체크 합니다.
                if url.contains(WebPageConstants.URL_MY_ACCOUNT_LIST)
                {
                    self.setDisplayWebView(WebPageConstants.URL_MY_ACCOUNT_LIST)
                }
            default:break
            }            
        }
        self.viewController.navigationController?.pushViewController(webview, animated: true)
    }
    
}

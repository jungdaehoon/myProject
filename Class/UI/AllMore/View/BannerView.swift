//
//  BannerView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import UIKit



/**
 베너 뷰어 입니다.  ( J.D.H VER : 2.0.0 )
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
     "전체" 탭 에서 스크롤시 이벤트 정보를 받습니다. ( J.D.H VER : 2.0.0 )
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
            BaseViewModel.setGAEvent(page: "전체서비스",area: "중간배너" ,label: "요즘 뜨는 OK저축은행 인기 상품")
            tabbar.setSelectedIndex(.finance)
        }
    }    
}

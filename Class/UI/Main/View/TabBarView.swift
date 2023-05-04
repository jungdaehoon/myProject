//
//  TabBarView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/03.
//

import UIKit

/**
 탭바 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
 */
class TabBarView : UIView
{
    /// 탭 아이템들 높이 값을 가집니다.
    @IBOutlet weak var itemHeight       : NSLayoutConstraint!
    /// 탬 아이템 들의 넓이 값을 가집니다.
    @IBOutlet weak var itemWidth        : NSLayoutConstraint!
    /// 공통으로 사용되는 Tabbar 입니다. ( MainViewController 에서 TabbarViewController 를 가져 옵니다. )
    static var tabbar                   : TabbarViewController?
    /// 이전 Tab 인덱스 입니다.
    static var tabBackIndex             : Int   = 0
    /// 현 Tab 인덱스 입니다.
    static var tabSeletedIndex          : Int   = 0
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initTabBarView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initTabBarView()
    }
    
    
    
    //MARK: - 지원 메서드 입니다
    /**
     탭바  뷰어 초기화 메서드 입니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     */
    func initTabBarView(){
        /// Xib 연결 합니다.
        self.commonInit()
        
        /// 아이템 들 넓이를 설정 합니다.
        self.itemWidth.constant  = (UIScreen.main.bounds.size.width - 20) / 5
        self.itemHeight.constant = self.frame.size.height
        //Thread 1: Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value
    }
    
    
    /**
     탭 아이템 기본 상태로 설정 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:False
     - returns :False
     */
    func setDefault(){
        let itemViews = self.subviews[0].subviews
        for views in itemViews
        {
            self.setSeleted(views, enabled: false)
        }
    }
    
    
    /**
     탭 아이템  활성화 여부를 받아 활성화 합니다..   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:
        - subViews : 활성화될 아이템 뷰어 입니다.
        - enabled : 활성화 여부 값입니다.
     - returns :False
     */
    func setSeleted( _ subViews : UIView, enabled : Bool )
    {
        for subview in subViews.subviews
        {
            if subview is UIButton
            {
                let item  = subview as! UIButton
                /// 버튼 문구를 활성화 합니다.
                if item.tag == 0
                {
                    if enabled == true
                    {
                        item.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 12.0)!
                    }
                    else
                    {
                        item.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 12.0)!
                    }
                    
                    item.isSelected  = enabled
                    item.isEnabled   = enabled
                }
                
                /// 버튼을 이미지를 활성화 합니다.
                if item.tag >= 100
                {
                    if enabled == true
                    {
                        /// 애니 효과 디스플레이로 디폴트 버튼을 히든 처리 합니다.
                        item.isHidden   = true
                        /// 디스플레이할 애니 이미지들을 선언 합니다.
                        let aniimages   = ["tabbar_wallet","tabbar_benefit","tabbar_home","tabbar_financial","tabbar_more"]
                        /// 애니 뷰어를 추가합니다.
                        let aniView     = LottieAniView(frame: item.frame)
                        aniView.setAnimationView(name: aniimages[item.tag - 100], loop: false)
                        aniView.play { success in
                            /// 디폴트 버튼을 활성화 합니다.
                            item.isHidden    = false
                            /// 추가한 애니 뷰어를 삭제 합니다.
                            aniView.removeFromSuperview()
                        }
                        subViews.addSubview(aniView)
                    }
                    /// 디폴트 버튼을 활성화 여부를 설정 합니다.
                    item.isSelected  = enabled
                    item.isEnabled   = enabled
                    
                }
            }
            
            
        }
    }
    
    
    /**
     변경할 탭 카운트를 받아 활성화 합니다..   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:
        - pageTag : 활성화될 아이템 넘버 입니다.
     - returns :False
     */
    func setChangePage( _ pageTag : Int ){
        if let subView = self.viewWithTag(pageTag)
        {
            /// 이전 탭 정보를 넘 깁니다.
            TabBarView.tabBackIndex             = TabBarView.tabSeletedIndex
            /// 현 탭 정보를 저장 합니다.
            TabBarView.tabSeletedIndex          = pageTag - 10
            
            /// 현 페이지가 전체 탭 페이지면 초기화합니다.
            if let viewController = TabBarView.tabbar!.viewControllers![TabBarView.tabSeletedIndex] as? AllMoreViewController
            {
                /// 한번이라도 요청된적이 있는 경우 입니다.
                if let _ = viewController.viewModel.allModeResponse
                {
                    viewController.setDisplayData()
                }
            }
            
            /// 이전 웹페이지를 초기화 합니다.
            if let viewController = TabBarView.tabbar!.viewControllers![TabBarView.tabBackIndex] as? BaseViewController ,
               TabBarView.tabSeletedIndex != TabBarView.tabBackIndex
            {
                /// 이전 페이지의 웹뷰를 초기화 합니다.
                viewController.initWebPage()
            }
        

            Slog("TabBarView.tabBackIndex : \(TabBarView.tabBackIndex)")
            Slog("TabBarView.tabSeletedIndex : \(TabBarView.tabSeletedIndex)")
            
            self.setDefault()
            self.setSeleted(subView, enabled: true)
        }
    }
    
    
    
    //MARK: - 버튼 이벤트 입니다.
    @IBAction func btn_action(_ sender: Any) {
        let btn : UIButton  = sender as! UIButton
        Slog("btn.tag: \(btn.tag)")
        let seletedIndex    = btn.tag - 10
        TabBarView.tabbar!.selectedIndex    = seletedIndex
    }

}


/**
 탭바 상단 쉐도우 라인을 그립니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
 */
extension CALayer {
    // Sketch 스타일의 그림자를 생성하는 유틸리티 함수
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.3,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4
    ) {
        shadowColor     = color.cgColor
        shadowOpacity   = alpha
        shadowOffset    = CGSize(width: x, height: y)
        shadowRadius    = blur / 2.0
    }
}

extension UITabBar {
    /// 기본 그림자 스타일을 초기화해야 커스텀 스타일을 적용할 수 있습니다.
    static func clearShadow() {
        UITabBar.appearance().shadowImage       = UIImage()
        UITabBar.appearance().backgroundImage   = UIImage()
        UITabBar.appearance().backgroundColor   = UIColor.white
    }
}




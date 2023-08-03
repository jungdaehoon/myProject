//
//  BaseTabBarView.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import UIKit


/**
 탭바 호출시 타입 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.20
 */
enum TAB_REPLACE
{
    case normal
    case replace
    case newtab
}


/**
 탭바 뷰어의 높이 값 설정 및 커스텀 UI 연결 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.20
 */
class BaseTabBarView: UITabBar {
    var tabMode : TAB_REPLACE? = .normal
    /// 탭바 뷰어 입니다.
    var tabbar : TabBarView? = nil
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits        = super.sizeThatFits(size)
        let height : CGFloat    = sizeThatFits.height
        
        ///탭바 뷰어 기본 높이 49 인 경우 입니다.
        if height == 49 ||
           height == 50
        {
            /// 일반 탭바 뷰 높이를 설정 합니다.
            sizeThatFits.height     = height + 11
            /// 탭바 설정이 되어있지 않는지를 체크 합니다.
            if self.tabbar == nil
            {
                /// 일반 탭바 뷰 모드로 설정 합니다.
                self.tabMode            = .normal
                
                /// 텝바 UI 화면에 추가 하며 하단 라운드를 가리는 높이 24 를 추가 합니다.
                self.tabbar = TabBarView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height + 24))
                self.addSubview(self.tabbar!)
            }
        }
        else
        {
            /// 신규 탭바 뷰 높이를 설정 합니다.
            sizeThatFits.height     = height + 11
            
            /// 일반 모드 탭바 가 화면에 추가 되었을 경우 입니다.
            if self.tabbar != nil &&
               self.tabMode == .normal
            {
                self.tabMode    = .replace
                self.tabbar?.removeFromSuperview()
                self.tabbar     = nil
            }
            
            /// 탭바뷰 다시 그리기  혹은 텝바가 추가되지 않은 경우 입니다.
            if self.tabMode == .replace ||
                self.tabbar == nil
            {
                /// 신규 탭바 모드로 변경 합니다.
                self.tabMode = .newtab
                
                /// 신규 텝바 UI 화면에 추가 하며 하단 라운드를 가리는 높이 24 를 추가 합니다.
                self.tabbar = TabBarView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height + 11))
                self.addSubview(self.tabbar!)
            }
        }
        self.tabbar?.backgroundColor    = .white
        self.backgroundColor            = .white
        return sizeThatFits
    }
}



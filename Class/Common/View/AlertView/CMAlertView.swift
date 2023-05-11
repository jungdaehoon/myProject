//
//  CMAlertView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/15.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 기본 안내 팝업 전체화면 형태의 UI 입니다.   ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.16
 */
class CMAlertView: UIView {
    /// 왼쪽 버튼 팝업 종료 이벤트를 넘깁니다.
    var leftCompletion                  : (( _ result : String ) -> Void )? = nil
    /// 오른쪽 버튼 팝업 종료 이벤트를 넘깁니다.
    var rightCompletion                 : (( _ result : String ) -> Void )? = nil
    /// 싱글 중앙 버튼  팝업 종료 이벤트를 넘깁니다.
    var centerCompletion                : (( _ result : String ) -> Void )? = nil
    /// 싱글 팝업 인지를 체크 합니다.
    var isSinglePop                     : Bool?
    
    /// 타이틀 정보 입니다.
    @IBOutlet weak var titleLabel       : UILabel!
    /// 타이틀 정보 디스플레이 높이 입니다.
    @IBOutlet weak var titleHeight      : NSLayoutConstraint!
    /// 팝업의 상세 정보 디스플레이 영역 입니다.
    @IBOutlet weak var detailView       : UIView!
    /// 팝업 상세 정보 뷰어의 높이 입니다.
    @IBOutlet weak var detailViewHeight : NSLayoutConstraint!
    /// 싱글 버튼 팝업에 하단 팝업 종료 버튼 입니다.
    @IBOutlet weak var cancelBtn        : UIButton!
    /// 다중 버튼 뷰어 입니다.
    @IBOutlet weak var twoButtonview    : UIView!
    /// 다중 버튼 팝업에 하단 왼쪽 팝업 종료 버튼 입니다.
    @IBOutlet weak var leftBtn          : UIButton!
    /// 다중 버튼 팝업에 하단 오른쪽 팝업 종료 버튼 입니다.
    @IBOutlet weak var rightBtn         : UIButton!
    /// 알림 뷰어 입니다.
    @IBOutlet weak var alertView        : UIView!
    
    
    
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     싱글 버튼 형태의 안내 팝업 오픈을 위한 기본 정보를 받아 디스플레이 하는 메서드 입니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - titleText : 팝업 타이틀 정보 입니다.
        - detailObject : 팝업 상세 정보에 디스플레이 할 정보 입니다. ( String : 문자를 받아 디스플레이 합니다. , UIView : 상세 뷰어에 디스플레이 합니다.)
        - cancelText : 하단 버튼 타이틀 정보 입니다.
        - completion : 팝업 종료시 이벤트를 가집니다.
     - Throws : False
     - returns :False
     */
    func setAlertView( titleText : String = "", detailObject : AnyObject, cancelText : String, completion : (( _ result : String ) -> Void )? = nil )
    {
        self.cancelBtn.setTitle(cancelText, for: .normal)
        self.centerCompletion   = completion
        let _ = self.setAlertView(titleText: titleText, detailObject: detailObject)
        /// 팝업을 오픈 합니다.
        self.show()
    }
    
    
    
    /**
     버튼을 별도로 추가하는 형태의 안내 팝업 오픈을 위한 기본 정보를 받아 디스플레이 하는 메서드 입니다.  별도로 버튼  'addAlertBtn'  으로 추가 해야하며, 별도로 show 메서드를 호출해야 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - titleText : 팝업 타이틀 정보 입니다.
        - detailObject : 팝업 상세 정보에 디스플레이 할 정보 입니다. ( String : 문자를 받아 디스플레이 합니다. , UIView : 상세 뷰어에 디스플레이 합니다.)
     - Throws : False
     - returns :
        - CMAlertView Type
            + 버튼 이벤트를 추가할 알림뷰 자기 자신을 넘깁니다.
     */
    func setAlertView( titleText : String = "", detailObject : AnyObject) -> CMAlertView?
    {
        self.isSinglePop        = true
        /// 타이틀 정보에 따른 디스플레이 여부 입니다.
        if titleText == ""
        {
            self.titleLabel.isHidden        = true
            self.titleHeight.constant       = 0
        }
        else
        {
            self.titleLabel.isHidden        = false
            self.titleHeight.constant       = 36
        }
        
        /// 문자 정보 입니다.
        if detailObject is String
        {
            let detailText : String = detailObject as! String
            /// 문자 정보로 화면에 label 추가 합니다.
            self.addLabel(detailText == "" ? detailText : detailText)
        }
        
        /// 뷰어 정보 입니다.
        if detailObject is UIView
        {
            /// 받은 UIView 정보를 상세 뷰어에 추가합니다.
            self.addView(detailObject as! UIView)
        }
        
        return self
    }
    
    
    
    /**
     다중 버튼으로 팝업에 사용될 버튼을 추가 합니다..   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - btnTitleText : 버튼 타이틀 정보 입니다.
        - completion : 추가되는 버튼 이벤트를 가집니다.
     - Throws : False
     - returns :False
     */
    func addAlertBtn( btnTitleText : String, completion : (( _ result : String ) -> Void )? = nil )
    {
        /// 싱글 버튼을 추가 합니다.
        if self.centerCompletion == nil
        {
            /// 싱글 버튼 타입 문구 입니다.
            self.cancelBtn.setTitle(btnTitleText, for: .normal)
            /// 싱글 버튼 타입으로 활성화 합니다.
            self.isSinglePop            = true
            self.centerCompletion       = completion
        }
        else
        {
            
            /// 왼쪽  버튼 타입 문구 입니다.
            self.leftBtn.setTitle(self.cancelBtn.currentTitle, for: .normal)
            /// 오른쪽  버튼 타입 문구 입니다.
            self.rightBtn.setTitle(btnTitleText, for: .normal)
            /// 싱글 버튼 타입을 비활성화 합니다.
            self.isSinglePop            = false
            /// 싱글 버튼을 비활성화 합니다.
            self.cancelBtn.isHidden     = true
            /// 다중 버튼 뷰어를 활성화 합니다.
            self.twoButtonview.isHidden = false
            /// 왼쪽 버튼 이벤트를 활성화 합니다.
            self.leftCompletion         = self.centerCompletion
            /// 오른쪽 버튼 이벤트를 활성화 합니다.
            self.rightCompletion        = completion
        }
    }
    
    
    /**
     안내 팝업의 상세 뷰어에  받아온 뷰어를  추가합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - view : 상세 뷰어 입니다.
     - Throws : False
     - returns :False
     */
    func addView( _ view : UIView )
    {
        self.detailViewHeight.constant = view.frame.size.height
        self.detailView.addSubview(view)
    }
    
    
    /**
     안내 팝업의 상세 뷰어에  받아온 문자정보를  추가합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:
        - text : 상세 문자 정보 입니다.
     - Throws : False
     - returns :False
     */
    func addLabel( _ text : String )
    {
        let textLabel                   = UILabel()
        textLabel.text                  = text
        textLabel.font                  = UIFont(name: "Pretendard-Regular", size: 16)
        textLabel.textAlignment         = NSTextAlignment.center
        textLabel.textColor             = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
        textLabel.numberOfLines         = 0
        textLabel.lineBreakMode         = .byWordWrapping
        let maxSize                     = CGSize(width: self.detailView.frame.size.width ,
                                                 height: UIScreen.main.bounds.height - self.alertView.frame.height )
        let textSize                    = textLabel.sizeThatFits(maxSize)
        let textWidth                   = min(textSize.width, maxSize.width)
        let textHeight                  = min(textSize.height, maxSize.height)
        
        self.detailViewHeight.constant  = textHeight
        self.detailView.addSubview(textLabel)
        self.detailView.addConstraintsToFit(textLabel)
    }
    

    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        if let base = base {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.16
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is CMAlertView
                {
                    $0.removeFromSuperview()
                }
            })
        }        
    }
    
    
    
    
    //MARK: - btn_action
    @IBAction func btn_action(_ sender: Any) {
        self.hide()
        /// 싱글 버튼 팝업 뷰어인지를 체크 합니다.
        if self.isSinglePop!
        {
            /// 싱글 팝업의 선택 이벤트를 넘깁니다.
            self.centerCompletion!("")
            self.centerCompletion = nil
        }
        /// 다중 버튼 팝업 뷰어로 체크 합니다.
        else
        {
            let btn : UIButton = sender as! UIButton
            /// 버튼 액션이 왼쪽 버튼인지를 체크 합니다.
            if btn == self.leftBtn
            {
                /// 왼쪽 버튼의 액션 이벤트를 넘깁니다.
                self.leftCompletion!("")
            }
            else
            {
                /// 오른쪽 버튼의 액션 이벤트를 넘깁니다.
                self.rightCompletion!("")
            }
            self.leftCompletion  = nil
            self.rightCompletion = nil
        }
    }
}

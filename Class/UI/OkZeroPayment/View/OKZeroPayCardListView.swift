//
//  OKZeroPayCardListView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/28.
//

import UIKit


/**
 제로페이 결제 가능 카드 리스트 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.28
 */
class OKZeroPayCardListView: UIView {
    var viewModel                       : OKZeroViewModel = OKZeroViewModel()
    /// 카드 디스플레이 하는 스크롤 뷰어 입니다.
    @IBOutlet weak var scrollView       : UIScrollView!
    /// 코드 선택시 이벤트 입니다.
    var btnEvent                        : (( _ success : Bool ) -> Void)? = nil
    /// 전체 화면 활성화 버튼 입니다
    @IBOutlet weak var listEnabledBtn   : UIButton!
    /// 카드 뷰어를 저장 합니다.
    var cardViews                       : [OKZeroPayCardView?] = []
    /// 카드 뷰어 상단 까지의 포지션 입니다.
    var topPosition                     : CGFloat = 0.0
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initZeroPayCardList()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initZeroPayCardList()
    }
    
    
    
    //MARK: - draw
    override func draw(_ rect: CGRect) {
        self.setCardDisplay()
    }
    
    

    //MARK: - 지원 메서드 입니다.
    /**
     제로페이 결제 가능 카드뷰어 초기화 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.28
     */
    func initZeroPayCardList(){
        self.commonInit()
    }
    
    
    /**
     카드 리스트 뷰어어 디스플레이를 요청 합니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.28
     - Parameters:
        - btnEvent : 버튼 이벤트를 넘깁니다.
     - Throws : False
     - returns :False
     */
    func setDisplay( btnEvent : (( _ success : Bool ) -> Void)? = nil ){
        self.btnEvent = btnEvent
    }
    
    
    /**
     최초 카드 정보를 화면에 추가 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.28
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setCardDisplay(){
        let colors : [(c1 : UIColor, c2 : UIColor)]  = [(UIColor(hex: 0x666666),UIColor(hex: 0xF6F6F6)),
                               (UIColor(hex: 0x2A357F),UIColor(hex: 0x626FC1)),
                                                        (UIColor(hex: 0xFF5300),UIColor(hex: 0xFD9200))]
        let maxCount = 3
        for index in 0..<maxCount
        {
            let width : CGFloat = ( self.frame.size.width - 40.0 ) - ( CGFloat((maxCount - index)) * 20.0)
            if let cardview = self.getCardView( position_y: CGFloat(index) * 7.0, width:width, colors : colors[index] )
            {
                self.cardViews.append(cardview)
                self.scrollView.addSubview(cardview)
            }
        }
    }
    
    
    /**
     카드 디스플레이 입니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.28
     - Parameters:
        - position_y : 카드 y 좌표 위치 입니다.
        - width : 카드 넓이 입니다.
        - colors : 카드 컬러 입니다.
     - Throws : False
     - returns :False
     */
    func getCardView( position_y : CGFloat = 0.0, width : CGFloat = 0.0, colors : (c1 : UIColor, c2 : UIColor) ) -> OKZeroPayCardView? {
        let cardview : OKZeroPayCardView    = OKZeroPayCardView()
        let size                            = CGSize(width: width, height: 208.0)
        let point                           = CGPoint(x: self.frame.size.width/2 - size.width/2, y: position_y)
        cardview.frame                      = CGRect(origin: point, size: size)
        cardview.cardBGColor.frame          = CGRect(origin: .zero, size: size)
        cardview.cardBGColor.setGradientRightDownLeftTop( starColor: colors.c1, endColor: colors.c2 )
        return cardview
    }

    
    /**
     결제 카드 정보를 하단에 디스플레이 되도록 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.10
     - Parameters:
        - topPosition : 하단 디스플레이시 상단 까지의 포지션 입니다.
     - Throws : False
     - returns :False
     */
    func setCardBottom( topPosition : CGFloat = 0.0){
        /// 최대 상단 포지션을 저장 합니다.
        self.topPosition = topPosition
        for index in 0..<self.cardViews.count
        {
            let w = self.frame.size.width/2
            /// 카드의 기본 사이즈를 가져 옵니다.
            if let view = self.cardViews[index]
            {
                let width       : CGFloat   = ( self.frame.size.width - 40.0 ) - ( CGFloat((self.cardViews.count - index)) * 20.0)
                let position_y  : CGFloat   = CGFloat(index) * 7.0
                var frame                   = view.frame
                frame.origin.x              = w - (width/2)
                if index == self.cardViews.count - 1
                {
                    frame.origin.y              = topPosition == 0.0 ?  position_y : position_y + topPosition - 40
                }
                else
                {
                    frame.origin.y              = position_y + topPosition
                }
                
                frame.size.width            = width
                view.frame                  = frame
            }
        }
        self.scrollView.layoutSubviews()
    }
    
    
    /**
     결제 카드 정보를 하단에 순차적으로 디스플레이 되도록 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.10
     - Parameters:
        - index : 순차적으로 보여질 카드 인덱스 정보 입니다.
        - completion : 이벤트 완료 처리를 리턴 합니다.
     - Throws : False
     - returns :False
     */
    func setCardFullAniClose( index : Int = 0, completion : (( _ success : Bool ) -> Void)? = nil )
    {
        DispatchQueue.global(qos: .userInteractive).async {
            var cardView : UIView?
            /// 디스플레이할 카드 인덱스 정보를 가져 옵니다.
            var viewIndex = index
            while(true)
            {
                Thread.sleep(forTimeInterval: 0.001)
                print("viewIndex : \(viewIndex)")
                /// 카드뷰어를 가져 옵니다.
                if let view = self.cardViews[viewIndex] { cardView = view }
                break
            }
            
            DispatchQueue.main.async {
                /// 카드뷰어가 있을경우 위치르 변경 합니다.
                if let view = cardView
                {
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn) {
                        let mainw       : CGFloat   = self.frame.size.width/2
                        let width       : CGFloat   = ( self.frame.size.width - 40.0 ) - ( CGFloat((self.cardViews.count - viewIndex)) * 20.0)
                        let position_y  : CGFloat   = CGFloat(viewIndex) * 7.0
                        var frame                   = view.frame
                        frame.origin.x              = mainw - (width/2)
                        frame.origin.y              = position_y + self.topPosition
                        frame.size.width            = width
                        view.frame                  = frame
                        /// 디스플레이할 카드 인덱스 정보를 변경 합니다.
                        viewIndex                   += 1
                        /// 최대 인덱스 정보를 체크 합니다.
                        if viewIndex == self.cardViews.count - 1
                        {
                            /// 마지막 카드뷰어를 추가 이동 합니다.
                            if let view = self.cardViews[viewIndex]
                            {
                                let mainw       : CGFloat   = self.frame.size.width/2
                                let width       : CGFloat   = ( self.frame.size.width - 40.0 ) - ( CGFloat((self.cardViews.count - viewIndex)) * 20.0)
                                let position_y  : CGFloat   = CGFloat(viewIndex) * 7.0
                                var frame                   = view.frame
                                frame.origin.x              = mainw - (width/2)
                                frame.origin.y              = position_y + 50
                                frame.size.width            = width
                                view.frame                  = frame
                            }
                        }
                    } completion: { _ in
                        if viewIndex < self.cardViews.count
                        {
                            /// 최대 인덱스 카드정보인 경우 입니다.
                            if viewIndex == self.cardViews.count - 1
                            {
                                self.setCardFullAniClose(index: viewIndex, completion: completion)
                                completion!(true)                                
                            }
                            else
                            {
                                self.setCardFullAniClose(index: viewIndex, completion: completion)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    /**
     결제 카드 전체 화면에 순차적으로 디스플레이 입니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.10
     - Parameters:
        - index : 순차적으로 디스플레이할 카드 인덱스 정보 입니다.
        - update_y : 순차적으로 디스플레이 할 위치 Y 좌표 입니다.
     - Throws : False
     - returns :False
     */
    func setCardFullDisplay( index : Int = -1, update_y : CGFloat = 0.0){
        /// 카드간의 간격 정보 입니다.
        let interval   = 12.0
        /// 카드 기본 위치 정보 입니다.
        var position_y = interval + update_y
        /// 카드 기본 넓이 입니다.
        let cardWidth  = self.frame.size.width - 40.0
        /// 카드 기본 높이 입니다.
        let cardHeight = 208.0
        DispatchQueue.global(qos: .userInteractive).async {
            /// 디스플레이할 카드 인덱스 정보를 가져 옵니다.
            var viewIndex = index == -1 ? self.cardViews.count - 1 : index
            /// 디스플레이할 카드 입니다.
            var cardView : UIView?
            while(true)
            {
                Thread.sleep(forTimeInterval: 0.001)
                print("viewIndex : \(viewIndex)")
                /// 카드뷰어를 가져 옵니다.
                if let view = self.cardViews[viewIndex] { cardView = view }
                break
            }
            
            DispatchQueue.main.async {
                /// 카드뷰어가 있을경우 위치르 변경 합니다.
                if let view = cardView
                {
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut) {
                        let mainw           = self.frame.size.width/2
                        var frame           = view.frame
                        frame.origin.x      = mainw - (cardWidth/2)
                        frame.origin.y      = position_y
                        frame.size.width    = cardWidth
                        frame.size.height   = cardHeight
                        view.frame          = frame
                        position_y          += cardHeight
                        /// 디스플레이할 카드 인덱스 정보를 변경 합니다.
                        viewIndex -= 1
                        /// 최소 인덱스 정보를 체크 합니다.
                        if viewIndex >= 0
                        {
                            /// 마지막 카드뷰어를 추가 이동 합니다.
                            if let nextView = self.cardViews[viewIndex]
                            {
                                /// 카드 리스트 뷰어의 전체 넓이 입니다.
                                let mainw           = self.frame.size.width/2
                                var frame           = nextView.frame
                                frame.origin.x      = mainw - (cardWidth/2)
                                frame.origin.y      -= 100
                                frame.size.width    = cardWidth
                                frame.size.height   = cardHeight
                                nextView.frame      = frame
                            }
                        }
                    } completion: { _ in
                        if viewIndex > -1
                        {
                            /// 남은 카드 정보를 추가 디스플레이 합니다.
                            self.setCardFullDisplay(index: viewIndex, update_y: position_y)
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let event = self.btnEvent
        {
            self.listEnabledBtn.isHidden = true
            event(true)
        }
    }
}

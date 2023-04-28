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
    var cardViews : [OKZeroPayCardView?] = []
    
    
    
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
        cardview.cardBGColor.setGradientRightDownLeftTop(color1: colors.c1, color2: colors.c2)
        return cardview
    }

    
    /**
     결제 카드 전체 화면 종료로 하단에 디스플레이 되도록 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.28
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setCardFullClose(){
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
                frame.origin.y              = position_y
                frame.size.width            = width
                view.frame                  = frame
            }
        }
        self.scrollView.layoutSubviews()
    }
    
    
    /**
     결제 카드 전체 화면 디스플레이 입니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.28
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setCardFullDisplay(){
        /// 시작 인덱스 정보를 가집니다.
        var startIndex = 0
        /// 카드간의 간격 정보 입니다.
        let interval   = 12.0
        /// 카드 기본 위치 정보 입니다.
        var position_y = interval
        /// 카드 기본 넓이 입니다.
        var cardWidth  = 350.0
        /// 카드 기본 높이 입니다.
        var cardHeight = 208.0
        /// 저장된 카드리스트에 뒤에서 부터 0번째 순으로 디스플레이 하도록 합니다.
        for viewIndex in (0..<self.cardViews.count).reversed()
        {
            /// 0번째 위치는 정상 디스플레이로 하단 있을때 그대로 디스플레이 합니다.
            if startIndex == 0 {
                position_y += cardHeight + interval
                /// 카드의 기본 사이즈를 가져 옵니다.
                if let view = self.cardViews[viewIndex]
                {
                    cardWidth  = view.frame.size.width
                    cardHeight = view.frame.size.height
                }
                startIndex += 1
                continue
            }
            /// 카드 리스트 뷰어의 전체 넓이 입니다.
            let mainw = self.frame.size.width/2
            /// 각 카드뷰어를 가져 옵니다.
            if let view = self.cardViews[viewIndex]
            {
                var frame           = view.frame
                frame.origin.x      = mainw - (cardWidth/2)
                frame.origin.y      = position_y
                frame.size.width    = cardWidth
                frame.size.height   = cardHeight
                view.frame          = frame
            }
            /// 카드뷰어의 위치값을 추가 합니다.
            position_y += cardHeight + interval
        }
        self.scrollView.layoutSubviews()
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

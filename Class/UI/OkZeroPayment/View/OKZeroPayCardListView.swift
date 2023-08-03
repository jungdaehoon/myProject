//
//  OKZeroPayCardListView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/28.
//

import UIKit


/// 카드 전체화면 디스플레이 할 경우 높이 값입니다.
private let CARD_DEFUALT_HEIGHT : CGFloat = 208.0
/// 카드 전체화면 디스플레이 할 경우 넓이 값입니다.
private let CARD_DEFUALT_WIDTH  : CGFloat = 350.0

/**
 제로페이 결제 가능 카드 리스트 뷰어 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.04.28
 */
class OKZeroPayCardListView: UIView {
    var viewModel                       : OKZeroViewModel = OKZeroViewModel()
    /// 카드 디스플레이 하는 스크롤 뷰어 입니다.
    @IBOutlet weak var scrollView       : UIScrollView!
    /// 코드 선택시 이벤트 입니다.
    var btnEvent                        : (( _ success : Bool ) -> Void)? = nil
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
     제로페이 결제 가능 카드뷰어 초기화 합니다.  ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.28
     */
    func initZeroPayCardList(){
        self.commonInit()
    }
    
    
    /**
     카드 정보의 이벤트를 연결 합니다..( J.D.H VER : 1.24.43 )
     - Date: 2023.04.28
     - Parameters:
        - btnEvent : 버튼 이벤트를 넘깁니다.
     - Throws: False
     - Returns:False
     */
    func setEvent( btnEvent : (( _ success : Bool ) -> Void)? = nil ){
        self.btnEvent = btnEvent
    }
    
    
    /**
     최초 카드 정보를 화면에 추가 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.28
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setCardDisplay( model : ZeroPayOKMoneyResponse? = nil ) {
        if self.scrollView != nil {
            let _ = self.scrollView.subviews.map { $0.removeFromSuperview() }
        }
        self.cardViews.removeAll()
        
        /// 카드 그라데이션 컬러 입니다.
        let colors : [(start : UIColor, end : UIColor)]  = [(UIColor(hex: 0x666666),UIColor(hex: 0xF6F6F6)),(UIColor(hex: 0xFF5300),UIColor(hex: 0xFD9200))]
        /// 최대 카운트 3개 입니다.
        let maxCount = 2
        /// 기본 카드 뷰어를 설정 합니다.
        for index in 0..<maxCount
        {
            let cardview : OKZeroPayCardView    = OKZeroPayCardView()
            let width : CGFloat                 = ( self.frame.size.width - 40.0 ) - ( CGFloat((maxCount - index)) * 20.0)
            let size                            = CGSize(width: width, height: CARD_DEFUALT_HEIGHT)
            let point                           = CGPoint(x: self.frame.size.width/2 - size.width/2, y: CGFloat(index) * 7.0)
            cardview.frame                      = CGRect(origin: point, size: size)
            switch index {
                case 1 :
                    cardview.setDisplayView(displayType: .okmoney, colors: colors[index], model: model)
                    break
                case 0 :
                    cardview.setDisplayView(displayType: .banner, model: model)
                    break
                default:break
            }
            cardview.setDisplayChange(bottomMode: true, model: model)
            self.cardViews.append(cardview)
            self.scrollView.addSubview(cardview)
        }
    }
    
    
    /**
     카드 디스플레이 입니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.28
     - Parameters:
        - position_y : 카드 y 좌표 위치 입니다.
        - width : 카드 넓이 입니다.
        - colors : 카드 컬러 입니다.
     - Throws: False
     - Returns:False
     */
    func getCardView( position_y : CGFloat = 0.0, width : CGFloat = 0.0, colors : ( start : UIColor, end : UIColor) ) -> OKZeroPayCardView? {
        let cardview : OKZeroPayCardView    = OKZeroPayCardView()
        let size                            = CGSize(width: width, height: CARD_DEFUALT_HEIGHT)
        let point                           = CGPoint(x: self.frame.size.width/2 - size.width/2, y: position_y)
        cardview.frame                      = CGRect(origin: point, size: size)
        cardview.setCardBGColor( colors: colors )
        return cardview
    }

    
    /**
     카드 위치 값을 변경 합니다.  ( J.D.H VER : 1.24.43 )
     - Description: 카드 전체 뷰어인 스크롤 뷰어의 높이 값 변경되기 전에 카드 애니 효과로 이동하기전 시작 위치 값을 설정 합니다.
     - Date: 2023.05.10
     - Parameters:
        - startPosition : 카드가 위치할 시작점 위치 정보 입니다.
     - Throws: False
     - Returns:False
     */
    func setCardListPosition( startPosition : CGFloat = 0.0 ){
        /// 최대 상단 포지션을 저장 합니다.
        self.topPosition = startPosition
        /// 저장된 카드들의 위치 값을 변경 하도록 합니다.
        for index in 0..<self.cardViews.count
        {
            let w = self.frame.size.width/2
            /// 카드의 기본 사이즈를 가져 옵니다.
            if let cardView = self.cardViews[index]
            {
                let width       : CGFloat   = ( self.frame.size.width - 40.0 ) - ( CGFloat((self.cardViews.count - index)) * 20.0)
                let position_y  : CGFloat   = CGFloat(index) * 7.0
                var frame                   = cardView.frame
                frame.origin.x              = w - (width/2)
                if index == self.cardViews.count - 1
                {
                    frame.origin.y              = topPosition == 0.0 ?  position_y : position_y + topPosition - 40
                }
                else
                {
                    frame.origin.y              = position_y + topPosition
                }
                
                frame.size.width = width
                cardView.frame   = frame
                cardView.setCardBGColor()
                cardView.setDisplayChange(bottomMode: startPosition == 0.0 ? true : false, model: OKZeroViewModel.zeroPayOKMoneyResponse)
            }
        }
        self.scrollView.layoutSubviews()
    }
    
    
    /**
     결제 카드 정보를 하단에 순차적으로 디스플레이 되도록 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.05.10
     - Parameters:
        - index : 순차적으로 보여질 카드 인덱스 정보 입니다.
        - completion : 이벤트 완료 처리를 리턴 합니다.
     - Throws: False
     - Returns:False
     */
    func setCardFullAniClose( index : Int = 0, completion : (( _ success : Bool ) -> Void)? = nil )
    {
        DispatchQueue.global(qos: .userInteractive).async {
            /// 위치 정보 변경 할 카드 정보 입니다.
            var cardView : OKZeroPayCardView?
            /// 디스플레이할 카드 인덱스 정보를 가져 옵니다.
            var viewIndex = index
            while(true)
            {
                Thread.sleep(forTimeInterval: 0.001)
                /// 카드뷰어를 가져 옵니다.
                if let view = self.cardViews[viewIndex] { cardView = view }
                break
            }
            
            DispatchQueue.main.async {
                /// 카드뷰어가 있을경우 위치르 변경 합니다.
                if let ingCardView = cardView
                {
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn) {
                        /// 카드의 Frame 정보를 변경 합니다.
                        let _ = self.setCardReFrame( cardView: ingCardView, index: viewIndex, position: self.topPosition, cardFullSize: true )
                        /// 디스플레이할 카드 인덱스 정보를 변경 합니다.
                        viewIndex += 1
                        
                        /// 마지막 전 카드인 경우 마지막 카드 미리 위치값 일부를 변경 합니다.
                        if viewIndex == self.cardViews.count - 1
                        {
                            /// 마지막 카드뷰어를 추가 이동 합니다.
                            if let lastCardView = self.cardViews[viewIndex]
                            {
                                /// 카드의 Frame 정보를 변경 합니다.
                                let _ = self.setCardReFrame( cardView: lastCardView, index: viewIndex, position: 70, cardFullSize: true )
                            }
                        }
                         
                    } completion: { _ in
                        /// 최대 인덱스 카드정보인 경우 종료 처리 합니다.
                        if viewIndex == self.cardViews.count - 1 { completion!(true) }
                        else
                        {
                            /// 다음 카드 위치값을 조졀 하도록 다시 호출 합니다.
                            self.setCardFullAniClose(index: viewIndex, completion: completion)
                        }
                    }
                }
            }
        }
    }
    
    
    /**
     카드의 Frame 정보를 변경 합니다.. ( J.D.H VER : 1.24.43 )
     - Date: 2023.05.10
     - Parameters:
        - index : 순차적으로 보여질 카드 인덱스 정보 입니다.
        - completion : 이벤트 완료 처리를 리턴 합니다.
     - Throws: False
     - Returns:False
     */
    func setCardReFrame( cardView : OKZeroPayCardView? = nil, index : Int, position : CGFloat, cardFullSize : Bool = false ) -> CGFloat {
        if let cardView = cardView {
            let centerPosition : CGFloat = self.frame.size.width/2
            let cardViewWidth  : CGFloat = cardFullSize == true ? self.frame.size.width - 40.0 : ( self.frame.size.width - 40.0 ) - ( CGFloat((self.cardViews.count - index)) * 20.0)
            let cardViewHeight : CGFloat = cardFullSize == true ? CARD_DEFUALT_HEIGHT * (cardViewWidth/CARD_DEFUALT_WIDTH) : frame.size.height
            let position_y     : CGFloat = CGFloat(index) * 7.0
            var frame                    = cardView.frame
            frame.origin.x               = centerPosition - (cardViewWidth/2)
            frame.origin.y               = cardFullSize == true ? position : position_y + position
            frame.size.width             = cardViewWidth
            frame.size.height            = cardViewHeight
            cardView.frame               = frame
            cardView.setCardBGColor()
            return cardViewHeight
        }
        return CARD_DEFUALT_HEIGHT
    }
    
    
    /**
     결제 카드 전체 화면에 순차적으로 디스플레이 입니다. ( J.D.H VER : 1.24.43 )
     - Description: setCardListPosition 에서 카드위치 변경된 정보를 전체화면에 순차적으로 카드를 상단으로 하나씩 올리는 효과로 디스플레이 합니다.
     - Date: 2023.05.10
     - Parameters:
        - index : 순차적으로 디스플레이할 카드 인덱스 정보 입니다.
        - update_y : 순차적으로 디스플레이 할 위치 Y 좌표 입니다.
     - Throws: False
     - Returns:False
     */
    func setCardFullDisplay( index : Int = -1, update_y : CGFloat = 0.0){
        /// 카드간의 간격 정보 입니다.
        let interval   = 12.0
        /// 카드 기본 위치 정보 입니다.
        var position_y = interval + update_y
        DispatchQueue.global(qos: .userInteractive).async {
            /// 디스플레이할 카드 인덱스 정보를 가져 옵니다.
            var viewIndex = index == -1 ? self.cardViews.count - 1 : index
            /// 디스플레이할 카드 입니다.
            var cardView : OKZeroPayCardView?
            while(true)
            {
                Thread.sleep(forTimeInterval: 0.001)
                Slog("viewIndex : \(viewIndex)")
                /// 카드뷰어를 가져 옵니다.
                if let view = self.cardViews[viewIndex] { cardView = view }
                break
            }
            
            DispatchQueue.main.async {
                /// 카드뷰어가 있을경우 위치르 변경 합니다.
                if let ingCardView = cardView
                {
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut) {
                        /// 카드의 Frame 정보를 변경 합니다.
                        position_y  += self.setCardReFrame( cardView: ingCardView, index: viewIndex, position: position_y, cardFullSize: true )
                        /// 디스플레이할 카드 인덱스 정보를 변경 합니다.
                        viewIndex   -= 1
                        /// 마지막 인덱스 인지를 체크 합니다.
                        if viewIndex == 0
                        {
                            /// 마지막 카드뷰어를 추가 이동 합니다.
                            if let lastCardView = self.cardViews[viewIndex]
                            {
                                /// 카드의 Frame 정보를 변경 합니다.
                                let _ = self.setCardReFrame( cardView: lastCardView, index: viewIndex, position: lastCardView.frame.origin.y - 100 , cardFullSize: true )
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
    
    
    //MARK: - setRelease
    /**
     데이터를 초기화합니다.  ( J.D.H VER : 1.24.43 )
     - Date: 2023.07.10
     */
    func setRelease(){
        self.cardViews.removeAll()
        if let scrollView = self.scrollView {
           let _ = scrollView.subviews.map { $0.removeFromSuperview() }
        }
    }
    
}

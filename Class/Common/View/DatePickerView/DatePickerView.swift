//
//  DatePickerView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/18.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit

/**
 날짜 정보를 PickerView 디스플레이 합니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.17
 */
class DatePickerView: BaseView {

    @IBOutlet weak var pickerView: PickerView!
    /// 왼쪽 버튼 팝업 종료 이벤트를 넘깁니다.
    var completion                  : (( _ value : Date ) -> Void )? = nil
    
    //MARK: - Init
    init(){
        super.init(frame: UIScreen.main.bounds)
        self.setDatePickerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    //MARK: - 지원 메서드 입니다.
    func setDatePickerView(){
        commonInit()
    }

    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.17
     - Parameters:
        - displayType   : 날짜 디스플레이 모드 값입니다. ( YMD : 년/월/일, YM : 년/월, Y : 년, D : 일 )
        - selectDate    : 선택 날짜 입니다.
        - maxDate       : 최대 날짜 입니다.
        - minDate       : 최소 날짜 입니다.
        - completion    : 선택된 날짜 정보를 리턴 합니다.
     - Throws: False
     - Returns:False
     */
    func setDisplayView( _ displayType : DATE_TYPE, selectDate : String, maxDate : String, minDate : String, completion : (( _ value : Date ) -> Void )? = nil  ){
        /// 데이터 콜백을 연결 합니다.
        self.completion                 = completion
        /// 디스플레이 타입을 설정 합니다.
        self.pickerView.displayType     = displayType
        /// 디스플레이할 날짜 정보를 설정 합니다.
        self.pickerView.setPicketInfoDate( minDate: minDate, maxDate: maxDate, setDate: selectDate)
        ///< 화면을 디스플레이 합니다.
        self.show()
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.17
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        if let base = base {
            DispatchQueue.main.async {
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0 is DatePickerView
                {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        self.completion!(self.pickerView.seletedDate!)
        self.hide()
    }
}

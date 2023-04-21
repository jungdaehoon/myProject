//
//  PickerView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/18.
//

import UIKit

/**
 날짜 디스플레이 타입 입니다. ( J.D.H  VER : 1.0.0 )
 - Description
    - YMD : 년/월/일, YM : 년/월, Y : 년, D : 일
 - Date : 2023.04.20
*/
enum DATE_TYPE : String {
    /// 년/월/일 형태로 디스플레이 합니다.
    case all_date   = "YMD"
    /// 년/월 형태로 디스플레이 합니다.
    case year_month = "YM"
    /// 년 형태로 디스플레이 합니다.
    case year       = "Y"
    /// 일 형태로 디스플레이 합니다.
    case day        = "D"
}


/**
 날짜 디스플레이 데이터 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.20
*/
struct picker_info {
    /// 디스플레이할 년도 정보들을 가집니다.
    var years       : [Any?] = []
    /// 디스플레이할 월 정보들을 가집니다.
    var months      : [Any?] = []
    /// 디스플레이할 일 정보들을 가집니다.
    var days        : [Any?] = []
    /// 최소 년도 정보 입니다.
    var ingYear     : Int?
    /// 최대 년도 정보 입니다.
    var ingMonth    : Int?
    /// 최대 일 정보 입니다.
    var ingDay      : Int?
    /// 최소 년도 정보 입니다.
    var minYear     : Int?
    /// 최대 년도 정보 입니다.
    var maxYear     : Int?
    /// 최소 월 정보 입니다.
    var minMonth    : Int?
    /// 최대 월 정보 입니다.
    var maxMonth    : Int?
    /// 최소 일 정보 입니다.
    var minDay      : Int?
    /// 최대 일 정보 입니다.
    var maxDay      : Int?
}



/**
 DatePickerView 에 사용되는 UIPickerView 오버라이딩 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.20
*/
class PickerView: UIPickerView {
    /// 디스플레이 타입 입니다. ( YMD : 년/월/일, YM : 년/월, Y : 년, D : 일 )
    var displayType : DATE_TYPE?
    /// 피커뷰 디스플레이할 데이터 정보 입니다.
    var pickerInfo  : picker_info? = picker_info()
    
    
    
    //MARK: - Setter
    /// 선택 날짜 정보 입니다.
    var seletedDate : Date? {
        didSet
        {
            if let date = seletedDate {
                let comps                   = NSCalendar.current.dateComponents([.year,.month,.day], from: date)
                self.pickerInfo!.ingYear    = comps.year
                self.pickerInfo!.ingMonth   = comps.month
                self.pickerInfo!.ingDay     = comps.day
            }
        }
    }
    
    /// 최소 날짜 정보 입니다.
    var minDate     : Date? {
        didSet
        {
            if let date = minDate {
                let comps                   = NSCalendar.current.dateComponents([.year,.month,.day], from: date)
                self.pickerInfo!.minYear    = comps.year
                self.pickerInfo!.minMonth   = comps.month
                self.pickerInfo!.minDay     = comps.day
            }
        }
    }
    
    /// 최대 날짜 정보 입니다.
    var maxDate     : Date? {
        didSet
        {
            if let date = maxDate {
                let comps                   = NSCalendar.current.dateComponents([.year,.month,.day], from: date)
                self.pickerInfo!.maxYear    = comps.year
                self.pickerInfo!.maxMonth   = comps.month
                self.pickerInfo!.maxDay     = comps.day
            }
        }
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     디스플레이할 날짜 정보를 설정 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.20
     - Parameters:
        - maxDate : 최대 날짜 입니다.
        - minDate : 최소 날짜 입니다.
        - setDate : 선택 날짜 입니다.
     - Throws : False
     - returns :False
     */
    func setPicketInfoDate( minDate : String, maxDate : String, setDate : String )
    {
        
        /// 최소 날짜 정보 입니다.
        self.minDate                = self.getStringToDate(minDate)
        /// 최대 날짜 정보 입니다.
        self.maxDate                = self.getStringToDate(maxDate)
        /// 선탠된 날짜 정보 입니다.
        self.seletedDate            = self.getStringToDate(setDate)
        /// 현 날짜 정보를 가져 옵니다.
        let comps : DateComponents  = NSCalendar.current.dateComponents([.year,.month,.day], from: self.seletedDate!)
        /// 일 정보를 세팅 합니다.
        self.pickerInfo!.days       = self.getDays(year: comps.year!, month: comps.month!)
        ///< 월 정보를 세팅 합니다.
        self.pickerInfo!.months     = self.getMonths(year: comps.year!)
        ///< 년도 정보를 세팅 합니다.
        self.pickerInfo!.years      = self.getYear()
        
        self.dataSource             = self
        self.delegate               = self
        /// 기본 위치를 세팅 합니다.
        self.setComponentDate()
    }
    
    
    /**
     문자형 날짜 정보를 Date 형으로 변환 하여 리턴 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.20
     - Parameters:
        - dateText : 변환할 String 날짜 정보 합니다.
     - Throws : False
     - returns :
        - Date
            + 변환된 Date 날짜 정보 입니다.
     */
    func getStringToDate( _ dateText : String ) -> Date
    {
        let formatter : DateFormatter   =  DateFormatter()
        formatter.dateFormat            = "yyyyMMdd"
        return formatter.date(from: dateText)!
    }
    
    
    /**
     현 "월" 정보에 따른 디스플레이 가능한 "일" 정보를 리턴 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.20
     - Parameters:
        - year : 년도 정보를 받습니다.
        - month : 월 정보를 받습니다.
     - Throws : False
     - returns :
        - [String]
            + 총 "일" 정보를 리턴 합니다.
     */
    func getDays( year : Int, month : Int) -> [String]
    {
        /// 선택된 년/월 정보를 세팅 합니다.
        var ingComps : DateComponents   = DateComponents()
        ingComps.month                  = month
        ingComps.year                   = year
        let ingDate                     = Calendar.current.date(from: ingComps)
        /// 년/월에 최대 날자 정보를 가져 옵니다.
        let daysRange                   = Calendar.current.range(of: .day, in: .month, for: ingDate!)
        var days : [String]             = []
        for index in 1..<daysRange!.count + 1
        {
            if year >= self.pickerInfo!.maxYear!,
               month >= self.pickerInfo!.maxMonth!,
               index > self.pickerInfo!.maxDay!
            {
                break
            }
            days.append("\(index)일")
        }
        return days
    }
    
    
    /**
     현 "년" 정보에 따른 디스플레이 가능한 "월" 정보를 리턴 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.20
     - Parameters:
        - year : 년도 정보를 받습니다.
     - Throws : False
     - returns :
        - [String]
            + 총 "월" 정보를 리턴 합니다.
     */
    func getMonths( year : Int ) -> [String]
    {
        ///< 월 정보를 세팅 합니다.
        let dateFormatter       = DateFormatter()
        dateFormatter.locale    = Calendar.current.locale
        
        if let maxMonth = self.pickerInfo!.maxMonth
        {
            if let maxYear = self.pickerInfo!.maxYear,
               year < maxYear
            {
                return dateFormatter.monthSymbols
            }
            else
            {
                var months : [String] = []
                for index in 0..<maxMonth
                {
                    months.append(dateFormatter.monthSymbols[index])
                }
                return months
            }
        }
        return dateFormatter.monthSymbols
    }
    
    
    /**
     최대 디스플레이 가능한 "년" 정보를 리턴 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.20
     - Parameters:False
     - Throws : False
     - returns :
        - [String]
            + 총 "년" 정보를 리턴 합니다.
     */
    func getYear() -> [String]
    {
        ///< 년도 정보를 세팅 합니다.
        let dateFormatter                   = DateFormatter()
        dateFormatter.locale                = Calendar.current.locale
        dateFormatter.dateFormat            = "yyyy"
        var yearComps   : DateComponents    = DateComponents()
        var years       : [String]          = []
        for index in self.pickerInfo!.minYear!..<self.pickerInfo!.maxYear! + 1
        {
            yearComps.year = index
            let yearDate = Calendar.current.date(from: yearComps)
            years.append("\(dateFormatter.string(from: yearDate!))년")
        }
        return years
    }
    
    
    /**
     seletedDate 정보로 PickerView 디스플레이 Row 설정 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.20
     - Parameters:
        - animation : PickerView Row 데이터 설정시 애니 효과 여부 입니다.
     - Throws : False
     - returns : False
     */
    func setComponentDate( animation : Bool = false )
    {
        /// 현 날짜 정보를 가져 옵니다.
        let comps : DateComponents  = NSCalendar.current.dateComponents([.year,.month,.day], from: self.seletedDate!)
        
        let year    = comps.year! - self.pickerInfo!.minYear!
        let month   = comps.month! - 1
        let day     = comps.day! - 1
        
        switch  self.displayType {
            /// 년/월/일 정보 일 경우 ㅇ빈디ㅏ.
        case .all_date:
            self.selectRow(year, inComponent: 0, animated: animation)
            self.selectRow(month, inComponent: 1, animated: animation)
            self.selectRow(day, inComponent: 2, animated: animation)
            /// 년/월 정보 일 경우 입니다.
        case .year_month:
            self.selectRow(year, inComponent: 0, animated: animation)
            self.selectRow(month, inComponent: 1, animated: animation)
            /// 년도 디스플레이 입니다.
        case .year:
            self.selectRow(year, inComponent: 0, animated: animation)
            /// 일 디스플레이 입니다.
        case .day:
            self.selectRow(day, inComponent: 0, animated: animation)
        default:
            break
        }
    }
    
    
    /**
    선택된 날짜 정보를 정리하여 Date 정보로 리턴합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.20
     - Parameters:
        - component : 선택 인덱스 입니다.
     - Throws : False
     - returns :
        - Date
            + 선택된 Date 날짜 정보 입니다.
     */
    func getDateSeleted( component : Int ) -> Date? {
        var selectYear      = 2030
        var selectMonth     = 1
        var selectDay       = 31
        var monthsChange    = false
        var daysChange      = false
        
        switch self.displayType
        {
        case .all_date:
            /// 년도 정보를 설정 합니다. 합니다.
            selectYear = self.selectedRow(inComponent: 0) + self.pickerInfo!.minYear!
            /// 년도 정보를 변경 할 경우 입니다.
            if component == 0
            {
                /// 선택된 년도의 최대 "월" 정보를 설정 옵니다.
                self.pickerInfo!.months = self.getMonths(year: selectYear)
                if self.selectedRow(inComponent: 1) + 1 > self.pickerInfo!.months.count
                {
                    monthsChange = true
                }
                self.reloadComponent(1)
            }
            
            selectMonth = monthsChange ? self.pickerInfo!.months.count : self.selectedRow(inComponent: 1) + 1
            
            if component != 2
            {
                /// 선택된 최대 "일" 정보를 설정 합니다.
                self.pickerInfo!.days = self.getDays(year: selectYear, month: selectMonth)
                if self.selectedRow(inComponent: 2) + 1 > self.pickerInfo!.days.count
                {
                    daysChange = true
                }
                self.reloadComponent(2)
            }
            /// 일 정보를 설정 합니다.
            selectDay = daysChange ? self.pickerInfo!.days.count : self.selectedRow(inComponent: 2) + 1
            break
        case .year_month:
            /// 년도 정보를 설정 합니다. 합니다.
            selectYear = self.selectedRow(inComponent: 0) + self.pickerInfo!.minYear!
            /// 일 단위가 월 날짜 보다 많으면 다음 달 체크로 월 단위 체크로 최소 나라ㅉ 정보를 2월 기준으로 진행 합니다.
            selectDay  = 28
            /// 년도 정보를 변경 할 경우 입니다.
            if component == 0
            {
                /// 선택된 년도의 최대 "월" 정보를 설정 옵니다.
                self.pickerInfo!.months = self.getMonths(year: selectYear)
                if self.selectedRow(inComponent: 1) + 1 > self.pickerInfo!.months.count
                {
                    monthsChange = true
                }
                self.reloadComponent(1)
            }
            
            selectMonth = monthsChange ? self.pickerInfo!.months.count : self.selectedRow(inComponent: 1) + 1
            break
        case .day:
            selectDay = self.selectedRow(inComponent: 0) + 1
            break
        default:break
        }
        
        var comps       = DateComponents()
        comps.day       = selectDay
        comps.month     = selectMonth
        comps.year      = selectYear
        return Calendar.current.date(from: comps)
    }
}


//MARK: - UIPickerViewDelegate
extension PickerView : UIPickerViewDelegate
{
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var textView = view as? UILabel
        if textView == nil
        {
            let rowSize                         = pickerView.rowSize(forComponent: component)
            textView                            = UILabel.init(frame: CGRect(origin: .zero, size: rowSize))
            textView!.font                      = UIFont.systemFont(ofSize: 24.0)
            textView!.textAlignment             = .center
            textView!.adjustsFontSizeToFitWidth = true
        }
        
        /// 디스플레이 타입에 따라 디스플레이 합니다.
        switch self.displayType
        {
            /// 년/월/일 형태로 디스플레이 합니다.
            case .all_date:
                switch component {
                case 0:
                    textView!.text = NC.S(self.pickerInfo!.years[row] as? String)
                case 1:
                    textView!.text = NC.S(self.pickerInfo!.months[row] as? String)
                case 2:
                    textView!.text = NC.S(self.pickerInfo!.days[row] as? String)
                default:
                    break
                }
            /// 년/월 형태로 디스플레이 합니다.
            case .year_month:
                switch component {
                case 0:
                    textView!.text = NC.S(self.pickerInfo!.years[row] as? String)
                case 1:
                    textView!.text = NC.S(self.pickerInfo!.months[row] as? String)
                default:
                    break
                }
            /// 년 형태로 디스플레이 합니다.
            case .year:
                textView!.text = NC.S(self.pickerInfo!.years[row] as? String)
            /// 일 형태로 디스플레이 합니다.
            case .day:
                textView!.text = NC.S(self.pickerInfo!.days[row] as? String)
            default:break
        }
        
        return textView!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        ///< 선택된 날짜 정보를 가져 옵니다.
        self.seletedDate =  self.getDateSeleted(component: component)
    }
}



//MARK: - UIPickerViewDataSource
extension PickerView : UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        /// 타입에 따라 PickerView 디스플레이 셀 입니다.
        switch self.displayType {
        case .all_date:
            return 3
        case .year_month:
            return 2
        case .year, .day:
            return 1
        default:
            break
        }
        return 3
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        /// 타입에 따라 셀당 디스플레이할 총 카운트 입니다.
        switch self.displayType {
        case .all_date:
            switch component {
            case 0:
                return self.pickerInfo!.years.count
            case 1:
                return self.pickerInfo!.months.count
            case 2:
                return self.pickerInfo!.days.count
            default:
                break
            }
            return 3
        case .year_month:
            if component == 0
            {
                return self.pickerInfo!.years.count
            }
            return self.pickerInfo!.months.count
        case .year:
            return self.pickerInfo!.years.count
        case .day :
            return self.pickerInfo!.days.count
        default:
            break
        }
        return 0
    }
}

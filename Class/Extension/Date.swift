//
//  Date.swift
//  MyData
//
//  Created by UMCios on 2022/01/06.
//

import Foundation

extension Date {
    
    func addedBy(minutes:Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func addedBy(seconds:Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
    
    func addedBy(months: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .month, value: months, to: self)!
    }

    /**
     받은 DateFormat  정보 기준으로 해당 날짜 정보를 String 리턴 됩니다. ( J.D.H  VER : 1.0.0 )
    - Date : 2023.02.23
    - Parameters:
        - typetText : 날짜 타입 스타일 정보를 받습니다. ( DateFormat )
    - Returns
        - String Type
            > 변경된 날짜 정보를 리턴 합니다.
     */
    func getTypeString( _ typetText : String ) -> String?
    {
        let formatter           = DateFormatter()
        formatter.calendar      = Calendar(identifier: .gregorian)
        formatter.dateFormat    = typetText
        let dateStr : String?   = formatter.string(from: self)
        if  dateStr == nil { return typetText }
        return dateStr!
    }
    
    // YYYYMM
    var yyyyMMString: String {
        let date = self
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMM"
        let dateStr = formatter.string(from: date) //"201706"
        return dateStr
    }
    
    // YYYYMMDD
    var yyyyMMddString: String {
        let date = self
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMdd"
        let dateStr = formatter.string(from: date) //"20170612"
        return dateStr
    }
    
    // YYYYMMDD
    var yyyyMMddDotString: String {
        let date = self
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy.MM.dd"
        let dateStr = formatter.string(from: date) //"2017.06.12"
        return dateStr
    }
    
    
    // YYYYMMDDhhmmss
    var yyyyMMddHHmmssString: String {
        let date = self
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMddHHmmss"
        let dateStr = formatter.string(from: date) //"20150320121510"
        return dateStr
    }

    // YYYYMMDDhhmm
    var yyyyMMddHHmmString: String {
        let date = self
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMddHHmm"
        let dateStr = formatter.string(from: date) //"201503201215"
        return dateStr
    }
    
    var dateFormatWithPipe: String { //한국으로 Locale 설정필요
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
//        dateFormatter.locale = try! Locale(from: "ko_KR" as! Decoder)
     //   dateFormatter.dateFormat = "yyyy.MM.dd|hh:mm:ss|E"
        dateFormatter.dateFormat = "yyyy.MM.dd|HH:mm:ss|E"
        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }
    
    // YYYYMMDDhhmm
    func getTodayAndResetTimePart(HHmm:String) -> Date { //HHmm ==> 13:30 꼴이어야 함.
        let splitWithColon = HHmm.components(separatedBy:":")
        let hourStr:String = (splitWithColon[0] as? String)!
        let minStr:String = (splitWithColon[1] as? String)!
        
        //시간, 분, 10 보다 작은경우때문에 재계산. 앞에 0 넣기 로직까지 필요
        let hour:Int = Int(hourStr)!
        let min:Int = Int(minStr)!
        
        var HH:String = ""
        if hour < 10 {
            HH = "0\(hour)"
        } else {
            HH = "\(hour)"
        }
        
        var mm:String = ""
        if min < 10 {
            mm = "0\(min)"
        } else {
            mm = "\(min)"
        }
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMddHHmm"
        let yyyyMMdd:String = Date().yyyyMMddString
        let result:String = "\(yyyyMMdd)\(HH)\(mm)"
        let resultDate:Date = formatter.date(from: result)!
        return resultDate
    }
    
    func isUrgentInspectionTime(from:Date, to:Date) -> Bool { // from : 점검 시작 시간, to: 점검 완료 시간,  Bool로 넘김
        var result:Bool = false
        let now:Date = Date()
        let delta1 = now.timeIntervalSince(from)
        if delta1 >= 0 { //now > from일때 여기 오네...
            let delta2 = to.timeIntervalSince(now)
            if delta2 >= 0 { //toDate > now일때 여기 오네...
            //여기가 아직 범위 시간
                result = true
            } else {
                //여기는 끝난 시간
                result = false
            }
        } else {
            //여기는 아직 시작전....
            result = false
        }
        return result
    }
}

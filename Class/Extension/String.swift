//
//  String.swift
//  MyData
//
//  Created by DaeHoon Chung on 2023/03/07.
//

import Foundation
import UIKit

extension String {
    
    /**
     문자 내부에 Html 문구가 들어있는 경우 해당 문구를 제외 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.06
     - Parameters:
        - htmlEncodedString : 체크할 문자 정보를 받습니다.
     - Throws: False
     - Returns:False
     */
    init?(htmlEncodedString: String) {
        if htmlEncodedString.contains("&amp;") == true
        {
            guard let data = htmlEncodedString.data(using: .utf8) else {
                return nil
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
                return nil
            }
            self.init(attributedString.string)
        }
        else
        {
            self.init(htmlEncodedString)
        }
    }
    
    
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
    
    var isValid: Bool {
        if !self.isEmpty && self.count > 0 {
            return true
        }
        return false
    }
    
    func getByteArray() -> [UInt8] {
        var byteArray = [UInt8]()
        for char in self.utf8 {
            byteArray += [char]
        }
        return byteArray
    }
    
    func getASCIIArray() -> [UInt8] {
        var byteArray = [UInt8]()
        for char in self {
            byteArray += [char.asciiValue!]
        }
        return byteArray
    }
    
    /**
     Hex 문자열을 byte array로 변환
     */
    func hexToByteArray() -> Array<UInt8> {
        guard let data = hexToData() else {
            return []
        }
        
        let byteArray = [UInt8](data)
        return byteArray
    }
    
    ///////////////////////////
    func padding16(text: String) -> Array<UInt8> {
        var dataArray = Array(text.utf8)
        if dataArray.count == 0 || dataArray.count % 16 != 0 {
            for _ in 0..<(16 - dataArray.count%16) {
                dataArray.append(0x20)
            }
        }
        
        return dataArray
    }

    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 일주일후..
    public static func expiredWeekDateYYYYMMDDString() -> String {
        let cal = Calendar(identifier: .gregorian)
        var date = cal.startOfDay(for: Date())
        date = cal.date(byAdding: .day, value: 7, to: date)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: date) //"20170612"
        return dateStr
    }
    
    // 1년 후
    public static func expiredYearDateYYYYMMDDString() -> String {
        let cal = Calendar(identifier: .gregorian)
        var date = cal.startOfDay(for: Date())
        date = cal.date(byAdding: .year, value: 1, to: date)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: date) //"20170612"
        return dateStr
    }

    // n Day 후..
    public static func expiredDayDateYYYYMMDDString(day: Int) -> String {
        let cal = Calendar(identifier: .gregorian)
        var date = cal.startOfDay(for: Date())
        date = cal.date(byAdding: .day, value: day, to: date)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }

    //날짜 체크: 오늘 기준으로 expire 여부. 날짜까지만 체크
    public func isExpiredDate() -> Bool {
        var endDate = self
        if self.length > 8 {
            endDate = self.substring(r: 0..<8)
        }
        if let expireDay = endDate.date(withFormat: "yyyyMMdd") {
            let todayString: String = "".dateYYYYMMDDString()
            let today: Date = todayString.date(withFormat: "yyyyMMdd")!
            if expireDay < today {
                return true
            }
        }
        
        return false
    }
    
    //yyyyMMddHHmm
    public func isExpiredDateTimeMin() -> Bool {
        if self.length < 12 { return false }
        
        var endDate = self
        if self.length > 12 {
            endDate = self.substring(r: 0..<12)
        }
        if let expire = endDate.date(withFormat: "yyyyMMddHHmm") {
            let currentString: String = Date().yyyyMMddHHmmString
            let current: Date = currentString.date(withFormat: "yyyyMMddHHmm")!
            if expire < current {
                return true
            }
        }
        
        return false
    }
    
    //============================================================
    // UInt8로...
    //============================================================
    
    public func int8Array() -> [UInt8] {
        var retVal : [UInt8] = []
        for thing in self.utf8 {
            retVal.append(thing)
        }
        return retVal
    }
    
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomLength = UInt32(letters.count)
        
        let randomString: String = (0 ..< length).reduce(String()) { accum, _ in
            let randomOffset = arc4random_uniform(randomLength)
            let randomIndex = letters.index(letters.startIndex, offsetBy: Int(randomOffset))
            return accum.appending(String(letters[randomIndex]))
        }
        
        return randomString
    }
    
    static func randomNumberString(length: Int) -> String {
        let letters = "0123456789"
        let randomLength = UInt32(letters.count)
        
        let randomString: String = (0 ..< length).reduce(String()) { accum, _ in
            let randomOffset = arc4random_uniform(randomLength)
            let randomIndex = letters.index(letters.startIndex, offsetBy: Int(randomOffset))
            return accum.appending(String(letters[randomIndex]))
        }
        
        return randomString
    }
    
    func highlightSubwordWithColor(_ searchWord: String, color: UIColor?, font: UIFont?) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: self)
        let nsstring = self as NSString
        var range = nsstring.range(of: searchWord, options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(0, nsstring.length))
        range = nsstring.range(of: searchWord, options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(0, nsstring.length))
        while range.location != NSNotFound {
            if let font = font {
                attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            }
            if let color = color {
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
            }
            range = nsstring.range(of: searchWord, options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(range.location+1, nsstring.length-range.location-1))
        }
        return attributedText
    }
    
    // email validate
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return self.regEx(regEx: emailRegEx)
    }

    func isValidName() -> Bool {
        if replacingOccurrences(of: " ", with: "").count < 2 {
            return false
        }
        let regEx = "[ 가-힣a-zA-Z]{2,}"
        return self.regEx(regEx: regEx)
    }
    
    func isValidPhoneNumber() -> Bool {
        let numbers = self.replacingOccurrences(of: "-", with: "")
        let regEx = "[0-9]{10,}"
        return numbers.regEx(regEx: regEx)
    }
    
    func regEx(regEx: String) -> Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }
    
    
    /**
     문자 중간중간에 빈칸을 추가 합니다.( J.D.H VER : 2.0.0 )
     - Date: 2023.07.18
     - Parameters:
        - distance : 간격 정보를 받습니다.  간격정보는 요청 한 간격 정보의 -1 값으로 적용 됩니다.( default : 5 )
     - Throws: False
     - Returns:
        간격별 빈찬 추가된 문자를 리턴 합니다. ( String? )
     */
    func addSpace( distance : Int = 5 ) -> String? {
        var allStr : String = "\(self)"
        let space: Character = " "

        /// 4번째 위치마다 빈 칸 추가 합니다.
        var currentIndex = allStr.startIndex
        while currentIndex < allStr.endIndex {
            if allStr.distance(from: allStr.startIndex, to: currentIndex) % distance == 0 {
                allStr.insert(space, at: currentIndex)
            }
            currentIndex = allStr.index(after: currentIndex)
        }

        /// 총 문자 길이 체크 합니다.
        while allStr.count < self.count {
            allStr.append(space)
        }
        return allStr
    }
    
    
    /**
     해당 마지막 정보들의 일부 영역을 마스킹 처리 합니다..( J.D.H VER : 2.0.0 )
     - Date: 2023.07.05
     - Parameters:
        - maskStr : 마스킹할 정보 입니다. ( default : * )
        - maskCnt : 뒤에서 부터 마스킹할 카운트 입니다. ( default : 4 )
     - Throws: False
     - Returns:
        마스킹 처리된 문구를 리턴 합니다. ( String? )
     */
    func setLastMasking( maskStr : String = "*", maskCnt : Int = 4 ) -> String?{
        if self.count > maskCnt
        {
            let first = self.left( self.count - maskCnt )
            var last : String = ""
            for _ in 0..<maskCnt
            {
                last += maskStr
            }
            return first+last
        }
        return self
    }
    
    
    var phoneNumberDash: String {
        let left = self.left(3)
        let middle = self.count == 11 ? self.mid(3, amount: 4) : self.mid(3, amount: 3)
        let right = self.right(4)
        return left + "-" + middle + "-" + right
    }
    
    // url에 parameter 형식을 dictionary로 변환
    // "Code=200&Message=&IPINAuthNum=11513&Name=9c9bbce53674a7343c3c86a43318742fa3d2aa8cfaf397d0a71a5f316774fe2a&Birth=264c6a085e4ab00ce754aa8f7330ce12&Nation=0&Gender=0"
    func queryStringToDic() -> [String:String] {
        let components:[String] = self.components(separatedBy: "&")
        var dictionary = [String:String]()
        
        for pairs in components {
            let pair = pairs.components(separatedBy: "=")
            if pair.count == 2 {
                dictionary[pair[0]] = pair[1]
            }
        }
        
        return dictionary
    }
    
    /**
     QueryString 파라미터 파싱
     - Parameter queryString: URL QueryString
     - Returns: NSDictionary 파싱된 데이터
     */
    func queryParameters(queryString: String) -> [String:Any] {
        var params = [String:AnyObject]()
        let keyValues = queryString.components(separatedBy: "&")
        for keyValue in keyValues {
            
            let keyValuePair = keyValue.components(separatedBy: "=")
            let key = keyValuePair[0]
            let value = keyValuePair[1]
            
            params[key] = value as AnyObject
        }
        
        return params
    }

    //============================================================
    // UILabel에 밑줄 친 텍스트 넣기.
    //============================================================
    static func addUnderbarString(value:String) -> NSMutableAttributedString {
        let retValue: NSMutableAttributedString =  NSMutableAttributedString(string: value)
        retValue.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSMakeRange(0, retValue.length))
        return retValue
    }
    
    func hexToData() -> Data? {
        var data = Data(capacity: self.count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else { return nil }
        return data
    }
    
    //============================================================
    // Json객체로 변경
    //============================================================
    func toJson() -> [String:Any] {
        var result:[String:Any] = [:]
        
        do {
            let data: Data = self.data(using: String.Encoding.utf8)!
            result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
        } catch {
            //Slog("json parse error : \(error)")
        }
        
        return result
    }
    
    //============================================================
    // 문자를 범위로 쪼갠다 배열로 넘겨줌
    //============================================================
    func substring(r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }
    
    //============================================================
    // 문자를 커터로 쪼갠후 (Key, Value)형식이면 index = 1번째 (0말고) value만 리턴한다.
    //============================================================
    func getValue(cutter:String) -> String { //Key[Cutter]Value형식.
        var retVal:String = ""
        let tempArr:[String] = self.stringToArray(cutter: cutter)
        
        if tempArr.count == 2 {
            retVal = tempArr[1]
        }
        return retVal
    }
    
    //============================================================
    // 문자를 커터로 쪼갠다 배열로 넘겨줌
    //============================================================
    func stringToArray(cutter:String) ->Array<String>{
        var retArray = Array<String>()
        retArray = self.components(separatedBy: cutter)
        return retArray
    }
    
    // LEFT
    // Returns the specified number of chars from the left of the string
    // let str = "Hello"
    // Slog(str.left(3))         // Hel
    func left(_ to: Int) -> String {
        return "\(self[..<self.index(startIndex, offsetBy: to)])"
    }
    
    // RIGHT
    // Returns the specified number of chars from the right of the string
    // let str = "Hello"
    // Slog(str.right(3))         // llo
    func right(_ from: Int) -> String {
        return "\(self[self.index(startIndex, offsetBy: self.length-from)...])"
    }
    
    // MID
    // Returns the specified number of chars from the startpoint of the string
    // let str = "Hello"
    // Slog(str.mid(2,amount: 2))         // ll
    func mid(_ from: Int, amount: Int) -> String {
        let x = "\(self[self.index(startIndex, offsetBy: from)...])"
        return x.left(amount)
    }
    
    //  현재 날짜를 문자열 날짜 포맷으로 변환
    func dateFormattedString() ->String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = self
        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }
    
    func dateString() ->String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        let dateStr = dateFormatter.string(from: date) //"20170605175100023"
        return dateStr
    }
    
    func dateYYYYMMString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMM"
        let dateStr = dateFormatter.string(from: date) //"201706"
        return dateStr
    }
    
    func dateKey() -> String {
        let dateStr = self.dateString()
        let keyLen  = dateStr.count >= 16 ? 16 : dateStr.count
        let key = dateStr.right(keyLen)
        return key
    }
    
    func dateYYYYMMDDString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStr = dateFormatter.string(from: date) //"20170612"
        return dateStr
    }
    
    func dateYYYYMMDDDotString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateStr = dateFormatter.string(from: date) //"2017.06.12"
        return dateStr
    }
    
    func dateType8AddDot() -> String { //self -> Must YYYYMMDD 꼴.
        if self.length != 8 {
            return self
        }
        
        let firstPart:String = self.substring(r: 0..<4)
        let midPart:String = self.substring(r:4..<6)
        let lastPart:String = self.substring(r:6..<8)
        
        return "\(firstPart).\(midPart).\(lastPart)"
    }
    
    func dateType6AddDot() -> String { //self -> Must YYYYMM 꼴.
        var retVal:String = ""
        if self.length < 6 { //8개로 안올수도 있네...
            return self
        }
        
        var firstPart:String = "" //self.substring(r: 0..<4)
        var midPart:String = "" //self.substring(r:4..<6)
        var lastPart:String = "" //self.substring(r:6..<8)
        
        firstPart = self.substring(r: 0..<4)
        midPart = self.substring(r: 4..<6)
        
        retVal = "\(firstPart).\(midPart)"
        if self.length >= 8 {
            lastPart = self.substring(r:6..<8)
            retVal = "\(firstPart).\(midPart).\(lastPart)"
        }
        
        return retVal
    }
    
    func dateType4AddDot() -> String { //self -> Must MMDD 꼴.
        if self.length != 8 {
            return self
        }
        let firstPart:String = self.substring(r: 0..<4)
        let midPart:String = self.substring(r:4..<6)
        let lastPart:String = self.substring(r:6..<8)
        
        return "\(midPart).\(lastPart)"
    }
    
    func timeType6AddColon() -> String { //self -> Must MMDD 꼴.
        if self.length != 6 {
            return self
        }
        let firstPart:String = self.substring(r: 0..<2)
        let midPart:String = self.substring(r:2..<4)
        let lastPart:String = self.substring(r:4..<6)
        
        return "\(firstPart):\(midPart):\(lastPart)"
    }
    
    
    
    //============================================================
    // 대체 문자
    //============================================================
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString)
    }

    // 모든 공백 제거
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    var removeWhitespaces: String {
        return remove(.whitespaces)
    }
    
    var removeWhitespaceAndNewLines: String {
        return remove(.whitespacesAndNewlines)
    }
    
    func remove(_ forbiddenCharacters: CharacterSet) -> String {
        return String(unicodeScalars.filter({ !forbiddenCharacters.contains($0) }))
    }
    
    //============================================================
    // 숫자로만 이루어진 문자열 인가?
    //============================================================
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["-","0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] // - for negative num.
        return Set(self).isSubset(of: nums)
    }
    
    func date(inputFormat: String, outputFormat:String) -> String? {
        if self.isEmpty { return ""}
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = inputFormat
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = outputFormat
            return dateFormatter.string(from: date)
        }
        
        return self
    }
        
    func toPrice(removeSign:Bool=false, tail:String="") -> String {
        var price = self
        if removeSign {
            price = self.replacingOccurrences(of: "-", with: "")
        }
        
        if let number = Int(price) {
            price = number.addComma()
        }

        if !tail.isEmpty && !price.isEmpty {
            price += tail
        }
        
        return price
    }
    
    // "yyyyMMdd"
    func calcAge(birthday:String) -> Int {
        var age = -1
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        if let birthdayDate = dateFormatter.date(from: birthday) {
            if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
                let now = NSDate()
                let calcAge = calendar.components(.year, from: birthdayDate, to: now as Date, options: [])
                age = calcAge.year ?? -1
                //age += 1
            }
        }
        return age
    }
    
    // "yyyyMMdd"
    var calcAge:Int {
        var age = -1
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        if let birthdayDate = dateFormatter.date(from: self) {
            if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
                let now = NSDate()
                let calcAge = calendar.components(.year, from: birthdayDate, to: now as Date, options: [])
                age = calcAge.year ?? -1
                //age += 1
            }
        }
        return age
    }

    public func date(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    public var length: Int {
        return self.count
    }
    
    func padding(char: Character, length: Int) -> String {
        var paddingString = self
        if paddingString.count == 0 || paddingString.count % length != 0 {
            for _ in 0..<(length - paddingString.count % length) {
                paddingString.append(char)
            }
        }
        
        return paddingString
    }
    
    func nilToBlank(item:String?) -> String {
        var retVal = ""
        if item == nil {
           retVal = ""
        } else {
            retVal = item!
        }
        return retVal
    }
    
    var isBackspace: Bool {
      let char = self.cString(using: String.Encoding.utf8)!
      return strcmp(char, "\\b") == -92
    }
    
    /**
     문자의 화면 기준 그려길  CGSize 정보를 받습니다.  ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.14
     - Parameters:
        - maxSize : 화면에 그릴 최대 사이즈 정보를 받습니다.
        - font : 화면에 그릴 폰트 정보를 받습니다.
     - Throws: False
     - Returns:
        화면에 그려질 사이즈 정보를 리턴 합니다. (CGSize)        
     */
    func getHeight( _ maxSize : CGSize, font : UIFont ) -> CGSize {
        let textLabel                   = UILabel()
        textLabel.text                  = self
        textLabel.font                  = font
        textLabel.textAlignment         = NSTextAlignment.left
        textLabel.numberOfLines         = 0
        return textLabel.sizeThatFits(maxSize)
        
    }
    
    func isURL() -> Bool {
        let urlString:String = self
        let url:URL = URL(string: urlString)!
        if !UIApplication.shared.canOpenURL(url) { return false }
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: self)
    }
    
    
    /**
     URL 사파리 외부 오픈 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.03.16
     - Parameters:False
     - Returns:False
     */
    func openUrl() {
        guard let url = URL(string: self) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    var insertComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal // 소수점이 있는 경우 처리
        if let _ = self.range(of: ".")
        {
            var numberArray = self.components(separatedBy: ".")
            if numberArray.count == 1
            {
                var numberString = numberArray[0]
                if numberString.isEmpty
                {
                    numberString = "0"
                }
                guard let doubleValue = Double(numberString) else { return self }
                
                return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? self
            }
            else if numberArray.count == 2
            {
                var numberString = numberArray[0]
                if numberString.isEmpty
                {
                    numberString = "0"
                }
                guard let doubleValue = Double(numberString) else { return self }
                
                guard let doubleValue2 = Double(numberArray[1]) else { return self }
                
                if doubleValue2 == 0
                {
                    return (numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberString)
                }
                else
                {
                    var dot = "."
                    if NSLocale.current.languageCode == "vi"
                    {
                        dot = ","
                    }
                    
                    return (numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberString) + "\(dot)\(numberArray[1])"
                }
            }
        }
        else
        {
            guard let doubleValue = Double(self) else { return self }
            return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? self
        }
        return self
    }
    

}

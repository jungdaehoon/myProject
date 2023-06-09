//
//  URL.swift
//  MyData
//
//  Created by UMCios on 2022/01/07.
//

import Foundation

extension URL {
    /**
     URL 파라미터를Dic 형태의 데이터 변경합니다.
     - Date: 2023.06.09
     */
    public var getQueries: [String: String] {
        var dict        : [String:String] = [:]
        var queryString : String = ""
        var queryValue  : String = ""
        let items = URLComponents(string: absoluteString)?.queryItems ?? []
        items.forEach {
            queryString = $0.name
            queryValue  = $0.value ?? ""
            dict.updateValue($0.value ?? "", forKey: $0.name)
        }
        
        /// 변경된 데이터가 1개이며 value 정보가 없다면 "queryString" 정보로 다시 파싱 합니다.
        if dict.count == 1,
           !queryValue.isValid
        {
            let param = queryString.components(separatedBy: "&").map({
                $0.components(separatedBy: "=")
            }).reduce(into: [String:String]()) { dict, pair in
                if pair.count == 2 {
                    dict.updateValue(pair[1], forKey: pair[0])
                } else if pair.count > 2 {
                    var value : String  = pair[1]
                    for _ in 0..<(pair.count - 2) {
                        value.append("=")
                    }
                    dict.updateValue(value, forKey: pair[0])
                }
            }
            return param
        }
        return dict
    }

    
    /// URL 정보를 파라미터 Dic 정보로 변경 합니다.
    public var queryParameters: [String:String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String:String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    /// URL 정보를 디코딩하여 파라미터 Dic 정보로 변경 합니다.
    public var decodedQueryParameters: [String:String]? {
        let queryItems = URLComponents(string: self.absoluteString)?.queryItems
        let queryTuples: [(String, String)] = queryItems?.compactMap{
            guard let value = $0.value?.removingPercentEncoding else { return nil }
            return ($0.name, value)
        } ?? []
        return Dictionary(uniqueKeysWithValues: queryTuples)
    }
    
}

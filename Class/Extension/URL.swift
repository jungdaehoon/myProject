//
//  URL.swift
//  MyData
//
//  Created by UMCios on 2022/01/07.
//

import Foundation

extension URL {
    
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

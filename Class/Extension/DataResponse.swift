//
//  DataResponse.swift
//  MyData
//
//  Created by UMC on 2021/12/02.
//

import Alamofire
import os

/**
 Console App Log 확인을 위해 사용 합니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2020.02.18
 */
extension OSLog
{
    private static var log_subtype = Bundle.main.bundleIdentifier
    /// Console Log 확인시 "Network" 카테고리 구분 입니다.
    static let network  = OSLog(subsystem: log_subtype!, category: "Network")
    /// Console Log 확인시 "Apns" 카테고리 구분 입니다.
    static let apns     = OSLog(subsystem: log_subtype!, category: "Push")
    /// Console Log 확인시 "Kyobo" 카테고리 구분 입니다.
    static let kyobo    = OSLog(subsystem: log_subtype!, category: "Kyobo")
    /// Console App Log 활성화 여부 입니다.
    static let OS_LOG   = true
}


extension DataResponse {
/*
    public var debugDescription: String {
        #if DEBUG
        func prettyPrintedString(_ rawData: Data) -> String {
            guard let object = try? JSONSerialization.jsonObject(with: rawData, options: []),
                let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                let prettyPrintedString = String(data: data, encoding: .utf8) else {
                    return "None"
            }
            return prettyPrintedString // Json을 보기 좋게 표시
        }
        
        let requestAPI = request.map { "\($0.httpMethod!) \($0)" } ?? "nil"
        let requestHeader = request.map { "\($0.headers.sorted())" } ?? "nil"
        let requestBody = request?.httpBody.map { prettyPrintedString($0) } ?? "None"
        let responseCode = response.map { "\($0.statusCode)" } ?? "nil"
        let responseBody = data.map { prettyPrintedString($0) } ?? "None"
        let metricsDescription = metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
        
        let log = """
        [Request API]: \(requestAPI)
        [Request Header]: \n\(requestHeader)
        [Request Body]: \n\(requestBody)
        [Response Status Code]: \(responseCode)
        [Response Body]: \n\(responseBody)
        [Network Duration]: \(metricsDescription)
        """
                
        /// Console Log 활성화 여부 입니다. ( J.D.H  VER : 1.0.0 )
        if OSLog.OS_LOG == true
        {
            os_log("%{public}@", log:  .network, type: .debug, log)
            return ""
        }
                
        
        return log
        #else
        return ""
        #endif
    }
 */
}

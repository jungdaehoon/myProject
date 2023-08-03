//
//  DataResponse.swift
//  MyData
//
//  Created by UMC on 2021/12/02.
//

import Alamofire
import os




extension DataResponse {

    public var debugDescription: String {
        /// Console Log 활성화 여부 입니다. ( J.D.H VER : 1.24.43 )
        if OSLog.OS_LOG == true
        {
            func getHttpBody( _ rawData: Data? ) -> String?
            {
                if let bodyData = rawData {
                    if let rawDataText = String(data: bodyData, encoding: .utf8) {
                        let dataTexts = rawDataText.components(separatedBy: "&")
                        var params    = ""
                        for text in dataTexts { params.append("\(text)\n") }
                        return params
                    }
                }
                return "None"
            }
            
            func prettyPrintedString(_ rawData: Data) -> String {
                guard let object = try? JSONSerialization.jsonObject(with: rawData, options: []),
                    let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                    let prettyPrintedString = String(data: data, encoding: .utf8) else {
                        return "None"
                }
                return prettyPrintedString // Json을 보기 좋게 표시
            }
            
            let requestAPI = request.map { "\($0.httpMethod!) \($0)" } ?? "nil"
            let requestHeader = request.map { "\($0.allHTTPHeaderFields!)" } ?? "nil"
            let requestBody =  getHttpBody(request!.httpBody) ?? "None"
            let responseCode = response.map { "\($0.statusCode)" } ?? "nil"
            let responseBody = data.map { prettyPrintedString($0) } ?? "None"
            let metricsDescription = metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
            
            let log = """
            _\n\n----------------------------- API Request Open -------------------------------
            [Request API]: \(requestAPI)
            [Request Header]: \n\(requestHeader)
            [Request Body]: \n\(requestBody)
            [Response Status Code]: \(responseCode)
            [Response Body]: \n\(responseBody)
            [Network Duration]: \(metricsDescription)
            ----------------------------- API Request End --------------------------------
            _\n
            """
            return log
        }
        
#if DEBUG
        func getHttpBody( _ rawData: Data? ) -> String?
        {
            if let bodyData = rawData {
                if let rawDataText = String(data: bodyData, encoding: .utf8) {
                    let dataTexts = rawDataText.components(separatedBy: "&")
                    var params    = ""
                    for text in dataTexts { params.append("\(text)\n") }
                    return params
                }
            }
            return "None"
        }
        
        func prettyPrintedString(_ rawData: Data) -> String {
            guard let object = try? JSONSerialization.jsonObject(with: rawData, options: []),
                let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                let prettyPrintedString = String(data: data, encoding: .utf8) else {
                    return "None"
            }
            return prettyPrintedString // Json을 보기 좋게 표시
        }
        
        let requestAPI = request.map { "\($0.httpMethod!) \($0)" } ?? "nil"
        let requestHeader = request.map { "\($0.allHTTPHeaderFields!)" } ?? "nil"
        let requestBody =  getHttpBody(request!.httpBody) ?? "None"
        let responseCode = response.map { "\($0.statusCode)" } ?? "nil"
        let responseBody = data.map { prettyPrintedString($0) } ?? "None"
        let metricsDescription = metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
        
        let log = """
        \n[Request API]: \(requestAPI)
        [Request Header]: \n\(requestHeader)
        [Request Body]: \n\(requestBody)
        [Response Status Code]: \(responseCode)
        [Response Body]: \n\(responseBody)
        [Network Duration]: \(metricsDescription)
        """
                
        
        return log
#else
        return ""
#endif
    }
 
}


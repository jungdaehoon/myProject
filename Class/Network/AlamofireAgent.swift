//
//  AlamofireAgent.swift
//  MyData
//
//  Created by UMC on 2021/12/01.
//

import Combine
import Alamofire
import AlamofireActivityLogger
import os


/**
 HTTP 인터페이스 연결할 기본 메서드를 지원 합니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.07
 */
enum AlamofireAgent {
    /// 최대 요청 타임 정보 입니다.
    private static let REQUEST_TIMEOUT          = TimeInterval(5.0)
    /// 최대 받는 타임 정보 입니다.
    private static let RESOURCE_TIMEOUT         = TimeInterval(5.0)
    /// 도메인 URL 정보를 가져 옵니다.
    static let baseURL                          = Bundle.main.infoDictionary?["Server"] as? String ?? ""
    /// 세션 정보를 가져 옵니다.
    static var defaultManager : SessionManager! = {
        /// 취약점 점검인 경우 입니다.
        if APP_INSPECTION
        {
            /// SSL 인증서 관련  델레게이트를 연결 합니다.
            let delegate: Alamofire.SessionDelegate = SessionDelegate()
            /// SSL 인증서 우회 진행으로 설정 합니다.
            delegate.taskDidReceiveChallengeWithCompletion = { (session, task, challenge, completionHandler) in
                /// 해당 도메인의 SSL 인증서 우회를 설정 합니다.
                if challenge.protectionSpace.host.contains(AlamofireAgent.baseURL)
                {
                    let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                    completionHandler(.useCredential, urlCredential)
                }
                else
                {
                    completionHandler(.performDefaultHandling, nil)
                }
            }
            return Alamofire.SessionManager(configuration: urlSessionConfiguration(),delegate: delegate)
        }
        else
        {
            return Alamofire.SessionManager(configuration: urlSessionConfiguration())
        }
        
    }()
    
    
    /**
    HTTP 연결할 세션 정보를 설정 합니다. ( J.D.H  VER : 1.0.0 )
    - Date: 2023.03.07
    */
    static func urlSessionConfiguration() -> URLSessionConfiguration {
        let urlSessionConfiguration                         = URLSessionConfiguration.default
        urlSessionConfiguration.requestCachePolicy          = .useProtocolCachePolicy
        urlSessionConfiguration.timeoutIntervalForResource  = REQUEST_TIMEOUT
        urlSessionConfiguration.timeoutIntervalForRequest   = RESOURCE_TIMEOUT
        return urlSessionConfiguration
    }
    
    
    /**
     상황별 인터페이스를 요청 합니다.( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.07
     - Parameters:
        - operation     : 요청할 인터페이스 타입 입니다.
        - method        : 요청 http 타입 기본 post 타입입니다.
        - parameters    : http 요청할 파라미터 정보 입니다.
        - encoding      : encoding 타입으로 기본 타입을 사용 합니다.
        - headers       : 기본 헤더 정보를 사용 합니다. "["x-requested-with": "XMLHttpRequest"]"
        - decoder       : 요청후 받은 데이터 디코딩 타입 입니다. 기본 JSONDecoder 를 사용 합니다.
     - Throws: False
     - Returns:
        요청된 T 값을 리턴 합니다. (AnyPublisher<T, ResponseError>)
     */
    static func request<T: Decodable>(
        _ url: String ,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = ["x-requested-with": "XMLHttpRequest"],
        decoder: JSONDecoder = JSONDecoder())
        -> AnyPublisher<T, ResponseError>  {
            let publisher               = PassthroughSubject<T,ResponseError>()
            let requestUrl              = URL(string: baseURL + url)!
            let request = defaultManager.request(
                requestUrl,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            
            request.validate().responseJSON { (response) in
                guard response.result.isSuccess,
                    let _ = response.result.value else {
                        Slog(response.debugDescription, category: .network, logType: .default)
                        Slog("response.result.error value error", category: .network, logType: .error)
                    publisher.send(completion: .failure( handleError(response.result.error!) ))
                        return
                }
                
                do {
                    let decoder         = JSONDecoder()
                    guard let value     = try? decoder.decode(T.self, from: response.data!) else {
                        throw ResponseError.parsing(PARSING_ERR_MSG)
                    }
                    Slog(response.debugDescription, category: .network, logType: .default)
                    publisher.send(value)
                }
                catch ( let error )
                {
                    Slog("response.result.error:::\(error)", category: .network, logType: .error)
                }
            }
            return publisher.eraseToAnyPublisher()
    }
    
    
    /**
     Error 발생시 이벤트 핸들러 입니다..( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.07
     - Parameters:
        - error     : 에러 타입을 받습니다.
     - Throws: False
     - Returns:
        타입별 정리된 에러 값을 리턴 합니다. (ResponseError)
     */
    private static func handleError(_ error: Error) -> ResponseError {
        if let apiError = error as? ResponseError {
            return apiError
        } else if let afError = error as? AFError {
            switch afError {
            case .invalidURL( _ ):
                Slog("잘못된 URL 입니다.: \(error.localizedDescription)", category: .network, logType: .error)
            case .parameterEncodingFailed( _ ):
                Slog("파라미터 인코딩 오류 입니다: \(error.localizedDescription)", category: .network, logType: .error)
            case .multipartEncodingFailed( _ ):
                Slog("파일첨부 서비스 요청 오류입니다: \(error.localizedDescription)", category: .network, logType: .error)
            case .responseValidationFailed( let reason ):
                Slog("Response validation failed: \(error.localizedDescription)", category: .network, logType: .error)
                Slog("Failure Reason: \(reason)", category: .network, logType: .error)
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    Slog("Downloaded file could not be read", category: .network, logType: .error)
                case .missingContentType(let acceptableContentTypes):
                    Slog("Content Type Missing: \(acceptableContentTypes)", category: .network, logType: .error)
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    Slog("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)", category: .network, logType: .error)
                case .unacceptableStatusCode(let code):
                    Slog("Response status code was unacceptable: \(code)", category: .network, logType: .error)
                    switch code
                    {
                    case 503 :
                        return .timeout(afError.errorDescription ?? NETWORK_ERR_MSG_DETAIL)
                    case 404 :
                        return .http(ErrorData(code: 404, message: NETWORK_ERR_404_MSG))
                    default:break
                    }
                }
            case .responseSerializationFailed( _ ):
                Slog("Response serialization failed: \(error.localizedDescription)", category: .network, logType: .error)
            }
            return .unknown(afError.errorDescription ?? NETWORK_ERR_MSG_DETAIL)
        } else {
            return .unknown(NETWORK_ERR_MSG_DETAIL)
        }
    }
    
    
    /**
     멀티파트 파일 업로드 입니다. ( J.D.H  VER : 1.0.0 )
     - Date: 2023.03.07
     - Parameters:
        - url : 업로드할 위치 정보입니다.
        - multipartFormData : 보낼 데이터 입니다.
        - encodingCompletion : 처리후 리턴 입니다.
     - Throws: False
     - Returns:False
     */
    static func upload(
        _ url: String,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?) {
        let url                 = URL(string:url)!
        var urlRequest          = URLRequest(url: url)
        urlRequest.httpMethod   = "POST"
        return defaultManager.upload(multipartFormData: multipartFormData, with: urlRequest, encodingCompletion: encodingCompletion)
    }
    
}


protocol NetworkService {
    static func getHeader() -> HTTPHeaders?
}

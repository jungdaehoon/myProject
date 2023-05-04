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

// 멀티파트로 전송할 데이터를 구성하기 위한 클래스
struct MultipartWithData {
    var data: Data
    var fileName: String?
    var mimeType: String
}

struct MultipartWithURL {
    var url: URL
    var fileName: String?
    var mimeType: String
}

enum MultipartItem {
    case data(MultipartWithData)
    case url(MultipartWithURL)
}


private let REQUEST_RETRY_COUNT = 2 // 서버 연결 타임아웃


enum AlamofireAgent {
    private static let REQUEST_TIMEOUT = TimeInterval(15) // 서버 연결 타임아웃
    /// 도메인 URL 정보를 가져 옵니다.
    static let domainUrl = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)?.value(forKey: "Server") as? String ?? ""
    
    /// 세션 세부 정보를 세팅 합니다.
    static func urlSessionConfiguration() -> URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.requestCachePolicy = .useProtocolCachePolicy // reloadIgnoringLocalCacheData
        urlSessionConfiguration.timeoutIntervalForResource = TimeInterval(5.0)
        urlSessionConfiguration.timeoutIntervalForRequest  = TimeInterval(5.0)
        
        return urlSessionConfiguration
    }
    
    /// 세션 연결 합니다.
    static var defaultManager : SessionManager! = {
        let sessionManager = Alamofire.SessionManager(configuration: urlSessionConfiguration())
        return sessionManager;
    }()
    
    
    
    /**
     상황별 인터페이스를 요청 합니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.07
     - Parameters:
        - operation     : 요청할 인터페이스 타입 입니다.
        - method        : 요청 http 타입 기본 post 타입입니다.
        - parameters    : http 요청할 파라미터 정보 입니다.
        - encoding      : encoding 타입으로 기본 타입을 사용 합니다.
        - headers       : 기본 헤더 정보를 사용 합니다. "["x-requested-with": "XMLHttpRequest"]"
        - decoder       : 요청후 받은 데이터 디코딩 타입 입니다. 기본 JSONDecoder 를 사용 합니다.
     - Throws : False
     - returns :
        + AnyPublisher<T, ResponseError>
            : 요청된 T 값을 리턴 합니다.
     */
    static  func request<T: Decodable>(
        _ url: String ,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = ["x-requested-with": "XMLHttpRequest"],
        decoder: JSONDecoder = JSONDecoder())
        -> AnyPublisher<T, ResponseError>  {
            
            let publisher               = PassthroughSubject<T,ResponseError>()
            let requestUrl              = URL(string: domainUrl + url)!
            
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
                        return .timeout(afError.errorDescription ?? NETWORK_ERR_MSG)
                    default:break
                    }
                    
                }
            case .responseSerializationFailed( _ ):
                Slog("Response serialization failed: \(error.localizedDescription)", category: .network, logType: .error)
            }
            /*
            switch afError {
            case .sessionTaskFailed(let sessionError):
                if let urlError = sessionError as? URLError {
                    if urlError.errorCode == NSURLErrorTimedOut {
                        Slog("time out : #7 : \(afError)" )
                        return .timeout(afError.errorDescription ?? NETWORK_ERR_MSG)
                    }
                }
                
            default: break
            }
             */
            return .unknown(afError.errorDescription ?? NETWORK_ERR_MSG)
        } else {
            return .unknown(NETWORK_ERR_MSG)
        }
    }
    
    
    
    static func upload(
        _ url: String,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?) {
        let url                     = URL(string: domainUrl + url)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"        
        return defaultManager.upload(multipartFormData: multipartFormData, with: urlRequest, encodingCompletion: encodingCompletion)
    }
    
}


protocol NetworkService {
    static func getHeader() -> HTTPHeaders?
}

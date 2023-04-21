//
//  IntroModel.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/20.
//

import Foundation
import Combine
import ContactsUI
import UserNotifications
import SystemConfiguration
import Photos


/**
 연결 체크 타입 입니다..  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
 
        + checking   : 체킹을 시작 합니다.
        + connecting : 네트워크 연결로 사용 가능 입니다.
        + fail       : 사용 불가능 입니다.
 */
enum IS_CHECKING {
    /// 체킹을 시작 합니다.
    case checking
    /// 네트워크 연결로 사용 가능 입니다.
    case connecting
    /// 네트워크 사용 불가능 입니다.
    case fail
}


/**
 인트로 뷰어 지원 모델 입니다.    ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.05
 */
class IntroModel : BaseViewModel{
    /// 네트워크 채킹 이벤트 입니다.
    var isNetworkChecking   = PassthroughSubject<Bool,Error>()
    
    
    /**
     네크워크  연결 상태를 체크 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - returns :
            - CurrentValueSubject<IS_CHECKING, Never>
                >  네트워크 연결 가능 여부를 리턴 합니다. ( true / false )
     */
    func isConnectedToNetwork() -> CurrentValueSubject<IS_CHECKING,Never> {
        /// 네트워크 체킹 여부 값을 리턴 합니다.
        let isConnected = CurrentValueSubject<IS_CHECKING,Never>(.checking)
        /// 네트워크 채킹을 요청 합니다.
        self.isNetworkChecking.send(true)
        /// 네트워크 채킹을 시작 합니다.
        self.isNetworkChecking.delay(for: 1.0, scheduler: RunLoop.main ).sink { result in
            
        } receiveValue: { checking in
            DispatchQueue.main.async {
                /// 네트워크 채킹 여부 값이 true 일경우 네트워크 채킹일 시작 합니다.
                if checking == true
                {
                    /// 네크워크 정보 구조체를 가져 옵니다.
                    var zeroAddress         = sockaddr_in()
                    zeroAddress.sin_len     = UInt8(MemoryLayout<sockaddr_in>.size)
                    zeroAddress.sin_family  = sa_family_t(AF_INET)
                    
                    /// 연결 가능한 호스트 정보를 가져 옵니다.
                    guard let reachability  = withUnsafePointer(to: &zeroAddress, {
                        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                            SCNetworkReachabilityCreateWithAddress(nil, $0)
                        }
                    }) else { isConnected.send(.fail); return }
                    
                    /// 현재 네트워크 구성을 사용하여 지정된 네트워크 대상에 연결할 수 있는지 확인합니다.
                    var flags: SCNetworkReachabilityFlags? = SCNetworkReachabilityFlags()
                    if SCNetworkReachabilityGetFlags(reachability, &flags!) == false
                    {
                        isConnected.send(.fail)
                    }
                    
                    /// 해당 플레그가 네트워크 연결을 사용 할수 있는지 여부를 체크 합니다.
                    let isReachable         = (flags!.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
                    let needsConnection     = (flags!.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
                    isConnected.send((isReachable && !needsConnection) ? .connecting : .fail)
                }
                else
                {
                    isConnected.send(.connecting)
                }
            }
        }.store(in: &cancellableSet)
        return isConnected
    }
    
    
    /**
     자동로그인 처리 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.20
     - Parameters:False
     - Throws : False
     - returns :
        - AnyPublisher<LogOutResponse?, ResponseError>
            >  LogOutResponse : 로그아웃 처리 결과를 받습니다.
     */
    func setAutoLogin() ->  AnyPublisher<LoginResponse?, ResponseError> {
        var parameters : [String:Any]       = [:]
        let custItem                        = SharedDefaults.getKeyChainCustItem()!
        parameters["login_type"]            = "A"
        parameters["user_hp"]               = NC.S(custItem.user_hp)
        parameters["token"]                 = NC.S(custItem.token)
        parameters["user_no"]               = NC.S(custItem.user_no)
        parameters["auto_login"]            = "Y"
        parameters["appshield_session_id"]  = ""
        parameters["appshield_token"]       = ""
        
        let subject             = PassthroughSubject<LoginResponse?,ResponseError>()
        requst( showLoading: true ) { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 로그인 요청 합니다.
            return NetworkManager.requestLogin(params: parameters)
        } completion: { model in
            BaseViewModel.loginResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
}

//
//  PedometerModel.swift
//  OKPay
//
//  Created by DaeHoon Chung on 2023/03/23.
//

import Foundation
import Combine


/**
 만보고 모델 정보 입니다.
 - Date : 2023.03.23
 */
class PedometerModel : BaseViewModel
{
    /// 만보기 데이터 입니다.
    var pedometerResponse       : PedometerResponse?
    /// 만보기 리워드 데이터 입니다.
    var pedometerRewardResponse : PedometerRewardResponse?
    /// 만보기 데이터 업데이트 입니다.
    var pedometerUpdateResponse : PedometerUpdateResponse?
    
    
    
    /**
     만보기 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.23
     - Parameters:False
     - Throws : False
     - returns :
        - AnyPublisher<PedometerResponse?, ResponseError>
            >  PedometerResponse : 만보기 정보를 받습니다.
     */
    func getPedometer( _ params : [String : Any] = [:]  ) -> AnyPublisher<PedometerResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<PedometerResponse?,ResponseError>()
        requst( showLoading: true ) { error in
            self.pedometerResponse = nil
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 만보기 요청 합니다.
            return NetworkManager.requestPedometer()
        } completion: { model in
            self.pedometerResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    
    /**
     만보기 리워드 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.23
     - Parameters:False
     - Throws : False
     - returns :
        - AnyPublisher<PedometerRewardResponse?, ResponseError>
            >  PedometerRewardResponse : 만보기 리워드 정보 입니다.
     */
    func getPedometerReward( _ params : [String : Any] = [:]  ) -> AnyPublisher<PedometerRewardResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<PedometerRewardResponse?,ResponseError>()
        requst( showLoading: true ) { error in
            self.pedometerRewardResponse = nil
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 만보기 리워드 요청 합니다.
            return NetworkManager.requestPedometerReward( params: params )
        } completion: { model in
            self.pedometerRewardResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    
    /**
     만보기 데이터 업데이트 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.23
     - Parameters:
        - params : 업데이트할 만보기 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<PedometerUpdateResponse?, ResponseError>
            >  PedometerUpdateResponse : 업데이트 여부 입니다.
     */
    func setPedometerUpdate( _ params : [String : Any] = [:]  ) -> AnyPublisher<PedometerUpdateResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<PedometerUpdateResponse?,ResponseError>()
        requst( showLoading: true ) { error in
            self.pedometerRewardResponse = nil
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 만보기 데이터를 업데이트 합니다.
            return NetworkManager.requestPedometerUpdate( params: params)
        } completion: { model in
            self.pedometerUpdateResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
}

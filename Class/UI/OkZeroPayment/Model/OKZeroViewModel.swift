//
//  AllMoreViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//

import AVFoundation
import Foundation
import Combine


/**
 결제 코드 활성화 타임별 타입 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.26
*/
enum CODE_ENABLED_TIME : Equatable {
    case start_time
    /// 진행 중인 타임 정보를 넘깁니다.
    case ing_time( timer : String? )
    /// 타임 종료 여부를 넘깁니다.
    case end_time
    /// 타임 강제 종료 입니다.
    case exit_time
}


/**
 코드 타입 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.03.13
*/
enum ZEROPAY_CODE_TYPE
{
    /// 바코드 타입 입니다.
    case barcode
    /// QRCode 타입 입니다.
    case qrcode
}


/**
 전체 웹 종료 콜백 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.19
*/
enum QRCODE_CB : Equatable {
    /// QRCode 페이지 시작 입니다.
    case start
    /// QRCode 페이지 종료 입니다.
    case close
    /// QRCdoe 읽기 실패 입니다.
    case qr_fail
    /// 서버 스크립트 요청 실패 입니다.
    case cb_fail
    /// QRCode 정보를 넘깁니다
    case qr_success ( qrcode : String? )
    /// QRCode 인증 정상처리 후 받은 스크립트를 넘깁니다.
    case cb_success ( scricpt : String? )
}


/**
 카드 디스플레이 타입  입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.06.27
*/
enum CARD_DISPLAY  : Equatable {
    /// 시작 타입 입니다.
    case start
    /// 하단 디스플레이 타입 입니다.
    case bottom
    /// 전체 화면 입니다.
    case full
}


/**
 제로페이 뷰어 관련 모델 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.06.16
*/
class OKZeroViewModel : BaseViewModel
{
    static var zeroPayShared    : OKZeroViewModel?
    /// 바코드 인식 세션 입니다.
    var captureSession          : AVCaptureSession?
    /// 제로페이 QRCode 인증 정보를 받습니다.
    var zeroPayQrCodeResponse   : ZeroPayQRCodeResponse?
    /// 스캔한 바코드 정보를 가져 옵니다.
    @Published var qrCodeValue  : QRCODE_CB = .start
    /// 코드 타임진행 상태를 가집니다.
    @Published var codeTimer    : CODE_ENABLED_TIME  = .start_time
    /// 카드 디스플레이 타입을 가집니다.
    @Published var cardDisplay  : CARD_DISPLAY = .bottom
    /// 제로페이를 새로고침 합니다. ( OkPaymentViewController / viewDidAppear)
    @Published var okZeroPayReload  : Bool = false
    


    /**
     QRCode 인증 할 제로페이 스크립트를 요청 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.19
     - Parameters:
        - params : 제로페이에서 받은 파라미터 정보 입니다.
     - Throws: False
     - Returns:
        QRCode 인증 할 제로페이 스크립트를 받습니다. (AnyPublisher<ZeroPayQRCodeResponse?, ResponseError>)
     */
    func getQRCodeZeroPay( params : [String : Any] = [:]) -> AnyPublisher<ZeroPayQRCodeResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<ZeroPayQRCodeResponse?,ResponseError>()
        requst() { error in
            self.zeroPayQrCodeResponse = nil
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 제로페이 리턴할 QrCode 인증 스크립트를 요청 합니다.
            return NetworkManager.requestZeroPayQRcode( params: params )
        } completion: { model in
            self.zeroPayQrCodeResponse = model
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
    
    
    
    /**
     제로페이 간편결제 스캔된 QRCode 정보를 정상여부 체크 합니다. ( J.D.H VER : 2.0.0 )
     - Date: 2023.07.05
     - Parameters:
        - qrcode : 스캔한 qrcode 정보 입니다.
     - Throws: False
     - Returns:
        ( S : 정지, A : 사용가능 ) 정상 여부를 받습니다. (AnyPublisher<ZeroPayQRCodeStatusResponse?, ResponseError>)
     */
    func getQRCodeZeroPayStatus( qrcode : String ) -> AnyPublisher<ZeroPayQRCodeStatusResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<ZeroPayQRCodeStatusResponse?,ResponseError>()
        requst() { error in
            subject.send(completion: .failure(error))
            return false
        } publisher: {
            /// 스캔한 QRCode  정상여부를 체크  요청 합니다.
            return NetworkManager.requestZeroPayQRCodeCheck(qrcode: qrcode)
        } completion: { model in
            // 앱 인터페이스 정상처리 여부를 넘깁니다.
            subject.send(model)
        }
        return subject.eraseToAnyPublisher()
    }
}


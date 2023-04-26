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
 결제 코드 활성화 타임별 타입 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.26
*/
enum CODE_ENABLED_TIME {
    case start_time
    /// 진행 중인 타임 정보를 넘깁니다.
    case ing_time( timer : String? )
    /// 타임 종료 여부를 넘깁니다.
    case end_time
}


/**
 코드 타입 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.13
*/
enum ZEROPAY_CODE_TYPE
{
    /// 바코드 타입 입니다.
    case barcode
    /// QRCode 타입 입니다.
    case qrcode
}


/**
 전체 웹 종료 콜백 입니다.  ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.19
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
 제로페이 뷰어 관련 모델 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.13
*/
class OKZeroViewModel : BaseViewModel
{
    /// 바코드 인식 세션 입니다.
    var captureSession          : AVCaptureSession?
    /// 제로페이 QRCode 인증 정보를 받습니다.
    var zeroPayQrCodeResponse   : ZeroPayQRCodeResponse?
    /// 바코드 인식왼 정보를 가져 옵니다.
    @Published var qrCodeValue  : QRCODE_CB = .start
    
    

    func isTimeCodeEnabeld() -> CurrentValueSubject<CODE_ENABLED_TIME,Never>
    {
        /// 네트워크 체킹 여부 값을 리턴 합니다.
        let checkTimer = CurrentValueSubject<CODE_ENABLED_TIME,Never>(.start_time)
        /// 최대 타임 입니다.
        let maxtime     = 180
        /// 오버 되는 타임 정보 입니다.
        var overtime    = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            overtime += 1
            DispatchQueue.main.async {
                /// 인식가능한 "분" 정보를 설정 합니다.
                let hour        = (maxtime - overtime)/60
                /// 인식 가능한 "초" 정보를 설정 합니다.
                let min         = (maxtime - overtime)%60
                /// 디스플레이할 "초" 정보를 2자리수로 설정 합니다.
                let minute      = min < 10 ? "0\(min)" : "\(min)"
                /// 최종 디스플레이할 타임 정보를 설정 합니다.
                let displayTime = "0\(hour):\(minute)"
                print(displayTime)
                
                /// 인식 가능 타임을 종료 합니다.
                if maxtime == overtime
                {
                    checkTimer.send(.end_time)
                    checkTimer.send(completion: .finished)
                    timer.invalidate()
                    return
                }
                /// 진행중인 타임 정보를 리턴 합니다.
                checkTimer.send(.ing_time(timer: displayTime))                
            }
        })
        return checkTimer
    }
    
    /**
     코드 인식 가능한 타임 여부를 체크 합니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.26
     - Parameters:False
     - Throws : False
     - returns :
        - Future<CODE_ENABLED_TIME, Never>
            >  CODE_ENABLED_TIME : 현 인식 가능 타임 정보를 리턴 합니다.
     */
    func isCodeEnabled() -> Future<CODE_ENABLED_TIME?, Never>
    {
        return Future<CODE_ENABLED_TIME?, Never> { promise in
            /// 최대 타임 입니다.
            let maxtime     = 180
            /// 오버 되는 타임 정보 입니다.
            var overtime    = 0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                overtime += 1
                DispatchQueue.main.async {
                    /// 인식가능한 "분" 정보를 설정 합니다.
                    let hour        = (maxtime - overtime)/60
                    /// 인식 가능한 "초" 정보를 설정 합니다.
                    let min         = (maxtime - overtime)%60
                    /// 디스플레이할 "초" 정보를 2자리수로 설정 합니다.
                    let minute      = min < 10 ? "0\(min)" : "\(min)"
                    /// 최종 디스플레이할 타임 정보를 설정 합니다.
                    let displayTime = "0\(hour):\(minute)"
                    print(displayTime)
                    /// 인식 가능 타임을 종료 합니다.
                    if maxtime == overtime { promise(.success(.end_time)) }
                    /// 진행중인 타임 정보를 리턴 합니다.
                    promise(.success(.ing_time(timer: displayTime)))
                }
            })
        }
    }
    
    /**
     바코드 인식할 세션 연결 입니다.( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.13
     - Throws : False
     - returns :
        - Future<Bool, Never>
            >  Bool : 세션 연결 여부를 받아 리턴 합니다.
     */
    func isAVCaptureSession() -> Future<AVCaptureMetadataOutput?, Never>
    {
        return Future<AVCaptureMetadataOutput?, Never> { promise in
            self.captureSession             = AVCaptureSession()
            guard let videoCaptureDevice    = AVCaptureDevice.default(for: .video) else {return}
            let videoInput: AVCaptureInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch let error {
                promise(.success(nil))
                print(error.localizedDescription)
                return
            }
            
            guard let captureSession = self.captureSession else {
                promise(.success(nil))
                return
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            else
            {
                promise(.success(nil))
                return
            }
                    
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput)
            {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes      = [.qr]
                promise(.success(metadataOutput))
            }
            else
            {
                promise(.success(nil))
                return
            }
        }
    }
    
    
    /**
     QRCode 인증 할 제로페이 스크립트를 요청 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.04.19
     - Parameters:
        - params : 제로페이에서 받은 파라미터 정보 입니다.
     - Throws : False
     - returns :
        - AnyPublisher<ZeroPayQRCodeResponse?, ResponseError>
            >  ZeroPayQRCodeResponse : QRCode 인증 할 제로페이 스크립트를 받습니다.
     */
    func getQRCodeZeroPay( params : [String : Any] = [:]) -> AnyPublisher<ZeroPayQRCodeResponse?, ResponseError>
    {
        let subject             = PassthroughSubject<ZeroPayQRCodeResponse?,ResponseError>()
        requst( showLoading : true ) { error in
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

    
    
    
    
}



// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension OKZeroViewModel: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                /// QR코드 정보 인식에 실패하여 "" 값으로 설정 합니다.
                self.qrCodeValue = .qr_fail
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            /// QRCode 값을 체크를 중단 합니다.
            self.captureSession!.stopRunning()
            /// QRCode 정보를 넘깁니다.
            self.qrCodeValue = .qr_success(qrcode: stringValue)
            print("OKZeroViewModel Value\n + \(self.qrCodeValue)\n")
        }
    }
}


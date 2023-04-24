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


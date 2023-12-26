//
//  QRCodeScannerViewModel.swift
//  cereal
//
//  Created by OKPay on 2023/10/18.
//

import AVFoundation
import Foundation
import Combine


/**
 QRCode 스켄  콜백 입니다.  ( J.D.H VER : 2.0.0 )
 - Date: 2023.10.18
*/
enum QRCODE_SCANNER_CB : Equatable {
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
 QRCode 스캔 관련 모델 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.10.18
 - Description : QRCode 스캔에 필요한 데이터를 처리 및 초기화 하며, 스켄시 정보를 처리 하여 뷰어로 리턴 합니다.
*/
class QRCodeScannerViewModel : BaseViewModel
{
    /// 바코드 인식 세션 입니다.
    var captureSession  : AVCaptureSession?
    /// 스캔 타입 리턴 입니다.
    var completion      : (( _ value : QRCODE_SCANNER_CB ) -> Void)? = nil
    
    
    /**
     바코드 인식할 캡쳐 세션 연결 입니다.( J.D.H VER : 2.0.5 )
     - Date: 2023.10.18
     - Throws: False
     - Returns:
        캡쳐 세션 연결 여부를 받아 리턴 합니다. (Future<AVCaptureMetadataOutput?, Never>)
     */
    func isAVCaptureSession( completion : (( _ value : QRCODE_SCANNER_CB ) -> Void)? = nil ) -> Future<AVCaptureMetadataOutput?, Never>
    {
        self.completion = completion
        return Future<AVCaptureMetadataOutput?, Never> { promise in
            self.captureSession             = AVCaptureSession()
            guard let videoCaptureDevice    = AVCaptureDevice.default(for: .video) else {return}
            let videoInput: AVCaptureInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch let error {
                promise(.success(nil))
                Slog(error.localizedDescription)
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
}




// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                /// QR코드 정보 인식에 실패하여 정보를 리턴 합니다.
                if let completion = completion {
                    completion(.qr_fail)
                }
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            /// QRCode 값을 체크를 중단 합니다.
            self.captureSession!.stopRunning()
            /// QR코드 정보 인식에 성공하여 정보를 리턴 합니다.
            if let completion = completion {
                Slog("qrcode stringValue : \(stringValue)")
                completion(.qr_success(qrcode: stringValue))
            }
        }
    }
}



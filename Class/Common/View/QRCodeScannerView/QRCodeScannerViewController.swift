//
//  QRCodeScannerViewController.swift
//  cereal
//
//  Created by OKPay on 2023/10/18.
//

import UIKit
import AVFoundation
import Combine



/**
 QRCode 스캔 뷰어 입니다  ( J.D.H VER : 2.0.4 )
 - Date: 2023.10.18
 */
class QRCodeScannerViewController: UIViewController {

    var viewModel : QRCodeScannerViewModel = QRCodeScannerViewModel()
    var completion : (( _ value : QRCODE_SCANNER_CB? ) -> Void )? = nil
    @IBOutlet weak var titleView: UIView!
    /// 전체 프리뷰 뷰 영역 입니다.
    @IBOutlet weak var previewView      : UIView!
    /// QRCode 스캔 영역 입니다.
    @IBOutlet weak var QRintersetView   : UIView!
    /// 바코드를 인식할 프리브 영역 입니다.
    var previewLayer                    : AVCaptureVideoPreviewLayer?
    /// 바코드 인식 할 영역 입니다.
    var rectOfInterest                  : CGRect?
    
    
    // MARK: - 데이터 초기화 입니다.
    init( completion : (( _ value : QRCODE_SCANNER_CB? ) -> Void )? = nil ) {
        super.init(nibName: nil, bundle: nil)
        self.completion = completion
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 캡쳐 세션 사용 여부를 체크 합니다.
        self.viewModel.isAVCaptureSession( completion: { value in
            if let completion = self.completion {
                completion(value)
            }
        }).sink { result in
            
        } receiveValue: { metadataOutput in
            /// 캡쳐 세션 사용가능 합니다.
            if metadataOutput != nil
            {
                DispatchQueue.main.async {
                    /// QRCode 를 인식할 카메라 프리뷰 화면을 설정 합니다.
                    self.setPreviewLayer(metadataOutput)
                }
            }
        }.store(in: &self.viewModel.cancellableSet)
        
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     프리뷰 화면과 캡쳐할 영역 설정 합니다. ( J.D.H VER : 2.0.3 )
     - Date: 2023.03.13
     - Parameters:
        - captureMetadataOutPut : 캡쳐할 메타데이터 output 정보 입니다.
     - Throws: False
     - Returns:False
     */
    private func setPreviewLayer( _ captureMetadataOutPut : AVCaptureMetadataOutput? ) {
        /// 캡쳐 세션이 사용 가능한지를 체크 합니다.
        guard let captureSession    = self.viewModel.captureSession else {
            return
        }
                
        let previewSize             = CGSize(width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height)
        /// 프리뷰 총 영역을 설정 합니다.
        let previewLayer            = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity   = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame          = CGRect(origin: .zero, size: CGSize(width: previewSize.width, height:  previewSize.height))
        
        Slog("titleView y : \(titleView.frame.origin.y)")
        Slog("titleView height : \(titleView.frame.size.height)")
        let plusY = titleView.frame.origin.y + titleView.frame.size.height
        /// QR 코드를 인식할 박스 영역을 설정 합니다.
        let rect                    = CGRect(x: previewSize.width/2 - self.QRintersetView.frame.size.width/2, y: self.QRintersetView.frame.origin.y + plusY,
                                             width: self.QRintersetView.frame.size.width , height: self.QRintersetView.frame.size.height)
        /// 총 전체 화면에 검은 쉐도우를 추가하는 범위 입니다.
        let path                    = UIBezierPath(rect: previewLayer.frame)
        /// 총 쉐도우에 QR코드만 인식할 박스 영역을 설정 합니다.
        let cp                      = UIBezierPath(roundedRect: rect, cornerRadius: 16)
        path.append(cp)
        path.usesEvenOddFillRule    = true
        
        
        /// 설정 된 영역을 설정 합니다.
        let maskLayer               = CAShapeLayer()
        maskLayer.path              = path.cgPath
        maskLayer.fillColor         = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        maskLayer.fillRule          = .evenOdd
        previewLayer.addSublayer(maskLayer)
        self.previewView.layer.addSublayer(previewLayer)
        self.previewLayer           = previewLayer
        
        DispatchQueue.main.async {
            /// QRCode 스켄을 진행 합니다.
            captureSession.startRunning()
            /// QRCode 캡쳐 할 데이터 영역을 설정 합니다.
            captureMetadataOutPut!.rectOfInterest = self.previewLayer!.metadataOutputRectConverted(fromLayerRect: self.QRintersetView.frame)
        }
    }
    
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        self.popController(animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

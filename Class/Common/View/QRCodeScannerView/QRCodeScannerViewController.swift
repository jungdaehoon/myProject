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
 - Description : OKPay 에서 공통으로 QRCode 스캔을 지원하는 페이지 입니다. ( 지갑,제로페이상품권,제로페이 간편결제 )
 */
class QRCodeScannerViewController: UIViewController {

    /// 스캔 모델 입니다.
    var viewModel  : QRCodeScannerViewModel = QRCodeScannerViewModel()
    /// 스켄 이벤트 정보를 리턴 합니다.
    var completion : (( _ value : QRCODE_SCANNER_CB? ) -> Void )? = nil
    @IBOutlet weak var titleView        : UIView!
    /// 전체 프리뷰 뷰 영역 입니다.
    @IBOutlet weak var previewView      : UIView!
    /// QRCode 스캔 영역 입니다.
    @IBOutlet weak var QRintersetView   : UIView!
    /// 페이지 타입별 상단 타이틀 명 입니다.
    @IBOutlet weak var titleName        : UILabel!
    /// 페이지 타입별 뒤로가기 버튼 입니다.
    @IBOutlet weak var backBtn          : UIButton!
    /// 페이지 타입별 종료 버튼 입니다.
    @IBOutlet weak var closeBtn         : UIButton!
    /// QRCode 스캔 부분 상세 설명 입니다.
    @IBOutlet weak var subInfoText      : UILabel!
    /// 스켄 영역 뷰어 입니다.
    @IBOutlet weak var scannerView      : UIView!
    /// 바코드를 인식할 프리브 영역 입니다.
    var previewLayer                    : AVCaptureVideoPreviewLayer?
    /// 바코드 인식 할 영역 입니다.
    var rectOfInterest                  : CGRect?
    /// 타이틀 정보 입니다.
    var titleStr                        : String    = ""
    /// 중앙 안내 정보 입니다.
    var subInfoStr                      : String    = ""
    /// 상단바 버튼 뒤로가기 여부 입니다.
    var isTitleBackBtn                  : Bool      = true
    
    
    
    // MARK: - 데이터 초기화 입니다.
    init( titleStr          : String = "QR결제",
          subInfoStr        : String = "QR코드를 찍어 간편결제하세요",
          isTitleBackBtn    : Bool = true,
          completion        : (( _ value : QRCODE_SCANNER_CB? ) -> Void )? = nil ) {
        super.init(nibName: nil, bundle: nil)
        self.titleStr       = titleStr
        self.subInfoStr     = subInfoStr
        self.isTitleBackBtn = isTitleBackBtn
        self.completion     = completion
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 캡쳐 세션 사용 여부를 체크 합니다.
        self.viewModel.isAVCaptureSession { value in
            if let completion = self.completion {
                completion(value)
            }
            self.popController(animated: true)
        }.sink { output in
            /// 캡쳐 세션 사용가능 합니다.
            if output != nil
            {
                DispatchQueue.main.async {
                    /// QRCode 를 인식할 카메라 프리뷰 화면을 설정 합니다.
                    self.setPreviewLayer(output)
                }
            }
        }.store(in: &self.viewModel.cancellableSet)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        /// 타이틀 명을 설정 합니다.
        self.titleName.text     = self.titleStr
        /// 중앙 상세 안내 문구 입니다.
        self.subInfoText.text   = self.subInfoStr
        /// 뒤로가기 버튼 활성화 여부 입니다.
        if self.isTitleBackBtn
        {
            self.backBtn.isHidden  = false
            self.closeBtn.isHidden = true
        }
        else
        {
            self.backBtn.isHidden  = true
            self.closeBtn.isHidden = false
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Slog("setView.fra : \(self.QRintersetView.frame)")
        Slog("setView.fra : \(self.QRintersetView.frame)")
    }
    
    
    
    // MARK: - 지원 메서드 입니다.
    /**
     프리뷰 화면과 캡쳐할 영역 설정 합니다. ( J.D.H VER : 2.0.3 )
     - Date: 2023.10.13
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
         
        var topPosition             = self.scannerView.frame.origin.y
        topPosition                 += self.scannerView.frame.height/2
        topPosition                 -= self.QRintersetView.frame.height/2
        
        let previewSize             = CGSize(width: UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height)
        /// 프리뷰 총 영역을 설정 합니다.
        let previewLayer            = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity   = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame          = CGRect(origin: .zero, size: CGSize(width: previewSize.width, height:  previewSize.height))
        
        Slog("titleView y : \(titleView.frame.origin.y)")
        Slog("titleView height : \(titleView.frame.size.height)")
        /// QR 코드를 인식할 박스 영역을 설정 합니다.
        let outputRect               = CGRect(x: previewSize.width/2 - self.QRintersetView.frame.size.width/2,
                                             y: topPosition,
                                             width: self.QRintersetView.frame.size.width,
                                             height: self.QRintersetView.frame.size.height)
        /// 총 전체 화면에 검은 쉐도우를 추가하는 범위 입니다.
        let path                    = UIBezierPath(rect: previewLayer.frame)
        /// 총 쉐도우에 QR코드만 인식할 박스 영역을 설정 합니다.
        let cp                      = UIBezierPath(roundedRect: outputRect, cornerRadius: 16)
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
        Slog("previewLayer.frame : \(previewLayer.frame)")
        Slog("previewSize : \(previewSize)")
        Slog("self.cgPath.boundingBox : \(path.cgPath.boundingBox)")
        Slog("self.QRintersetView.frame : \(self.QRintersetView.frame)")
        DispatchQueue.global(qos: .background).async {
            /// QRCode 스켄을 진행 합니다.
            captureSession.startRunning()
            DispatchQueue.main.async {
                /// QRCode 캡쳐 할 데이터 영역을 설정 합니다.
                captureMetadataOutPut!.rectOfInterest = self.previewLayer!.metadataOutputRectConverted(fromLayerRect: outputRect)
            }
        }
    }
    
    
    
    // MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let completion = self.completion {
            completion(.close)
        }
        self.popController(animated: true)
    }
}

//
//  OKZeroPayQRCaptureView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/11.
//  Copyright © 2023 srkang. All rights reserved.
//

import UIKit
import AVFoundation


/**
 제로페이 QRCode 체크 전체 화면 뷰어 입니다. ( J.D.H VER : 2.0.0 )
 - Date: 2023.04.11
*/
class OKZeroPayQRCaptureView: UIView {

    var viewModel                       : OKZeroViewModel = OKZeroViewModel()
    /// 프리브 뷰어 입니다.
    @IBOutlet weak var previewView      : UIView!
    /// 바코드를 인식할 프리브 영역 입니다.
    var previewLayer                    : AVCaptureVideoPreviewLayer?
    /// 이벤트를 넘깁니다.
    var completion                      : (( _ qrcodeCB : QRCODE_CB ) -> Void )? = nil
    /// 제로페이에서 받은 파라미터 정보를 저장 합니다.
    var params                          : [String:Any] = [:]
    
    
    //MARK: - Init
    init( params: [String:Any] = [:], completion : (( _ qrcodeCB : QRCODE_CB ) -> Void)? = nil){
        super.init(frame: UIScreen.main.bounds)
        self.initZeroPayView()
        /// 리턴 이벤트를 연결 합니다.
        self.completion = completion
        /// 제로페이에서 받은 파라미터 정보를 저장 합니다.
        self.params     = params
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    //MARK: - 지원 메서드 입니다.
    func initZeroPayView(){
        commonInit()
        /// 캡쳐 세션 사용 여부를 체크 합니다.
        self.viewModel.isAVCaptureSession().sink { metadataOutput in
            /// 캡쳐 세션 사용가능 합니다.
            if metadataOutput != nil
            {
                DispatchQueue.main.async {
                    /// QRCode 를 인식할 카메라 프리뷰 화면을 설정 합니다.
                    self.setPreviewLayer(metadataOutput)
                }
            }
        }.store(in: &self.viewModel.cancellableSet)
        
        /// QR 코드 정보를 받습니다.
        self.viewModel.$qrCodeValue.sink { value in
            if value == .start { return }
            self.completion!(value)
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    /**
     프리뷰 화면 설정 메서드 입니다. ( J.D.H VER : 2.0.0 )
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
        
        /// QR 코드를 인식할 박스 영역을 설정 합니다.
        let rect                    = CGRect(x: previewSize.width/2 - self.previewView.frame.size.width/2, y: self.previewView.frame.origin.y,
                                             width: self.previewView.frame.size.width , height: self.previewView.frame.size.height)
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
        
        /// 총 프리뷰 영역을 화면에 그립니다.
        //self.layer.addSublayer(previewLayer)
        self.previewView.layer.addSublayer(previewLayer)
        self.previewLayer           = previewLayer
        
        DispatchQueue.main.async {
            /// QRCode 스켄을 진행 합니다.
            captureSession.startRunning()
            /// QRCode 캡쳐 할 데이터 영역을 설정 합니다.
            captureMetadataOutPut!.rectOfInterest = self.previewLayer!.metadataOutputRectConverted(fromLayerRect: self.previewView.frame)
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에 디스플레이 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func show(_ base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })) {
        if let base = base {
            DispatchQueue.main.async {
                self.tag = 567891
                base.addSubview(self)
            }
        }
    }
    
    
    /**
     안내 팝업을 윈도우 최상단 뷰어에서 삭제 합니다.   ( J.D.H VER : 2.0.0 )
     - Date: 2023.04.05
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func hide() {
        let base: UIView? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        DispatchQueue.main.async {
            _ = base!.subviews.map({
                if $0.tag == 567891
                {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        self.completion!(.close)
    }
    
}

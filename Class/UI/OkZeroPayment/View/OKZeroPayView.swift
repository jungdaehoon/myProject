//
//  AllMoreViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//


import UIKit
import AVFoundation
import Combine


/**
 제로페이 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
*/
class OKZeroPayView: UIView {

    var cancellableSet                  = Set<AnyCancellable>()
    var viewModel                       : OKZeroViewModel = OKZeroViewModel()
    /// 바코드를 인식할 프리브 영역 입니다.
    var previewLayer                    : AVCaptureVideoPreviewLayer?
    /// 바코드 인식 할 영역 입니다.
    var rectOfInterest                  : CGRect?
    /// 전체 프리뷰 화면 입니다.
    @IBOutlet weak var previewView      : UIView!
    /// QR 인식 영역 뷰어 입니다. ( 영역만 가지고 있습니다. )
    @IBOutlet weak var QRintersetView   : UIView!
    /// QRCode 및 바코드를 디스플레이 하는 뷰어 입니다.
    @IBOutlet weak var displayQRView    : UIView!
    /// QRCode 를 디스플레이 합니다.
    @IBOutlet weak var qrCodeGenerator  : QRorBarCodeGeneratorView!
    /// 바코드를 디스플레이 합니다.
    @IBOutlet weak var barCodeGenerator : QRorBarCodeGeneratorView!
    /// 바코드 넘버를 디스플레이 합니다.
    @IBOutlet weak var barCodeNumber    : UILabel!
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initZeroPayView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initZeroPayView()
    }
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     제로페이 QRCode 뷰어 입니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.13
     */
    func initZeroPayView(){
        self.commonInit()
        
        /// 캡쳐 세션 사용 여부를 체크 합니다.
        self.viewModel.isAVCaptureSession().sink { result in
            
        } receiveValue: { metadataOutput in
            /// 캡쳐 세션 사용가능 합니다.
            if metadataOutput != nil
            {
                DispatchQueue.main.async {
                    /// QRCode 를 인식할 카메라 프리뷰 화면을 설정 합니다.
                    self.setPreviewLayer(metadataOutput)
                }
            }
        }.store(in: &cancellableSet)

        
        /// QR 코드 정보를 받습니다.
        self.viewModel.$qrCodeValue.sink { value in
            if value == .start { return }
        }.store(in: &cancellableSet)
    }
    
    
    /**
     프리뷰 화면 설정 메서드 이빈다.
     - Date : 2023.03.13
     - Parameters:
        - captureMetadataOutPut : 캡쳐할 메타데이터 output 정보 입니다.
     - Throws : False
     - returns :False
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
        let rect                    = CGRect(x: previewSize.width/2 - self.QRintersetView.frame.size.width/2, y: self.QRintersetView.frame.origin.y,
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
        
        /// 총 프리뷰 영역을 화면에 그립니다.
        //self.layer.addSublayer(previewLayer)
        self.previewView.layer.addSublayer(previewLayer)
        self.previewLayer           = previewLayer
        
        DispatchQueue.main.async {
            /// QRCode 스켄을 진행 합니다.
            captureSession.startRunning()
            /// QRCode 캡쳐 할 데이터 영역을 설정 합니다.
            captureMetadataOutPut!.rectOfInterest = self.previewLayer!.metadataOutputRectConverted(fromLayerRect: self.QRintersetView.frame)
        }
        
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        
        let btn : UIButton = sender as! UIButton
        /// 페이지 종료 이벤트 입니다.
        if btn.tag == 10
        {
            self.viewController.navigationController?.popViewController(animated: true, completion: {                
            })
            return
        }
        self.displayQRView.isHidden     = false
        /// QRCode 정상 처리 경우에만 QR디스프레이 가능 합니다.
        switch self.viewModel.qrCodeValue
        {
            case .qr_success(let qrcode):
            self.qrCodeGenerator.setCodeDisplay(.qrcode,code: NC.S(qrcode))
                self.barCodeGenerator.setCodeDisplay(.barcode,code: NC.S(qrcode))
                self.barCodeNumber.text  = qrcode
                break
            default:break
        }
        
    }
    
}


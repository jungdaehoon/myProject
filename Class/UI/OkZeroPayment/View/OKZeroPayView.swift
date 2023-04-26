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
 제로페이 페이지 버튼 타입 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.04.26
*/
enum ZEROPAY_BTN_TYPE : Int {
    /// 페이지 종료 입니다.
    case page_exit          = 10
    /// 바코드 결제 버튼 입니다.
    case barcode_pay        = 11
    /// QR 결제 타입 입니다.
    case qrcode_pay         = 12
    /// 신규 코드 생성 입니다.
    case creation_code      = 13
}


/**
 제로페이 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.20
*/
class OKZeroPayView: UIView {
    var viewModel                           : OKZeroViewModel = OKZeroViewModel()
    /// 바코드를 인식할 프리브 영역 입니다.
    var previewLayer                        : AVCaptureVideoPreviewLayer?
    /// 바코드 인식 할 영역 입니다.
    var rectOfInterest                      : CGRect?
    /// 제로페이 결제 할 코드타입을 설정 합니다. ( QRCode 결제 , BarCode 결제 )
    var zeroPayCodeType                     : ZEROPAY_CODE_TYPE = .barcode
    /// 전체 프리뷰 화면 입니다.
    @IBOutlet weak var previewView          : UIView!
    /// QR 인식 영역 뷰어 입니다. ( 영역만 가지고 있습니다. )
    @IBOutlet weak var QRintersetView       : UIView!
    /// QR 인식 영역 모서리 라인 이미지 입니다.
    @IBOutlet weak var qrcodeLineImg        : UIImageView!
    /// 결제 타입 선택시 선택여부 배경 입니다.
    @IBOutlet weak var payTypeBG            : UILabel!
    /// 결제 타입 배경 왼쪽 위치를 가집니다.
    @IBOutlet weak var payTypeBGLeft        : NSLayoutConstraint!
    /// 바코드 결제 버튼 입니다.
    @IBOutlet weak var barCodePayBtn        : UIButton!
    /// QRCode 결제 버튼 입니다.
    @IBOutlet weak var qrCodePayBtn         : UIButton!
    /// 바코드 배경 뷰어 입니다.
    @IBOutlet weak var barCodeView          : UIView!
    /// 바코드 생성 뷰어 입니다.
    @IBOutlet weak var barCodeGenerator     : QRorBarCodeGeneratorView!
    /// QRCode 배경 뷰어 입니다.
    @IBOutlet weak var qrCodeView           : UIView!
    /// QRCode 생성 뷰어 입니다.
    @IBOutlet weak var qrCodeGenerator      : QRorBarCodeGeneratorView!
    /// 코드 생성 버튼 배경 뷰어 입니다.
    @IBOutlet weak var codeCreationView     : UIView!
    /// 코드 생성 버튼 입니다.
    @IBOutlet weak var codeCreationBtn      : UIButton!
    /// 코드 활성화/비활성화 등 상황별 안내 문구 입니다.
    @IBOutlet weak var codeTypeInfoText     : UILabel!
    /// 코드 활성화 가능 타임 디스플레이 뷰어 입니다.
    @IBOutlet weak var codeEnabeldTimeView  : UIView!
    /// 코드 활성화중 디스플레이할 타임 문구 입니다.
    @IBOutlet weak var codeEnabeldTimeText  : UILabel!
    
    
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
        }.store(in: &self.viewModel.cancellableSet)

        
        /// QR 코드 정보를 받습니다.
        self.viewModel.$qrCodeValue.sink { value in
            if value == .start { return }
        }.store(in: &self.viewModel.cancellableSet)
        
        /// 초기 기본 타입은 바코드 결제 타입으로 디스플레이 합니다.
        self.setZeroPayCodeDisplay( type: self.zeroPayCodeType, animation: false )
    }
    

    /**
     프리뷰 화면과 캡쳐할 영역 설정 합니다.
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
    
    
    /**
     결제 코드별 타입을 화면 디스플레이 합니다.
     - Date : 2023.04.26
     - Parameters:
        - type : 코드 타입을 받습니다. ( .barcode : 바코드 타입 , .qrcode : QRCode 타입 )
     - Throws : False
     - returns :False
     */
    func setZeroPayCodeDisplay( type : ZEROPAY_CODE_TYPE, overTime : Bool = false, animation : Bool = true ) {
        switch type {
        case .barcode:
            /// 바코드 결제 타입 선택 입니다.
            self.zeroPayCodeType            = type
            /// QRCode 뷰어 히든 합니다.
            self.qrCodeView.isHidden        = true
            /// 바코드 를 디스플레이 합니다.
            self.barCodeView.isHidden       = false
            /// 바코드 디스플레이로 안내 문구를 바코드 결제 안내로 변경 합니다.
            self.codeTypeInfoText.text      = overTime == false ? "바코드 결제를 원하시면 하단 버튼을 눌러주세요" : "결제 유효시간이 초과되었습니다"
            /// 코드 생성 버튼을 디스플레이 합니다.
            self.codeCreationView.isHidden  = false
            /// 코드 생성 버튼 문구를 "바코드 생성" 으로 변경 합니다.
            self.codeCreationBtn.setTitle(overTime == false ? "바코드 생성" : "바코드 재생성", for: .normal)
            /// 바코드 결제 위치로 선택 배경을 이동합니다.
            UIView.animate(withDuration:animation == true ? 0.3 : 0.0, delay: 0.0, options: .curveEaseOut) {
                self.payTypeBGLeft.constant = 4.0
                self.layoutIfNeeded()
            } completion: { _ in
                /// 바코드 결제 위치 이동 완료로 "QR 결제" 폰트를 비활성으로 변경 합니다.
                self.qrCodePayBtn.titleLabel!.font = UIFont(name: "Pretendard-Regular", size: 14.0)
                self.qrCodePayBtn.setTitleColor(UIColor(hex: 0x666666), for: .normal)
                /// QR결제 위치 이동 완료로 "바코드 결제" 폰트를 비활성으로 변경 합니다.
                self.barCodePayBtn.titleLabel!.font = UIFont(name: "Pretendard-SemiBold", size: 14.0)
                self.barCodePayBtn.setTitleColor(UIColor(hex: 0x212121), for: .normal)
            }
            break
        case .qrcode:
            /// QR 결제 타입 선택 입니다.
            self.zeroPayCodeType            = type
            /// QRCode 뷰어를 디스플레이 합니다.
            self.qrCodeView.isHidden        = false
            /// 바코드 뷰어를 히든 합니다.
            self.barCodeView.isHidden       = true
            /// QRCode 디스플레이로 안내 문구를 QR 결제 안내로 변경 합니다.
            self.codeTypeInfoText.text      = overTime == false ? "QR 결제를 원하시면 하단 버튼을 눌러주세요" : "결제 유효시간이 초과되었습니다"
            /// 코드 생성 버튼을 디스플레이 합니다.
            self.codeCreationView.isHidden  = false
            /// 코드 생성 버튼 문구를 "QR코드 생성" 으로 변경 합니다.
            self.codeCreationBtn.setTitle(overTime == false ? "QR코드 생성" : "QR코드 재생성", for: .normal)
            /// QR결제 위치로 선택 배경을 이동 합니다.
            UIView.animate(withDuration: animation == true ? 0.3 : 0.0, delay: 0.0, options: .curveEaseOut) {
                self.payTypeBGLeft.constant = 92.0
                self.layoutIfNeeded()
            } completion: { _ in
                /// QR결제 위치 이동 완료로 "바코드 결제" 폰트를 비활성으로 변경 합니다.
                self.barCodePayBtn.titleLabel!.font = UIFont(name: "Pretendard-Regular", size: 14.0)
                self.barCodePayBtn.setTitleColor(UIColor(hex: 0x666666), for: .normal)
                /// QRCode 결제 위치 이동으로 폰트를 활성화 합니다.
                self.qrCodePayBtn.titleLabel!.font = UIFont(name: "Pretendard-SemiBold", size: 14.0)
                self.qrCodePayBtn.setTitleColor(UIColor(hex: 0x212121), for: .normal)
            }
            break
        }
    }
    
    
    /**
     코드생성으로 결제 코드를 생성 합니다.
     - Date : 2023.04.26
     - Parameters:False
     - Throws : False
     - returns :False
     */
    func setCodeCreationView(){
        /// 코드 정보를 요청해서 받는 API 추가 예정 입니다.
        let sampleCode = "8809276714800"
        if self.zeroPayCodeType == .barcode
        {
            /// 바코드를 제작 합니다.
            self.barCodeGenerator.setCodeDisplay(.barcode,code: NC.S(sampleCode)) { success in
                if success
                {
                    /// 바코드 타입으로 안내 문구를 변경 합니다.
                    self.codeTypeInfoText.text          = "매장에 바코드를 보여주세요"
                    self.viewModel.isTimeCodeEnabeld().sink { result in
                        print("isTimeCodeEnabeld completion finished")
                    } receiveValue: { type in
                        switch type
                        {
                        case .ing_time( let timer):
                            /// 라운드 컬러를 활성화 컬러로 변경 합니다.
                            self.barCodeView.borderColor             = .OKColor
                            /// 코드생성 버튼 뷰어를 히든처리 합니다.
                            self.codeCreationView.isHidden           = true
                            /// 코드 활성화 타임 뷰어를 디스플레이 합니다.
                            self.codeEnabeldTimeView.isHidden        = false
                            /// 코드 활성화 타임 문구 입니다.
                            self.codeEnabeldTimeText.text            = "  \(timer!)  "
                            /// 코드 이미지를 활성화 합니다.
                            self.barCodeGenerator.imageView.isHidden = false
                            print("isTimeCodeEnabeld sink timer : \(timer!)")
                        case .end_time:
                            /// 라운드 컬러를 활성화 컬러로 변경 합니다.
                            self.barCodeView.borderColor             = UIColor(hex: 0xE5E5E5)
                            /// 코드 활성화 타임 뷰어를 히든 합니다.
                            self.codeEnabeldTimeView.isHidden        = true
                            /// 타임 초과로 오버타입을 추가하고 코드 디스플레이 합니다.
                            self.setZeroPayCodeDisplay(type: .barcode, overTime: true)
                            /// 코드 이미지를 비활성화 합니다.
                            self.barCodeGenerator.imageView.isHidden = true
                            /// 코드 활성화 타임 문구 입니다.
                            self.codeEnabeldTimeText.text           = ""
                            break
                        default:break
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                }
            }
        }
        else
        {
            /// QRCode 를 제작 합니다.
            self.qrCodeGenerator.setCodeDisplay(.qrcode,code: NC.S(sampleCode)) { success in
                if success
                {
                    /// 바코드 타입으로 안내 문구를 변경 합니다.
                    self.codeTypeInfoText.text          = "매장에 QR코드를 보여주세요"
                    self.viewModel.isTimeCodeEnabeld().sink { result in
                        print("isTimeCodeEnabeld completion finished")
                    } receiveValue: { type in
                        switch type
                        {
                        case .ing_time( let timer):
                            /// 라운드 컬러를 비활성화 컬러로 변경 합니다.
                            self.qrCodeView.borderColor             = .OKColor
                            /// 코드생성 버튼 뷰어를 히든처리 합니다.
                            self.codeCreationView.isHidden          = true
                            /// 코드 활성화 타임 뷰어를 디스플레이 합니다.
                            self.codeEnabeldTimeView.isHidden       = false
                            /// 코드 활성화 타임 문구 입니다.
                            self.codeEnabeldTimeText.text           = "  \(timer!)  "
                            /// 코드 이미지를 활성화 합니다.
                            self.qrCodeGenerator.imageView.isHidden = false
                            print("isTimeCodeEnabeld sink timer : \(timer!)")
                        case .end_time:
                            /// 라운드 컬러를 비활성화 컬러로 변경 합니다.
                            self.qrCodeView.borderColor             = UIColor(hex: 0xE5E5E5)
                            /// 코드 활성화 타임 뷰어를 히든 합니다.
                            self.codeEnabeldTimeView.isHidden       = true
                            /// 타임 초과로 오버타입을 추가하고 코드 디스플레이 합니다.
                            self.setZeroPayCodeDisplay(type: .qrcode, overTime: true)
                            /// 코드 이미지를 활성화 합니다.
                            self.qrCodeGenerator.imageView.isHidden = true
                            /// 코드 활성화 타임 문구 입니다.
                            self.codeEnabeldTimeText.text           = ""
                            break
                        default:break
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                }
            }
        }
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let type =  ZEROPAY_BTN_TYPE(rawValue: (sender as AnyObject).tag)
        {
            switch type {
                /// 페이지 종료 입니다.
                case .page_exit:
                    self.viewController.navigationController?.popViewController(animated: true, animatedType: .down, completion: {
                    })
                    break
                /// 결제 타입 선택버튼 입니다.
                case .barcode_pay:
                    self.setZeroPayCodeDisplay( type: .barcode )
                case .qrcode_pay:
                    self.setZeroPayCodeDisplay( type: .qrcode )
                /// 코드 생성 요청 입니다.
                case .creation_code:
                    self.setCodeCreationView()
                    break
            }
            
        }
    }
    
    
    
    
    
    
}


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
 - Date: 2023.04.26
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
    /// 매장 찾기 입니다.
    case location_search     = 14
}


/**
 제로페이 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date: 2023.03.20
*/
class OKZeroPayView: UIView {
    var viewModel                           : OKZeroViewModel = OKZeroViewModel()
    /// 바코드를 인식할 프리브 영역 입니다.
    var previewLayer                        : AVCaptureVideoPreviewLayer?
    /// 바코드 인식 할 영역 입니다.
    var rectOfInterest                      : CGRect?
    /// 제로페이 결제 할 코드타입을 설정 합니다. ( QRCode 결제 , BarCode 결제 )
    var zeroPayCodeType                     : ZEROPAY_CODE_TYPE = .barcode
    /// 타이머 활성화 중인지를 체크 합니다.
    var isTimer                             : Bool = false
    /// 카드 전체 화면 디스플레이 여부 입니다.
    var isCardFullDisplay                   : Bool = false
    /// 코드 전체 화면 디스플레이 여부 입니다.
    var isCodeFullDisplay                   : Bool = false
    /// 바코드 결제 활성화 여부를 체크 합니다.
    var isBarCodePayEnabled                 : Bool = false
    /// QRCode 결제 활성화 여부를 체크 합니다.
    var isQrCodePayEnabled                  : Bool = false
    /// 전체 프리뷰 화면 입니다.
    @IBOutlet weak var previewView          : UIView!
    /// QR 인식 영역 뷰어 입니다. ( 영역만 가지고 있습니다. )
    @IBOutlet weak var QRintersetView       : UIView!
    /// QR 인식 영역 모서리 라인 이미지 입니다.
    @IBOutlet weak var qrcodeLineImg        : UIImageView!
    /// 상세 정보 뷰어의 상단 포지션 입니다.
    @IBOutlet weak var detaileViewTop       : NSLayoutConstraint!
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
    /// 코드 활성화시 타임 디스플레이 뷰어의 넓이 입니다.
    @IBOutlet weak var codeEnabledTimeWidth : NSLayoutConstraint!
    /// 코드 활성화중 디스플레이할 타임 문구 입니다.
    @IBOutlet weak var codeEnabeldTimeText  : UILabel!
    /// 코드 전체 화면 배경 뷰어 입니다.
    @IBOutlet weak var codeFullDisplayViewBG: UIView!
    /// 코드 전체 화면 입니다.
    @IBOutlet weak var codeFullDisplayView  : OKZeroPayCodeFullView!
    /// 코드 전체 화면 높이 입니다.
    @IBOutlet weak var codeFullHeight       : NSLayoutConstraint!
    //// 코드 전체 화면 넓이 입니다.
    @IBOutlet weak var codeFullWidth        : NSLayoutConstraint!
    /// 결제 가능한 카드 리스트 뷰어의 상단 연결 위치 정보 입니다.
    @IBOutlet weak var payCardListTop       : NSLayoutConstraint!
    /// 결제 가능한 카드 리스트 뷰어 입니다.
    @IBOutlet weak var payCardListView      : OKZeroPayCardListView!
    
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
     - Date: 2023.03.13
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

        /// 스캔한 결제 코드 정보를 받습니다.
        self.viewModel.$qrCodeValue.sink { value in
            switch value
            {
            case .qr_success(let qrcode):
                Slog("qrcode : \(qrcode!)")
                break
            default:break
            }
        }.store(in: &self.viewModel.cancellableSet)
                
        /// 결제코드 활성화시 타임 정보를 받습니다.
        self.viewModel.$codeTimer.sink { value in
            switch value
            {
            case .ing_time(let timer):
                /// 코드 활성화 타임 문구 입니다.
                self.codeEnabeldTimeText.text            = "\(timer!)"
                /// 코드 전체화면 모드 입니다.
                if self.isCodeFullDisplay
                {
                    if self.zeroPayCodeType == .barcode
                    {
                        /// 바코드 타입으로 안내 문구를 변경 합니다.
                        self.codeFullDisplayView.barCodeTypeInfoText.text    = self.codeTypeInfoText.text
                        /// qk코드 활성화 타임 문구 입니다.
                        self.codeFullDisplayView.barCodeEnabeldTimeText.text = self.codeEnabeldTimeText.text
                    }
                    else
                    {
                        /// 바코드 타입으로 안내 문구를 변경 합니다.
                        self.codeFullDisplayView.qrCodeTypeInfoText.text    = self.codeTypeInfoText.text
                        /// QRCode 활성화 타임 문구 입니다.
                        self.codeFullDisplayView.qrCodeEnabeldTimeText.text = self.codeEnabeldTimeText.text
                    }
                }
                break
            case .end_time:
                /// 타임 종료로 코드뷰를 초기화 합니다.
                self.releaseCodeView()
                break
            default:break
            }
        }.store(in: &self.viewModel.cancellableSet)
                
        /// 초기 기본 타입은 바코드 결제 타입으로 디스플레이 합니다.
        self.setZeroPayCodeDisplay( type: self.zeroPayCodeType, animation: false )
        /// 결제 가능 카드 리스트 뷰어를 디스플레이 합니다.
        self.payCardListView.setDisplay { success in
            /// 카드 디스플레이 전체 화면 여부를 활성화 합니다.
            self.setCardFullDisplay( display: true )
        }
    }
    

    /**
     프리뷰 화면과 캡쳐할 영역 설정 합니다.
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
     - Date: 2023.04.26
     - Parameters:
        - type : 코드 타입을 받습니다. ( .barcode : 바코드 타입 , .qrcode : QRCode 타입 )
        - overTime : 타이머 오버 값을 받습니다.
        - animation : 애니 사용 모드 입니다.
        - viewEnabled : 결제 타입 이동 없이 현 위치 뷰어만 상황별 디스플레이 하는 경우 입니다. ( 주로 현 결제 타입에서 타임 오버 되었을 경우 입니다. )
     - Throws: False
     - Returns:False
     */
    func setZeroPayCodeDisplay( type : ZEROPAY_CODE_TYPE, overTime : Bool = false, animation : Bool = true, viewEnabled : Bool = false ) {
        switch type {
        case .barcode:
            /// 바코드 결제 타입 선택 입니다.
            self.zeroPayCodeType            = type
            /// QRCode 뷰어 히든 합니다.
            self.qrCodeView.isHidden        = true
            /// 바코드 를 디스플레이 합니다.
            self.barCodeView.isHidden       = false
            /// 결제가 활성화 상태 입니다.
            if self.isBarCodePayEnabled
            {
                /// 결제 뷰어를 활성화 합니다.
                self.setPayViewEnabled(codeType: .barcode)
            }
            else
            {
                /// 바코드 디스플레이로 안내 문구를 바코드 결제 안내로 변경 합니다.
                self.codeTypeInfoText.text        = overTime == false ? "바코드 결제를 원하시면 하단 버튼을 눌러주세요" : "결제 유효시간이 초과되었습니다"
                /// 코드 생성 버튼을 디스플레이 합니다.
                self.codeCreationView.isHidden    = false
                /// 코드 생성 버튼 문구를 "바코드 생성" 으로 변경 합니다.
                self.codeCreationBtn.setTitle(overTime == false ? "바코드 생성" : "바코드 재생성", for: .normal)
                /// 타이머 디스플레이 하지 않습니다.
                self.codeEnabledTimeWidth.constant = 0
            }
            
            /// 뷰만 적용이 아닐경우 위치를 변경 합니다.
            if viewEnabled == false
            {
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
            }
            break
        case .qrcode:
            /// QR 결제 타입 선택 입니다.
            self.zeroPayCodeType            = type
            /// QRCode 뷰어를 디스플레이 합니다.
            self.qrCodeView.isHidden        = false
            /// 바코드 뷰어를 히든 합니다.
            self.barCodeView.isHidden       = true
            /// 결제가 활성화 상태 입니다.
            if self.isQrCodePayEnabled
            {
                /// 결제 뷰어를 활성화 합니다.
                self.setPayViewEnabled(codeType: .qrcode)
            }
            else
            {
                /// QRCode 디스플레이로 안내 문구를 QR 결제 안내로 변경 합니다.
                self.codeTypeInfoText.text        = overTime == false ? "QR 결제를 원하시면 하단 버튼을 눌러주세요" : "결제 유효시간이 초과되었습니다"
                /// 코드 생성 버튼을 디스플레이 합니다.
                self.codeCreationView.isHidden    = false
                /// 코드 생성 버튼 문구를 "QR코드 생성" 으로 변경 합니다.
                self.codeCreationBtn.setTitle(overTime == false ? "QR코드 생성" : "QR코드 재생성", for: .normal)
                /// 타이머를 디스플레이 하지 않습니다.
                self.codeEnabledTimeWidth.constant = 0
            }
            
            /// 뷰만 적용이 아닐경우 위치를 변경 합니다.
            if viewEnabled == false
            {
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
            }
            break
        }
    }
    
    
    /**
     생성된 결제 코드를 빈값으로 전부 초기화 합니다.
     - Date: 2023.04.27
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func releaseCodeView(){
        /// 바코드 라운드 컬러를 활성화 컬러로 변경 합니다.
        self.barCodeView.borderColor             = UIColor(hex: 0xE5E5E5)
        /// 코드 이미지를 비활성화 합니다.
        self.barCodeGenerator.imageView.isHidden = true
        /// 바코드 결제 비활성화 합니다.
        self.isBarCodePayEnabled                 = false
        
        /// 라운드 컬러를 비활성화 컬러로 변경 합니다.
        self.qrCodeView.borderColor             = UIColor(hex: 0xE5E5E5)
        /// 코드 이미지를 활성화 합니다.
        self.qrCodeGenerator.imageView.isHidden = true
        /// QRCode 결제 비활성화 합니다.
        self.isQrCodePayEnabled                 = false
        
        /// 타이머를 비활성화 합니다.
        self.isTimer                            = false
        /// 코드 활성화 타임 문구 입니다.
        self.codeEnabeldTimeText.text           = ""
        /// 코드 활성화 타임 뷰어를 히든 합니다.
        self.codeEnabledTimeWidth.constant      = 0
        
        /// 타임 초과로 오버타입을 추가하고 코드 디스플레이 합니다.
        self.setZeroPayCodeDisplay(type: self.zeroPayCodeType == .qrcode ? .barcode : .qrcode, overTime: true, viewEnabled: true)
        /// 타임 초과로 오버타입을 추가하고 코드 디스플레이 합니다.
        self.setZeroPayCodeDisplay(type: self.zeroPayCodeType == .qrcode ? .barcode : .qrcode , overTime: true, viewEnabled: true)
        /// 코드 전체화면 모드 입니다.
        if self.isCodeFullDisplay
        {
            /// 전체 화면 코드 화면을 종료 합니다.
            self.closeFullCodeDisplay()
        }
    }
    
    
    /**
     결제타입 뷰어를 활성화 합니다.
     - Date: 2023.04.27
     - Parameters:
        - codeType : 디스플레이 할 타입을 받습니다. ( .barcode : 바코드 타입 , .qrcode : QRCode 타입 )
     - Throws: False
     - Returns:False
     */
    func setPayViewEnabled( codeType : ZEROPAY_CODE_TYPE ){
        if codeType == .barcode
        {
            /// 바코드 타입으로 안내 문구를 변경 합니다.
            self.codeTypeInfoText.text          = "매장에 바코드를 보여주세요"
            /// 라운드 컬러를 활성화 컬러로 변경 합니다.
            self.barCodeView.borderColor        = .OKColor
        }
        else
        {
            /// 바코드 타입으로 안내 문구를 변경 합니다.
            self.codeTypeInfoText.text          = "매장에 QR코드를 보여주세요"
            /// 라운드 컬러를 비활성화 컬러로 변경 합니다.
            self.qrCodeView.borderColor         = .OKColor
        }
        /// 코드생성 버튼 뷰어를 히든처리 합니다.
        self.codeCreationView.isHidden      = true
        /// 코드 활성화 타임 뷰어를 디스플레이 합니다.
        self.codeEnabledTimeWidth.constant  = 49
        /// 코드 활성화 타임 문구 입니다.
        self.codeEnabeldTimeText.text       = self.isTimer == true ? self.codeEnabeldTimeText.text : "03:00"
    }
    
    
    /**
     코드생성으로 결제 코드를 생성 합니다.
     - Date: 2023.04.26
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func setCodeCreationView(){
        /// 코드 정보를 요청해서 받는 API 추가 예정 입니다.
        let sampleCode = "8809276714800"
        if self.zeroPayCodeType == .barcode
        {
            /// 바코드를 제작 합니다.
            self.barCodeGenerator.setCodeDisplay(.barcode, code: NC.S(sampleCode)) { success in
                if success
                {
                    /// 결제 뷰어를 활성화 합니다.
                    self.setPayViewEnabled(codeType: .barcode)
                    /// 바코드 결제를 활성화 합니다.
                    self.isBarCodePayEnabled            = true
                    /// 코드 이미지를 활성화 합니다.
                    self.barCodeGenerator.imageView.isHidden = false
                    /// 타이머 비활성화 를 체크 합니다.
                    if !self.isTimer
                    {
                        /// 타이머를 활성화 합니다.
                        self.isTimer = true
                        /// 코드 타이머 활성화 합니다.
                        self.viewModel.startCodeTimerEnabeld()
                    }
                }
            } btnEvent: { success in
                self.openFullCodeDisplay( codeType: .barcode, code : sampleCode )
            }
        }
        else
        {
            /// QRCode 를 제작 합니다.
            self.qrCodeGenerator.setCodeDisplay(.qrcode,code: NC.S(sampleCode)) { success in
                if success
                {
                    /// 결제 뷰어를 활성화 합니다.
                    self.setPayViewEnabled(codeType: .qrcode)
                    /// 코드 이미지를 활성화 합니다.
                    self.qrCodeGenerator.imageView.isHidden = false
                    ///  QRCode 결제 활성화 입니다.
                    self.isQrCodePayEnabled                 = true
                    /// 타이머 비활성화 를 체크 합니다.
                    if !self.isTimer
                    {
                        /// 타이머를 활성화 합니다.
                        self.isTimer = true
                        /// 코드 타이머 활성화 합니다.
                        self.viewModel.startCodeTimerEnabeld()
                    }
                }
            } btnEvent: { success in
                self.openFullCodeDisplay( codeType: .qrcode, code: sampleCode )
            }
        }
    }
    
    
    /**
     결제 코드를 전체 화면 디스플레이 합니다.
     - Date: 2023.04.27
     - Parameters:
        - codeType : 디스플레이 할 타입을 받습니다. ( .barcode : 바코드 타입 , .qrcode : QRCode 타입 )
        - code : 디스플레이 할 코드 정보 입니다.
     - Throws: False
     - Returns:False
     */
    func openFullCodeDisplay( codeType : ZEROPAY_CODE_TYPE, code : String = "" ){
        /// 결제 가능 카드 리스트 뷰어를 히든처리 합니다.
        self.payCardListView.isHidden       = true
        /// 전체 화면 디스플레이 여부를 활성화 합니다.
        self.isCodeFullDisplay              = true
        /// 전체 화면 코드 디스플레이 배경 입니다.
        self.codeFullDisplayViewBG.isHidden = false
        /// 디스플레이 가능한 최대 사이즈를 체크 합니다.
        let maxWidth                        = UIScreen.main.bounds.size.height - 124.0 > 484 ? 484 : UIScreen.main.bounds.size.height - 124.0
        let maxHeight                       = 243.0
        /// 코드 영역 화면을 최대 넓이로 수정 합니다.
        self.codeFullWidth.constant         = maxWidth
        /// 코드 영역 화면을 최대 높이로 수정 합니다.
        self.codeFullHeight.constant        = maxHeight
        /// 변경된 사이즈를 활성화 합니다.
        self.layoutIfNeeded()
        /// 전체화면을 활성화 합니다.
        self.codeFullDisplayView.setDisplayView(codeType: codeType, code: code) { success in
            if success
            {
                /// 바코드 경우 화면을 회전 합니다.
                if codeType == .barcode
                {
                    self.codeFullDisplayView.transform  = self.codeFullDisplayView.transform.rotated(by: .pi/2)
                }
                
                /// QR결제 위치로 선택 배경을 이동 합니다.
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                    self.detaileViewTop.constant        = 12.0
                    self.layoutIfNeeded()
                } completion: { _ in
                    
                }
            }
        }
    }
    
    
    /**
     결제 코드 전체 화면을 종료 합니다.
     - Date: 2023.04.27
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func closeFullCodeDisplay(){
        /// 결제 가능 카드 리스트 뷰어를 디스플레이 합니다.
        self.payCardListView.isHidden               = false
        /// 전체 화면 디스플레이 여부를 활성화 합니다.
        self.isCodeFullDisplay                      = false
        /// 전체 화면 코드 디스플레이 배경 입니다.
        self.codeFullDisplayViewBG.isHidden         = true
        /// 코드 영역 화면을 기본 크기로 변경 합니다.
        self.codeFullWidth.constant                 = 100
        /// 코드 영역 화면을 기본 크기로 변경 합니다.
        self.codeFullHeight.constant                = 100
        /// 회전을 원위치 합니다.
        self.codeFullDisplayView.transform          = .identity
        /// 디스플레이 정보를 초기화 합니다.
        self.codeFullDisplayView.releaseCodeView()
        /// QR결제 위치로 선택 배경을 이동 합니다.
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.detaileViewTop.constant        = 315.0
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    
    /**
     결제 카드 리스트 전체 화면을 종료 합니다.
     - Date: 2023.04.27
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    func closeFullCardDisplay(){
        /// 카드 디스플레이 전체 화면 여부를 비활성화 합니다.
        self.isCardFullDisplay          = false
        self.payCardListTop.constant    = (self.payCardListView.frame.origin.y * -1) + 48
        /// QR결제 위치로 선택 배경을 이동 합니다.
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.detaileViewTop.constant        = 315.0
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    
    /**
     결제 카드 리스트 전체 화면을 온오프 합니다.
     - Date: 2023.04.27
     - Parameters:
        - display : 디스플레이 여부 값을 받습니다. ( true : 카드 리스트 전체화면, false : 카드 하단 디스플레이 )
     - Throws: False
     - Returns:False
     */
    func setCardFullDisplay( display : Bool = true ){
        /// 카드 디스플레이 전체 화면 여부를 활성화 합니다.
        self.isCardFullDisplay                          = display
        /// 전체화면 활성화 버튼을 온/오프 합니다.
        self.payCardListView.listEnabledBtn.isHidden    = display
        /// 카드를 전체화면 디스플레이 합니다.
        if display == true
        {
            let update_y                                = (self.payCardListView.frame.origin.y * -1) + 48
            let deplay1                                 = self.detaileViewTop.constant
            self.payCardListTop.constant                = update_y
            /// QR결제 위치로 선택 배경을 이동 합니다.
            UIView.animate(withDuration: 0.20, delay: 0.0, options: .curveEaseIn) {
                self.detaileViewTop.constant        = display == true ? 12.0 : 315.0
                print("self.detaileViewTop.constant : \(self.detaileViewTop.constant)")
                if display == false { self.payCardListView.setCardBottom() }
                if display == true { self.payCardListView.setCardBottom( topPosition : (update_y * -1) + deplay1) }
                self.layoutIfNeeded()
            } completion: { _ in
                if display == true { self.payCardListView.setCardFullDisplay() }
            }
        }
        /// 카드를 하단에 디스플레이 합니다.
        else
        {
            /// 하단에 순차적으로 디스플레이 합니다.
            self.payCardListView.setCardFullAniClose(index: 0) { [self] success in
                self.perform(#selector(setCardFullAniDelayClose), with: nil, afterDelay: 0.05)
            }
        }
    }
    
    
    /**
     하단 순차적으로 디스플레이후 최종 배경 위치 값을 초기화 합니다.
     - Date: 2023.04.27
     - Parameters:False
     - Throws: False
     - Returns:False
     */
    @objc func setCardFullAniDelayClose(){
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut) {
            self.payCardListTop.constant        = (self.payCardListView.frame.origin.y * -1) + 48
            self.detaileViewTop.constant        = 315.0
            self.payCardListView.setCardBottom()
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
        
    }
    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let type =  ZEROPAY_BTN_TYPE(rawValue: (sender as AnyObject).tag)
        {
            switch type {
                /// 페이지 종료 입니다.
                case .page_exit:
                    /// 카드 전체화면 디스플레이 경우 입니다.
                    if self.isCardFullDisplay
                    {
                        self.setCardFullDisplay( display: false )
                        return
                    }
                
                    /// 코드 전체화면 디스플레이 경우 입니다.
                    if self.isCodeFullDisplay
                    {
                        self.closeFullCodeDisplay()
                        return
                    }
                
                    /// 타이머가 돌고있을경우 강제종료하고 페이지를 닫습니다.
                    if self.isTimer
                    {
                        self.viewModel.codeTimer = .exit_time
                    }
                    self.popViewController(animated: true, animatedType:  .down)
                    break
                /// 결제 타입 선택버튼 입니다.
                case .barcode_pay:
                    /// 바코드 결제 타입을 활성화 합니다.
                    self.setZeroPayCodeDisplay( type: .barcode, animation: false )
                case .qrcode_pay:
                    /// QR 결제 타입을 활성화 합니다.
                    self.setZeroPayCodeDisplay( type: .qrcode, animation: false )
                /// 코드 생성 요청 입니다.
                case .creation_code:
                    /// 결제할 코드생성을 디스플레이 합니다.
                    self.setCodeCreationView()
                    break
                case .location_search:
                    /// 제로페이 가맹점 검색 URL 입니다.
                    let urlString = "https://map.naver.com/v5/search/%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4%20%EA%B0%80%EB%A7%B9%EC%A0%90?c=15,0,0,0,dh".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                        /// 제로페이 가맹점 네이버 지도를 요청 합니다.
                    self.setDisplayWebView(urlString!, modalPresent: true, animatedType: .left, titleName: "가맹점 찾기", titleBarType: 1, titleBarHidden: false)
                    break
            }
            
        }
    }
    
}


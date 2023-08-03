//
//  OKZeroPayCodeFullView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/27.
//

import UIKit


/**
 제로페이 결제코드 전체화면 뷰어 입니다.  ( J.D.H VER : 1.24.43 )
 - Date: 2023.04.27
 */
class OKZeroPayCodeFullView: UIView {

    /// 바코드 디스플레이 뷰어 입니다.
    @IBOutlet weak var barCodeDisplayView       : UIView!
    /// 바코드 활성화/비활성화 등 상황별 안내 문구 입니다.
    @IBOutlet weak var barCodeTypeInfoText      : UILabel!
    /// 바코드 활성화중 디스플레이할 타임 배경 입니다.
    @IBOutlet weak var barCodeEnabledTimeView   : UIView!
    /// 바코드 활성화중 디스플레이할 타임 문구 입니다.
    @IBOutlet weak var barCodeEnabeldTimeText   : UILabel!
    /// 바코드 이미지 영역 배경 뷰어 입니다.
    @IBOutlet weak var barCodeView              : UIView!
    /// 바코드 생성 뷰어 입니다.
    @IBOutlet weak var barCodeGenerator         : QRorBarCodeGeneratorView!
    /// 바코드 넘버 입니다.
    @IBOutlet weak var barCodeNumberText        : UILabel!
    /// QRCode 디스플레이 뷰어 입니다.
    @IBOutlet weak var qrCodeDisplayView        : UIView!
    /// QRCode 활성화/비활성화 등 상황별 안내 문구 입니다.
    @IBOutlet weak var qrCodeTypeInfoText       : UILabel!
    /// QRCode 활성화중 디스플레이할 타임 뷰어 입니다.
    @IBOutlet weak var qrCodeEnabledTimeView    : UIView!
    /// QRCode 활성화중 디스플레이할 타임 문구 입니다.
    @IBOutlet weak var qrCodeEnabeldTimeText    : UILabel!
    /// QRCode 이미지 영역 배경 뷰어 입니다.
    @IBOutlet weak var qrCodeView               : UIView!
    /// QRCode 생성 뷰어 입니다.
    @IBOutlet weak var qrCodeGenerator          : QRorBarCodeGeneratorView!
    
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initZeroPayCodeFullView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initZeroPayCodeFullView()
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     제로페이 결제코드 전체화면 초기화 합니다.  ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.27
     */
    func initZeroPayCodeFullView(){
        self.commonInit()
    }
    
    
    /**
     전체 화면에 코드정보를 빈값으로 초기화 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.27
     - Parameters:
        - codeType : 디스플레이 할 타입을 받습니다. ( .barcode : 바코드 타입 , .qrcode : QRCode 타입 )
        - code : 디스플레이 할 코드 정보 입니다.
        - completion : 결제 코드 정상 디스플레이 여부를 리턴 합니다.
     - Throws: False
     - Returns:False
     */
    func releaseCodeView()
    {
        /// 바코드 타입으로 안내 문구를 초기화 합니다.
        self.barCodeTypeInfoText.text    = ""
        /// 바코드 활성화 타임 문구 초기화 입니다.
        self.barCodeEnabeldTimeText.text = ""
        /// 바코드 넘버를 초기화 합니다.
        self.barCodeNumberText.text      = ""
        /// QRCode 안내 문구를 초기화 합니다.
        self.qrCodeTypeInfoText.text     = ""
        /// QRCode 타임 문구를 초기화 합니다.
        self.qrCodeEnabeldTimeText.text  = ""
        /// 라운드 라인 컬러를 비활성화 컬러로 변경 합니다.
        self.barCodeView.borderColor     = UIColor(hex: 0xE5E5E5)
        /// 라운드 라인 컬러를 비활성화 컬러로 변경 합니다.
        self.qrCodeView.borderColor      = UIColor(hex: 0xE5E5E5)
    }
    
    
    /**
     결제 코드를 전체 화면에 설정 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.27
     - Parameters:
        - codeType : 디스플레이 할 타입을 받습니다. ( .barcode : 바코드 타입 , .qrcode : QRCode 타입 )
        - code : 디스플레이 할 코드 정보 입니다.
        - completion : 결제 코드 정상 디스플레이 여부를 리턴 합니다.
     - Throws: False
     - Returns:False
     */
    func setDisplayView( codeType : ZEROPAY_CODE_TYPE , code : String, completion : (( _ success : Bool ) -> Void)? = nil ){
        /// 바코드 뷰어 입니다.
        if codeType == .barcode
        {
            /// QRCode 뷰어를 히든 처리 합니다.
            self.qrCodeDisplayView.isHidden         = true
            /// 바코드 전체 뷰어를 디스플레이 합니다.
            self.barCodeDisplayView.isHidden        = false
            /// 바코드 영역 뷰어를 디스플레이 합니다.
            self.barCodeView.isHidden               = false
            /// 라운드 라인 컬러를 활성화 컬러로 변경 합니다.
            self.barCodeView.borderColor            = .OKColor
            /// 바코드 타임 뷰어를 활성화 합니다.
            self.barCodeEnabledTimeView.isHidden    = false
            /// 바코드 타입으로 안내 문구를 변경 합니다.
            self.barCodeTypeInfoText.text           = "매장에 바코드를 보여주세요"
            /// 바코드 넘버를 디스플레이 합니다.
            self.barCodeNumberText.text             = code.addSpace()
            /// 전체 화면 디스플레이 값입니다.
            self.barCodeGenerator.fullDisplay       = true
            /// 바코드 결제 이미지를 디스플레이 합니다.
            self.barCodeGenerator.setCodeDisplay(.barcode, code: code, completion: { success in
                if success
                {
                    /// 바코드 결제 이미지를 활성화 합니다.
                    self.barCodeGenerator.imageView.isHidden = false
                    completion!(true)
                }
            })
        }
        /// QRCode 뷰어 입니다.
        else
        {
            /// 바코드 전체 뷰어를 히든 합니다.
            self.barCodeDisplayView.isHidden        = true
            /// QRCode 전체 뷰어를 디스플레이 합니다.
            self.qrCodeDisplayView.isHidden         = false
            /// QRCode 영역 뷰어를 디스플레이 합니다.
            self.qrCodeView.isHidden                = false
            /// QRCode 영역 라운드 컬러를 활성화 합니다.
            self.qrCodeView.borderColor             = .OKColor
            /// QRCode 사용가능 안내 문구를 디스플레이 합니다.
            self.qrCodeTypeInfoText.text            = "매장에 QR코드를 보여주세요"
            /// 전체 화면 디스플레이 값입니다.
            self.qrCodeGenerator.fullDisplay        = true
            /// QRCode 결제 이미지를 디스플레이 합니다.
            self.qrCodeGenerator.setCodeDisplay(.qrcode, code: code, completion: { success in
                if success
                {
                    /// QRCode 결제 이미지를 활성화 합니다.
                    self.qrCodeGenerator.imageView.isHidden = false
                    completion!(true)
                }
            })
        }
    }
}

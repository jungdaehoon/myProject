//
//  AllMoreViewController.swift
//  OkPay
//
//  Created by DaeHoon Chung on 2023/03/06.
//


import UIKit



/**
 QRcode 및 바코드 생성 뷰어 입니다. ( J.D.H VER : 1.24.43 )
 - Date: 2023.03.20
*/
class QRorBarCodeGeneratorView: UIView {

    /// 화면에 디스플레이할 코드 뷰어 입니다.
    @IBOutlet weak var imageView    : UIImageView!
    /// QR/바코드 정보를 가집니다.
    var code                        : String?
    /// 코드 타입정보를 저장합니다.
    var type                        : ZEROPAY_CODE_TYPE?
    /// 코드 선택시 이벤트 입니다.
    var btnEvent                    : (( _ success : Bool ) -> Void)? = nil
    /// 전체화면 디스플레이 여부를 체크 합니다.
    var fullDisplay                 : Bool = false
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initGeneratorView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initGeneratorView()
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     제로페이 QRCode 뷰어 입니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.03.13
     */
    func initGeneratorView(){
        /// Xib 연결 합니다.
        self.commonInit()
    }
    
    
    /**
     코드별 디스플레이할 이미지 세팅 입니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.03.20
     - Parameters:
        - codeType : 코드 타입 정보를 받습니다.
        - code : 코드 정보 입니다.
        - completion : 코드가 정상 적으로 생성되었는지를 리턴 합니다.
        - btnEvent : 버튼 이벤트를 리턴 합니다.
     - Throws: False
     - Returns:False
     */
    func setCodeDisplay( _ codeType : ZEROPAY_CODE_TYPE,
                         code : String = "",
                         completion : (( _ success : Bool ) -> Void)? = nil,
                         btnEvent : (( _ success : Bool ) -> Void)? = nil)
    {
        self.code       = code
        self.type       = codeType
        self.btnEvent   = btnEvent
        switch codeType {
        case .barcode:
            if let image = self.generateBarcode128(code)
            {
                Slog("setCodeDisplay self.frame.size : \(self.frame.size)")
                self.imageView.image        = self.resize(image: image, size: self.frame.size)
                completion!(true)
            }
            break
        case .qrcode:
            self.imageView.tintColor         = .black
            self.imageView.backgroundColor   = .white
            if let image = self.generateQRCode(code)
            {
                self.imageView.image = image
                completion!(true)
            }
            break
        }
    }
    
    
    /**
     이미지를 원하는 사이즈로 리사이징 하여 리턴 합니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.04.26
     - parameters:
        - image : 원본 이미지를 받습니다.
        - size : 이미지를 넓이 기준으로 리사이징 합니다.
     - Throws:False
     - returns:
        리사이징 된 이미지를 리턴 합니다. (UIImage)
    */
    func resize( image : UIImage, size : CGSize) -> UIImage {
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            if self.fullDisplay
            {
                image.draw(in: CGRect(origin: CGPoint(x: -30.0, y: -35.0), size: CGSize(width: size.width + 60, height: size.height + 70)))
            }
            else
            {
                image.draw(in: CGRect(origin: CGPoint(x: -15.0, y: -20.0), size: CGSize(width: size.width + 30, height: size.height + 40)))
            }
            
        }
        return renderImage
    }
    
    
    
    /**
     바코드 이미지 생성 입니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.03.13
     - Parameters:
        - barcode : 이미지로 생성될 바코드 정보 입니다.
        - scale : 이미지 크기를 설정 합니다.
     - Throws: False
     - Returns:
        barcode 문자를 이미지로 변경한 데이터를 리턴 합니다. (UIImage)
     */
    func generateBarcode128( _ barcode: String, scale : CGFloat = 10.0 ) -> UIImage? {
        let data = barcode.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output,scale: 2.0, orientation: .down)
            }
        }
        return nil
    }
    
    
    /**
     QR코드 이미지 생성 입니다. ( J.D.H VER : 1.24.43 )
     - Date: 2023.03.13
     - Parameters:
        - qrcode : 이미지로 생성될 QRCode 정보 입니다.
        - scale : QRCode 이미지 크기 정보 입니다.
     - Throws: False
     - Returns:
        QRCode 문자를 이미지로 변경한 데이터를 리턴 합니다. (UIImage)        
     */
    func generateQRCode(_ qrcode: String, scale : CGFloat = 10.0 ) -> UIImage? {

        let data = qrcode.data(using: .isoLatin1, allowLossyConversion: false)
        /// 필터 정보에 CIQRCodeGenerator : QR code 생성 필터를 식별하기 위한 속성을 설정 합니다.
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            /// 필터에 설정 정보를 추가 합니다.
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("M", forKey: "inputCorrectionLevel")
            /// 이미지 여부 체크 합니다.
            guard let ciImage = filter.outputImage else {
                return nil
            }
            
            /// 이미지 선명도를 높이기 위해 scale 배율을 10배 증가 합니다.
            let transformed = ciImage.transformed(by: CGAffineTransform.init(scaleX: scale, y: scale))

            /// 색상 반전 필터를 적용 합니다.
            let invertFilter = CIFilter(name: "CIColorInvert")
            invertFilter?.setValue(transformed, forKey: kCIInputImageKey)

            /// CIMaskToAlpha : grayscale 로 변환된 이미지를 alpha 로 마스킹된 흰색이미지로 변환합니다.
            let alphaFilter = CIFilter(name: "CIMaskToAlpha")
            alphaFilter?.setValue(invertFilter?.outputImage, forKey: kCIInputImageKey)

            /// 이미지를 세팅 합니다.
            if let ouputImage = alphaFilter?.outputImage {
                /// withRenderingMode(.alwaysTemplate) : 원본 이미지의 컬러정보가 사라지고 불투명한 부분을 tintColor 로 설정합니다.
                return UIImage(ciImage: ouputImage, scale: 2.0, orientation: .up).withRenderingMode(.alwaysTemplate)
            } else {
                return nil
            }
        }
        return nil
    }

    
    
    //MARK: - 버튼 액션 입니다.
    @IBAction func btn_action(_ sender: Any) {
        if let event = self.btnEvent
        {
            event(true)
        }                
    }
    
    
}

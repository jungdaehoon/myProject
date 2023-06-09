//
//  QRReaderViewController.swift
//  cereal
//
//  Created by develop wells on 2023/03/24.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol QRReaderVcDelegate : class {
    func readQRResult(  _ controller : QRReaderViewController , action : DelegateButtonAction ,   info: Any?    ) -> Void
}

class QRReaderViewController: UIViewController {

    weak var delegate : QRReaderVcDelegate? = nil
    
    private let captureSession = AVCaptureSession()
    /// 이벤트를 넘깁니다.
    var completion  : (( _ value : Any? ) -> Void )? = nil
    var readQRAddr : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetup()
        
    }

    override func viewDidLayoutSubviews() {
        setVideoLayer()
        setGuideBG()

    }
    
    @IBOutlet weak var readView: UIView!
    
    @IBAction func onCloseBtn( sender: Any) {
        self.closeCapture()
    }
    
    private func initSetup(){
        DispatchQueue.global(qos: .background).async {
            self.startcapture()
        }
    }
    
    /**
     데이터 세팅 입니다.
     - Date: 2023.03.13
     - Parameters:
        - captureMetadataOutPut : 캡쳐할 메타데이터 output 정보 입니다.
     - Throws: False
     - Returns:False
     */
    func setInitData( completion : (( _ value : Any? ) -> Void)? = nil ) {
        self.completion = completion
    }
    
    
    private func closeCapture(){
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                self.delegate?.readQRResult(self, action: .close, info:self.readQRAddr)
                if let completion = self.completion { completion(self.readQRAddr) }
                self.popController(animated: true, animatedType: .down)
            }
        }
    }
    
    
    private func startcapture() {

        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("No video device found")
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)

            captureSession.addInput(input)

            // capture session 에 의해서 생성된 시간제한 metadata 를 처리하기 위한 capture output.
            // 영상으로 촬영하면서 지속적으로 생성되는 metadata 를 처리하는 output .
            let output = AVCaptureMetadataOutput()

            captureSession.addOutput(output)

            // queue : delegate 의 메서드를 실행할 큐이다. 이 큐는 metadata 가 받은 순서대로 전달되려면 반드시 serial queue(직렬큐) 여야 한다.
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            // 리더기가 인식할 수 있는 코드 타입을 정한다.
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            // startRunning() 과 stopRunning() 로 흐름 통제
            // input 에서 output 으로의 데이터 흐름을 시작
            captureSession.startRunning()
        }
        catch {
            Slog("error")
        }
    }

    private func setVideoLayer() {
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = readView.layer.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        readView.layer.addSublayer(videoLayer)
    }

    private func setGuideBG() {
        let guideCrossLine = UIImageView()
        guideCrossLine.image = UIImage(systemName: "plus")
        guideCrossLine.tintColor = .lightGray
        guideCrossLine.translatesAutoresizingMaskIntoConstraints = false
        readView.addSubview(guideCrossLine)
    
        let overlay = createOverlay()
        readView.addSubview(overlay)
        
        let screenW = Int(readView.frame.width)
        let tBgRect = CGRect(x: 0,
                                y: 0,
                                width: screenW,
                                height: 56)
        let vTitleBG = UIView(frame: tBgRect)
        vTitleBG.backgroundColor = UIColor.white
        
        readView.addSubview(vTitleBG)
        
        let tTitleRect = CGRect(x: 0,
                                y: 0,
                                width: screenW,
                                height: 56)
        let lbTitle = UILabel(frame: tTitleRect)
        lbTitle.textAlignment = .center
        lbTitle.text = "QR 코드 인식"
        lbTitle.textColor = .black //UIColor(red: 0x22, green: 0x22, blue: 0x22)
        lbTitle.font = UIFont.boldSystemFont(ofSize: 18)
        
        readView.addSubview(lbTitle)
        
        let imgW = 30
        let tCloseRect = CGRect(x: screenW - imgW - 20,
                           y: (56-imgW)/2,
                           width: imgW,
                           height: imgW)
        let btnClose = UIButton(frame: tCloseRect)
        btnClose.setTitle("", for: .normal)
        btnClose.addTarget(self, action: #selector(self.onCloseBtn( sender : )), for: .touchUpInside)
        if let image = UIImage(named: "header_close") {
            btnClose.setImage(image, for: .normal)
        }
        
        readView.addSubview(btnClose)
        
        
        NSLayoutConstraint.activate([
            guideCrossLine.centerXAnchor.constraint(equalTo: readView.centerXAnchor),
            guideCrossLine.centerYAnchor.constraint(equalTo: readView.centerYAnchor),
            guideCrossLine.widthAnchor.constraint(equalToConstant: 30),
            guideCrossLine.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func createOverlay() -> UIView {
        let tRect = CGRect(x: 0,
                           y: 0,
                           width: readView.frame.width,
                           height: readView.frame.height)
        
        let overlayView = UIView(frame: tRect)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let path = CGMutablePath()

        let width  = 213 // ? overlayView.frame.width - left -right
        
        path.addRoundedRect(in: CGRect(x: (Int(overlayView.frame.width) - width)/2 ,
                                       y: (Int(overlayView.frame.height) - width)/2,
                                       width: width,
                                       height: width),
                            cornerWidth: 0, cornerHeight: 0)

        
        path.closeSubpath()
        
        let shape = CAShapeLayer()
        shape.path = path
        shape.lineWidth = 1.0
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.white.cgColor
        
        overlayView.layer.addSublayer(shape)
        
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        
        return overlayView
    }
    
}


// 생성된 metatdata 를 수신하는 메서드.
// 이 프로토콜은 위에서처럼 AVCaptureMetadataOutput object 가 채택해야만 한다. 단일 메서드가 있고 옵션이다.
extension QRReaderViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        // 새로 내보낸 AVMetadataObject 인스턴스 배열이다.
        if let metadataObject = metadataObjects.first {

            // AVMetadataObject 는 추상 클래스이므로 이 배열의 object 는 항상 구체적인 하위 클래스의 인스턴스여야 한다.
            // AVMetadataObject 를 직접 서브클래싱해선 안된다. 대신 AVFroundation 프레임워크에서 제공하는 정의된 하위 클래스 중 하나를 사용해야 한다.
            // AVMetadataMachineReadableCodeObject : 바코드의 기능을 정의하는 AVMetadataObject 의 구체적인 하위 클래스. 인스턴스는 이미지에서 감지된 판독 가능한 바코드의 기능과 payload 를 설명하는 immutable object 를 나타낸다.
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let stringValue = readableObject.stringValue else {
                return
            }

            if stringValue.hasPrefix("0x") && (stringValue.count > 10)  {
                Slog("QR read : \(stringValue)")
                self.readQRAddr = stringValue
                
                self.onCloseBtn(sender:"")
            }
            else{
                Slog("readError : \(stringValue)")
            }
        }
    }

}

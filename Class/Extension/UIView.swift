//
//  UIView.swift
//  MyData
//
//  Created by UMCios on 2022/01/06.
//

import UIKit
import WebKit


extension UIView {
    func commonInit() {
        guard let xibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last else { return }
        if let _ = Bundle.main.path(forResource: xibName, ofType: "nib")  {
            let any = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)
            let view = any?.first as! UIView
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
    class func fromNib(_ named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard
            let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
            else { fatalError("missing expected nib named: \(name)") }
        guard
            /// we're using `first` here because compact map chokes compiler on
            /// optimized release, so you can't use two views in one nib if you wanted to
            /// and are now looking at this
            let view = nib.first as? Self
            else { fatalError("view of type \(Self.self) not found in \(nib)") }
        return view
    }
    
    func addConstraintsToFit(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: view,
                               attribute: NSLayoutConstraint.Attribute.leading,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: self,
                               attribute: NSLayoutConstraint.Attribute.leading,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: view,
                               attribute: NSLayoutConstraint.Attribute.trailing,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: self,
                               attribute: NSLayoutConstraint.Attribute.trailing,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: view,
                               attribute: NSLayoutConstraint.Attribute.top,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: self,
                               attribute: NSLayoutConstraint.Attribute.top,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: view,
                               attribute: NSLayoutConstraint.Attribute.bottom,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: self,
                               attribute: NSLayoutConstraint.Attribute.bottom,
                               multiplier: 1,
                               constant: 0),
        ])
    }
    
    /**
     Xib View 를 가져 옵니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.0211
     - returns
        - UIView Type
            > Xib 에서 가져온 UIView 를 리턴 합니다.
     */
    func instanceBundle() -> UIView
    {
        let bundle = Bundle(for: Self.self)
        return bundle.loadNibNamed("\(Self.self)", owner: self, options: nil)![0] as! UIView
    }
    
    
    /**
     Xib View Layout  상위뷰 사이즈에 맞춰 고정 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.0211
     - Parameters :
            - view : 상위 뷰어에 사이즈 맞춰 고정할 뷰어 입니다.
     - returns
        - UIView Type
            > Xib 에서 가져온 UIView 를 리턴 합니다.
     */
    func initializeConstraints( _ view : UIView )
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ view.topAnchor.constraint(equalTo: self.topAnchor),
                                      view.rightAnchor.constraint(equalTo: self.rightAnchor),
                                      view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                      view.heightAnchor.constraint(equalToConstant:self.bounds.size.height)])
    }
    
    
    /**
     Xib 와 UIView Class 를 연결 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.0211
     */
    func initView()
    {
        let xibView = self.instanceBundle()
        self.addSubview(xibView)
        self.initializeConstraints(xibView)
    }
    
    
    /**
     연결된 UIViewcontroller 를 사용 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.02.16
     */
    var viewController : UIViewController
    {
        get
        {
            if let vc = self.next as? UIViewController
            {
                return vc
            }
            else if self.superview != nil
            {
                return superview!.viewController
            }
            else
            {
                return UIViewController()
            }
        }
    }
    
    
    /**
     링크 기준으로 전체 화면 웹뷰를 디스플레이 합니다.
     - Date : 2023.03.13
     - Parameters:
        - linkUrl : 연결할 웹페이지 입니다.
        - modalPresent : 신규 컨트롤러 뷰어로 모달 오픈 할지를 받습니다.
        - animatedType : 모달 팝업시 에니 효과 입니다.
        - titleName : 타이틀 명칭 입니다.
        - titleBarType  : 타이틀바 디스플레이 타입 입니다. ( 0 : 타이틀바 히든, 1 : 뒤로가기버튼, 2 : 종료 버튼 ) default : 0
        - titleBarHidden : 타이틀바 디스플레이 여부를 받습니다. ( default false )
        - completion : 콜백 데이터 입니다.
     - Throws : False
     - returns :False
     */
    func setDisplayWebView( _ linkUrl       : String        = "",
                            modalPresent    : Bool          = false,
                            pageType        : FULL_PAGE_TYPE = .default_type,
                            animatedType    : AnimationType = .up,
                            titleName       : String        = "",
                            titleBarType    : Int           = 0,
                            titleBarHidden  : Bool          = false,
                            completion      : (( _ value : FULL_WEB_CB ) -> Void )? = nil ) {
        if modalPresent
        {
            let webview =  FullWebViewController( pageType: pageType, title: titleName,titleBarType: titleBarType, titleBarHidden: titleBarHidden, pageURL: linkUrl, completion : completion)
            webview.modalPresentationStyle = .overFullScreen
            self.viewController.navigationController!.pushViewController(webview, animated: true, animatedType: animatedType)
        }
        else
        {
            if self.viewController.isKind(of: BaseViewController.self)
            {
                let controller : BaseViewController = self.viewController as! BaseViewController
                controller.webView!.isHidden = false
                if let controller = self.viewController as? AllMoreViewController
                {
                    controller.webDisplayView.isHidden = false
                }
                /// 배경 전체 탭 컬러값으로 변경 합니다.
                controller.view.backgroundColor    = UIColor(hex: 0xFFFFFF)
                controller.loadMainURL(linkUrl)
            }
        }
    }
    
    
    /**
     UIViewController 를 받아 네비 컨트롤로 효과로 페이지 이동 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2023.05.09
     - Parameters:
        - controller : 이동할 타켓 컨트롤 뷰어 입니다.
        - animated : 페이지 이동 애니 효과 입니다.  ( default : true )
        - animationType : 페이지 이동할 효과 정보를 받습니다.  ( default : .left )
        - completion : 페이지 이동후 콜백 입니다.
     - returns : False
     */
    func pushViewController( _ controller: UIViewController, animated: Bool = true, animatedType: AnimationType? = .left, completion: @escaping () -> Void = {} )
    {
        /// 타켓 뷰어를 페이지 이동 합니다.
        self.viewController.navigationController?.pushViewController(controller, animated: animated, animatedType: animatedType!,completion: completion)
    }
    

    /**
     최 앞단 페이지로 이동 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.05.09
     - Parameters:
        - animated : 페이지 이동 애니 효과 입니다.  ( default : true )
        - animationType : 페이지 이동할 효과 정보를 받습니다. ( default : .right )
        - completion : 페이지 이동후 콜백 입니다.
     - returns : False
     */
    func popToRootViewController( animated : Bool = true, animatedType: AnimationType? = .right, completion: @escaping () -> Void = {} ){
        let rootController          = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        let childs                  = rootController!.children
        
        /// 탭 정보가 1 이상인경우 네비게이션 컨트롤 타입을 적용 합니다.
        if childs.count > 1
        {
            self.viewController.navigationController?.popToRootViewController(animated: animated, animatedType: animatedType, completion: completion)
        }
        /// 탭 정보가 2보다 작은 경우는 모달 타입으로 신규 루트 뷰어가 오픈된거로 체크 합니다.
        else
        {
            /// 연결된 루트 뷰어 모달 타입을 체크 합니다.
            if let presented = rootController!.presentedViewController {
                /// 모달 타입 뷰어의 0 번째 컨트롤러의 네비 위치를 0번째로 이동하며 해당 모달 타입을 내립니다.
                let presentedChilds = presented.children
                let root = presentedChilds[0] as UIViewController
                root.navigationController?.popToRootViewController(animated: false)
                root.dismiss(animated: animated)
            }
            
            /// 연결된 루트 뷰어가 네비 타입으로 연결된 경우 0번째로 이동 합니다.
            rootController?.navigationController?.popToRootViewController(animated: animated)
        }
    }
    
    
    
    /**
     배경에 쉐도우 를 추가 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.05.03
     - Parameters:
        - rect : 배경 넓이 입니다.
        - alpha : 쉐도우 배경 컬러 알파 값입니다.
     - returns : False
     */
    func setShadowEnabled( _ rect : CGRect , alpha : CGFloat? = 0.04 ){
        let path                    = UIBezierPath(rect: rect)
        self.layer.masksToBounds    = false
        self.layer.shadowColor      = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha!).cgColor
        self.layer.shadowOffset     = .zero
        self.layer.shadowOpacity    = 1.0
        self.layer.shadowRadius     = self.cornerRadius
        self.layer.shadowPath       = path.cgPath
    }
    
    
    /**
     배경에 그라데이션 컬러를 하단에서 상단으로 추가 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.05.03
     - Parameters:
        - starColor : 시작 컬러 입니다.
        - endColor : 종료 컬러 입니다.
     - returns : False
     */
    func setGradientDownTop( starColor : UIColor , endColor : UIColor ){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors     = [starColor.cgColor,endColor.cgColor]
        gradient.locations  = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.endPoint   = CGPoint(x: 1.0, y: 0.0)
        gradient.frame      = bounds
        layer.addSublayer(gradient)
    }
    
    
    /**
     배경에 그라데이션 컬러를 오른쪽 하단에서 왼쪽 상단으로 추가 합니다. ( J.D.H  VER : 1.0.0 )
     - Date : 2022.05.03
     - Parameters:
        - starColor : 시작 컬러 입니다.
        - endColor : 종료 컬러 입니다.
     - returns : False
     */
    func setGradientRightDownLeftTop( starColor : UIColor , endColor : UIColor ){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors     = [starColor.cgColor,endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)
        gradient.frame      = bounds
        layer.addSublayer(gradient)
    }
    
    
}

@IBDesignable
extension UIView {
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set (radius) {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        }
    }

    @IBInspectable public var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set (borderWidth) {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable public var borderColor:UIColor? {
        get {
            if let color = self.layer.borderColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set (color) {
            self.layer.borderColor = color?.cgColor
        }
    }
}

private var SwViewCaptureKey_IsCapturing: String = "SwViewCapture_AssoKey_isCapturing"
extension UIView
{
    @objc public func swSetFrame(_ frame: CGRect) {
        // Do nothing, use for swizzling
    }
    
    var isCapturing:Bool! {
        get {
            let num = objc_getAssociatedObject(self, &SwViewCaptureKey_IsCapturing)
            if num == nil {
                return false
            }
            
            if let numObj = num as? NSNumber {
                return numObj.boolValue
            }else {
                return false
            }
        }
        set(newValue) {
            let num = NSNumber(value: newValue as Bool)
            objc_setAssociatedObject(self, &SwViewCaptureKey_IsCapturing, num, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Ref: chromium source - snapshot_manager, fix wkwebview screenshot bug.
    // https://chromium.googlesource.com/chromium/src.git/+/46.0.2478.0/ios/chrome/browser/snapshots/snapshot_manager.mm
    public func swContainsWKWebView() -> Bool {
        if self.isKind(of: WKWebView.self) {
            return true
        }
        for subView in self.subviews {
            if (subView.swContainsWKWebView()) {
                return true
            }
        }
        return false
    }
    
    public func swCapture(_ completionHandler: (_ capturedImage: UIImage?) -> Void) {
        
        self.isCapturing = true
        
        let bounds = self.bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.translateBy(x: -self.frame.origin.x, y: -self.frame.origin.y);
        
        if (swContainsWKWebView()) {
            self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }else{
            self.layer.render(in: context!)
        }
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        context?.restoreGState();
        UIGraphicsEndImageContext()
        
        self.isCapturing = false
        
        completionHandler(capturedImage)
    }
}

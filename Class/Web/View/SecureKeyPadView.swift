//
//  SecureKeyPadView.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/28.
//

import UIKit

/**
 키패드 상황별 리턴 타입입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.29
*/
enum SecureKeyPadCBType {
    /// 진행중인 값을 전달 합니다.
    case progress( message : Any )
    /// 완료 처리된 경우 입니다.
    case success( message : Any )
    /// 실패 처리된 경우 입니다.
    case fail( message : String )
    /// 취소 입니다.
    case cancel
}


/**
 키패드 뷰어 입니다. ( J.D.H  VER : 1.0.0 )
 - Date : 2023.03.29
*/
class SecureKeyPadView: UIView {

    /// 이벤트를 넘깁니다.
    var completion                      : (( _ CBType : SecureKeyPadCBType ) -> Void )? = nil
    /// 보안 키페드 관련 입니다.
    var xkKeypadType                : XKeypadType?
    var xkKeypadViewType            : XKeypadViewType?
    var xkPasswordTextField         : XKTextField!
    /// 보안 키패드에 입력된 정보를 저장 합니다.
    var xkindexedInputText          : String?
    /// 보안 키패드 최대 입력 카운트 입니다.
    var maxNumber                   : Int?
    /// 보안 키패드 타입 입니다.
    var keyPadType                  : String?
    
    
    
    
    //MARK: - Init
    init( maxNumber : Int, padType : String, completion : (( _ CBType : SecureKeyPadCBType ) -> Void )? = nil  ) {
        super.init(frame: UIScreen.main.bounds)
        self.maxNumber  = maxNumber
        self.keyPadType = padType
        self.completion = completion
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initXKTextField()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initXKTextField()
    }
    
    
    
    //MARK: - 지원 메서드 입니다.
    /**
     보안 키페드 를 초기화 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.24
     - Parameters:Fasle
     - Throws : False
     - returns :False
     */
    func initXKTextField() {
        self.commonInit()
        xkKeypadType                        = self.keyPadType! == "qwerty" ? .qwerty : .number
        xkKeypadViewType                    = .normalView
        xkPasswordTextField                 = XKTextField(frame: CGRect.zero)
        xkPasswordTextField.isFromFullView  = true
        xkPasswordTextField.returnDelegate  = self
        xkPasswordTextField.xkeypadType     = xkKeypadType!
        xkPasswordTextField.xkeypadViewType = xkKeypadViewType!
        xkPasswordTextField.subTitle        = "비밀번호"
        xkPasswordTextField.e2eURL          = WebPageConstants.URL_KEYBOARD_E2E
        self.addSubview(xkPasswordTextField)
        self.setResignFirstResponder()
        print("xkKeypadType!:\(xkKeypadType!)")
        print("xkKeypadViewType!!:\(xkKeypadViewType!)")
        print("e2eURLString!!:\(WebPageConstants.URL_KEYBOARD_E2E)")
        print("xkPasswordTextField::\(xkPasswordTextField)")
        /// 배경 터치 키패드 종료 이벤트 연결 입니다.
        let gesture : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureRecognized(_ :)))
        self.addGestureRecognizer(gesture)
        
    }
     
    
    /**
     보안 키페드 를 활성화 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.27
     - Parameters:Fasle
     - Throws : False
     - returns :False
     */
    func xkKeyPadBecomeFirstResponder() {
        self.endEditing(true)
        self.isHidden = false
        self.xkPasswordTextField.becomeFirstResponder()
    }
    
    
    /**
     키페드 를 종료 합니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.27
     - Parameters:Fasle
     - Throws : False
     - returns :False
     */
    func setResignFirstResponder() {
        self.isHidden = true
        self.xkPasswordTextField.resignFirstResponder()
        self.endEditing(true)
    }
    
    
    /**
     보안키패드 입력 될 때 마다 받는 콜백 메서드 입니다.  ( J.D.H  VER : 1.0.0 )
     - Date : 2023.03.24
     - Parameters:
        - aCount: 입력된 카운트 정보 입니다.
        - finished : 입력 여부 입니다. ( true : 입력완료 , false : 미입력 )
        - tuple : finished 가 true 일 때  tuple 입력 받습니다.. ( 보안 키패드 관련된 sessionid, token , e2edata)
     - Throws : False
     - returns :False
     */
    func mainKeypadInputCompleted(_ aCount: Int,  finished : Bool = false, tuple : (String,String)? = nil ) {
        var retMessage  : [String : Any]  = [:]
        let ret         : [String : Any]  = ["count" :  aCount ]
        
        if let ( _, token) = tuple
        {
            let mData       = xkPasswordTextField.getDataE2E()
            var aSessionID  = xkPasswordTextField.getSessionIDE2E()
            if aSessionID!.count < 8 {
                let appendZero = "0"
                let count = aSessionID!.count
                let paddingCount = 8 - count
                let i = 0
                for  _ in i ..< paddingCount {
                    aSessionID = appendZero + aSessionID!
                }
            }
            let append : [String : Any] =  ["sessionid" : aSessionID! , "token" :  token , "e2edata" :  mData! ]
            let mergeResult = ret.merging(append) { $1 }
            retMessage = mergeResult
        }
        else
        {
            retMessage["result"] = ret
        }
        
        // 입력 완료 (finished == true) 일 경우 , 보안키패드 관련된 항목 ( sessionid, token , e2edata) 를 JSON 형태로 보낸다.
        if finished
        {
            self.setResignFirstResponder()
            do {
                let scriptMsg = try Utils.toJSONString(retMessage)
                if aCount < self.maxNumber!
                {
                    self.completion!( .fail(message: "보안키패드 입력 길이 자리수 오류") )
                }
                else
                {
                    self.completion!( .success(message: scriptMsg!) )
                }
            } catch {
                self.completion!( .fail(message:"보안키패드 결과 JSON 리턴 오류") )
            }
        }
        else
        {
            self.completion!( .progress(message: "\(aCount)"))
        }
    }
    

    
    // MARK: - GestureRecognizer
    @objc func tapGestureRecognized(_ gestureRecognizer:UITapGestureRecognizer) {
        self.setResignFirstResponder()
    }
}



//MARK: - XKTextFieldDelegate
extension SecureKeyPadView : XKTextFieldDelegate{
    func keypadInputCompleted(_ aCount: Int) {
        self.mainKeypadInputCompleted(aCount,finished: true)
    }
    
    
    func keypadE2EInputCompleted(_ aSessionID: String!, token aToken: String!, indexCount aCount: Int) {
        print("ABC keypadE2EInputCompleted aSessionID \(aSessionID) aToken \(aToken) aCount \(aCount)")
        self.mainKeypadInputCompleted(aCount,finished: true,tuple: (aSessionID, aToken ) )
        xkPasswordTextField.cancelKeypad()
        self.endEditing(true)
    }
    
    func keypadCanceled() {
        print("ABC keypadCanceled ")
        self.setResignFirstResponder()
    }
    
    
    /// 입력 길이가 변화 할 때 마다 XKTextFieldDelegate 의 콜백 메소드
    /// - Parameters:
    ///   - length: 입력 length
    func textField(_ textField: XKTextField!, shouldChangeLength length: UInt) -> Bool {
        if length == self.maxNumber!
        {
            let aSessionID = xkPasswordTextField.getSessionIDE2E()
            let aToken = xkPasswordTextField.getTokenE2E()
            
            self.mainKeypadInputCompleted(Int(length),finished: true,tuple: (aSessionID!, aToken! ) )
        }
        else
        {
            self.mainKeypadInputCompleted(Int(length))
        }
        return true
    }
    
    
    func textFieldShouldDeleteCharacter(_ textField: XKTextField!) -> Bool {
        print("ABC textFieldShouldDeleteCharacter length:\(String(describing: textField.text?.count))")
        self.mainKeypadInputCompleted((textField.text?.count)!)
        return true
    }
    
    func textFieldSessionTimeOut(_ textField: XKTextField!) {
        print("ABC textFieldSessionTimeOut ")
        textField.cancelKeypad();
        /// 세션만료 안내 팝업 오픈 입니다.
        CMAlertView().setAlertView(detailObject: "보안 세션이 만료되었습니다.\n다시 실행해 주세요." as AnyObject, cancelText: "확인") { event in
            self.setResignFirstResponder()
        }
    }
    
    
}


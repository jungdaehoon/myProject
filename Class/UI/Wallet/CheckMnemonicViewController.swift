//
//  CheckMnemonicViewController.swift
//  cereal
//
//  Created by develop wells on 2023/03/31.
//  Copyright © 2023 srkang. All rights reserved.
//

import Foundation

enum DelegateButtonAction {
    case close
    case login
    case logout
    case memberJoin
    case changeID
    case change90Pw
    case findPw
    case invalidToken
    case wakeSleepUser
    case tokenReissue
}




protocol CheckMnemonicVcDelegate : class {
    func checkMnemonicResult(  _ controller : CheckMnemonicViewController , action : DelegateButtonAction ,   info: Any?    ) -> Void
    
}

class CheckMnemonicViewController: UIViewController {

    
    weak var delegate : CheckMnemonicVcDelegate? = nil
    var mAlertView: UIAlertController?
    
    var org3 : String = ""
    var org5 : String = ""
    var org9 : String = ""
    var org11 : String = ""

    var selLine1 : String = ""
    var selLine2 : String = ""
    var selLine3 : String = ""
    var selLine4 : String = ""

    @IBOutlet weak var seg1: UISegmentedControl!
    @IBOutlet weak var seg2: UISegmentedControl!
    @IBOutlet weak var seg3: UISegmentedControl!
    @IBOutlet weak var seg4: UISegmentedControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadData()
        initControl()
        
    }
    

    @IBAction func onConfirm(_ sender: Any) {
        
        if (checkSelectOK()){
            BaseViewModel.setGAEvent(page: "월렛 복구구문 기록",area: "하단" ,label: "확인")
            self.dismiss(animated: true, completion: {
                self.delegate?.checkMnemonicResult(self, action: .close, info: nil)
            })
        }else{
            /// 안내 팝업 오픈 합니다.
            CMAlertView().setAlertView(detailObject: "복구 구문 확인이 틀렸습니다.\n복구 구문 순서에 맞게 다시 선택하거나,뒤로 돌아가 복구 구문을\n다시 기록하세요." as AnyObject, cancelText: "확인") { event in
            }
        }

    }
    
    @IBAction func onCloseBtn(_ sender: Any) {
        BaseViewModel.setGAEvent(page: "월렛 복구구문 기록",area: "상단" ,label: "뒤로가기")
        self.onPrev(sender)
    }
    
    @IBAction func onPrev(_ sender: Any) {
        BaseViewModel.setGAEvent(page: "월렛 복구구문 기록",area: "하단" ,label: "이전")
        self.dismiss(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        Slog("Login deinit")
    }
    

    private func checkSelectOK() -> Bool{
        let index1 = seg1.selectedSegmentIndex
        let selLine1 = seg1.titleForSegment(at: index1)
        
        let index2 = seg2.selectedSegmentIndex
        let selLine2 = seg2.titleForSegment(at: index2)
        
        let index3 = seg3.selectedSegmentIndex
        let selLine3 = seg3.titleForSegment(at: index3)
        
        let index4 = seg4.selectedSegmentIndex
        let selLine4 = seg4.titleForSegment(at: index4)
        
        if org3.compare(selLine1!, options: .caseInsensitive) != .orderedSame {
            return false
        }
        if org5.compare(selLine2!, options: .caseInsensitive) != .orderedSame {
            return false
        }
        if org9.compare(selLine3!, options: .caseInsensitive) != .orderedSame {
            return false
        }
        if org11.compare(selLine4!, options: .caseInsensitive) != .orderedSame {
            return false
        }
        
        return true
    }
    
    func loadData(){
        var mnemonicTxt = SharedDefaults.default.walletMnemonic
        if(mnemonicTxt.count == 0){
            mnemonicTxt = "니모닉 정보가 없습니다."
        }
        let arrMne = mnemonicTxt.split(separator: " ")
        
        if(arrMne.count == 12){
            org3 = String(arrMne[2]) //3rd
            org5 = String(arrMne[4]) //5th
            org9 = String(arrMne[8]) //9th
            org11 = String(arrMne[10]) //11th
            
            var line1List = NSMutableArray(array: [arrMne[0],arrMne[1],arrMne[2]])
            var line2List = NSMutableArray(array: [arrMne[3],arrMne[4],arrMne[5]])
            var line3List = NSMutableArray(array: [arrMne[6],arrMne[7],arrMne[8]])
            var line4List = NSMutableArray(array: [arrMne[9],arrMne[10],arrMne[11]])
            
            if let swiftArray = line1List as NSArray as? [String] {
                // Use swiftArray here
            }

            let shufList1 = line1List.shuffled()
            let shufList2 = line2List.shuffled()
            let shufList3 = line3List.shuffled()
            let shufList4 = line4List.shuffled()
            
            seg1.setTitle(shufList1[0] as! String , forSegmentAt: 0)
            seg1.setTitle(shufList1[1] as! String , forSegmentAt: 1)
            seg1.setTitle(shufList1[2] as! String , forSegmentAt: 2)

            seg2.setTitle(shufList2[0] as! String , forSegmentAt: 0)
            seg2.setTitle(shufList2[1] as! String , forSegmentAt: 1)
            seg2.setTitle(shufList2[2] as! String , forSegmentAt: 2)

            seg3.setTitle(shufList3[0] as! String , forSegmentAt: 0)
            seg3.setTitle(shufList3[1] as! String , forSegmentAt: 1)
            seg3.setTitle(shufList3[2] as! String , forSegmentAt: 2)

            seg4.setTitle(shufList4[0] as! String , forSegmentAt: 0)
            seg4.setTitle(shufList4[1] as! String , forSegmentAt: 1)
            seg4.setTitle(shufList4[2] as! String , forSegmentAt: 2)

        }

    }
    
    @IBAction func seg_action(_ sender: Any) {
        if let seg = sender as? UISegmentedControl {
            BaseViewModel.setGAEvent(page: "월렛 복구구문 기록",area: "\(seg.selectedSegmentIndex + 1)번째_복구단어" ,label: "단어선택")
        }
        
    }
    
    
    // 컨트롤 셋팅
    func initControl() {
        if let custItem = SharedDefaults.getKeyChainCustItem()
        {
            // 자동로그인 여부를 키체인에서 가져와서 셋팅
            if custItem.auto_login {
            }
        }
                
        var mnemonicTxt = SharedDefaults.default.walletMnemonic
        if(mnemonicTxt.count == 0){
            mnemonicTxt = "니모닉 정보가 없습니다."
        }
        
    }

    @IBAction func btnCopyClipAction(_ sender: Any) {
        self.delegate?.checkMnemonicResult(self, action: .memberJoin, info: nil)
    }
    
}


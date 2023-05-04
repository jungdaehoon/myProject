//
//  PedometerViewController.swift
//  cereal
//
//  Created by 아프로 on 2021/10/28.
//  Copyright © 2021 srkang. All rights reserved.
//

import UIKit
import CoreMotion
import HealthKit


class PedometerViewController: BaseViewController {
    var viewModel : PedometerModel = PedometerModel()
    static let WEEK_DATA = "WEEK_DATA"
    //static let TERMS_NOTI = "TERMS_NOTI"
    
    @IBOutlet weak var ibLabelReward: UILabel!
    @IBOutlet weak var ibProgressView: UIProgressView!
    @IBOutlet weak var ibWalkingLeading: NSLayoutConstraint!
    @IBOutlet weak var ibBtnReward: UIButton!
    @IBOutlet weak var ibViewFirst: UIView!
    @IBOutlet weak var ibStackSecond: UIStackView!
    @IBOutlet weak var ibLabelStep: UILabel!
    @IBOutlet weak var ibViewSecond: UIView!
    @IBOutlet weak var ibContentView: UIView!
    @IBOutlet weak var ibImageViewWalking: UIImageView!
    @IBOutlet weak var ibViewPopUp: UIView!
    @IBOutlet weak var ibLabelPoint: UILabel!
    @IBOutlet weak var ibViewPopUpContent: UIView!
    @IBOutlet weak var ibViewSecondContent: UIView!
    @IBOutlet weak var ibViewPedoInfo: UIView!
    
    @IBOutlet weak var ibViewMainStack: UIStackView!
    
    //필요시 처리
    var mIsAuthorized: Bool = false
    var mPeometerCount: Int = 0
    
    var mTotalPoint: Int = 0 //누적포인트
    var mPoint: Int = 0 //랜덤포인트
    
    private let emitterLayer = CAEmitterLayer()
        
    var mStpesInfo = [[String:Any]]()
    
    var mCallback : ((_:[[String:Any]])->Void)? = nil
    
    let activitymanager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
        
    lazy var defaults:UserDefaults = {
        return .standard
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 최초 진입인 경우 입니다.
        if SharedDefaults.default.pedometerFirstDate == ""
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let currDate = formatter.string(from: Date())
            SharedDefaults.default.pedometerFirstDate = currDate
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
       // NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground(notification:)), name: NSNotification.Name(PedometerViewController.TERMS_NOTI), object: nil)
        
        self.ibContentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        self.ibViewFirst.layer.cornerRadius = 10
        self.ibViewFirst.clipsToBounds = true
        
        self.ibViewFirst.layer.shadowOpacity = 0.2
        self.ibViewFirst.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.ibViewFirst.layer.shadowRadius = 3
        self.ibViewFirst.layer.masksToBounds = false
        
        self.setView()
        
        self.ibViewSecond.layer.cornerRadius = 10
        self.ibViewSecond.clipsToBounds = true
        
        self.ibViewPopUpContent.layer.cornerRadius = 15
        self.ibViewPopUpContent.clipsToBounds = true
        
        self.ibViewPopUp.isHidden = true
        
        self.__setProgressLayout(progress: self.ibProgressView)
        
        //동전뿌려지는 UI
        self.setUpEmitterLayer()
        self.setUpTapGestureRecognizer()
        
        
        if SharedDefaults.default.pedometerTermsAgree == "Y"
        {
            self.getHealthData()
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func setView(){
        self.ibViewPedoInfo.layer.shadowOpacity = 0.2
        self.ibViewPedoInfo.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.ibViewPedoInfo.layer.shadowRadius = 3
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Slog("viewDidAppear")
        
        if let callback = self.mCallback
        {
            self.sendWeekData(data: self.mStpesInfo)
        }

        if SharedDefaults.default.pedometerTermsAgree == "N"
        {
            let terms = [TERMS_INFO.init(title: "서비스 이용안내", url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S001"),TERMS_INFO.init(title: "개인정보 수집·이용 동의",url: WebPageConstants.URL_PEDO_TERMS + "?terms_cd=S002")]
            BottomTermsView().setDisplay( target: self, "도전! 만보GO 서비스를 이용하실려면\n이용약관에 동의해주세요",
                                         termsList: terms) { value in
                /// 동의/취소 여부를 받습니다.
                if value == .success
                {
                    /// 약관동의 처리를 요청합니다.
                    self.viewModel.setPTTermAgreeCheck().sink { result in
                        
                    } receiveValue: { response in
                        if response != nil
                        {
                            /// 약관동의가 정상처리 되었습니다
                            if response?.code == "0000"
                            {
                                /// 약관동의 여부를 "Y" 변경 합니다.
                                SharedDefaults.default.pedometerTermsAgree = "Y"
                            }
                            /// 약관 동의 요청에 실패 하였습니다.
                            else
                            {
                                self.dismiss(animated: true)
                            }
                        }
                    }.store(in: &self.viewModel.cancellableSet)
                }
                else
                {
                    
                }
            }
        }
        
        
    }
    
    func getHealthData()
    {
        Slog("getHealthData")
        
        HealthKitManager.healthCheck{ (result) in
            if result
            {
                self.mIsAuthorized = true
                HealthKitManager.getTodaysSteps {   (steps) in
                    if steps == 0 {
                        DispatchQueue.main.async {
                            self.mIsAuthorized = false
                            /// 만보기 서비스 이용활성화를 위해 설정으로 이동 안내 팝업 오픈 입니다.
                            CMAlertView().setAlertView(detailObject: "만보기 서비스이용을 위해  \n 건강앱에 들어가셔서 데이터 접근 권한을 허용해주세요." as AnyObject, cancelText: "확인") { event in
                                "x-apple-health://".openUrl()
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.mPeometerCount = Int(steps)
                            //                        self.__setLayout()
                            self.getWeekPedoMeter(callback: self.sendData)
                            self.updateTime()
                            //추후 보상들어가면 삭제
                            self.getData()
                        }
                    }
                    
                }
            }
            else
            {
                DispatchQueue.main.async {
                    self.mIsAuthorized = false
                    /// 만보기 서비스 이용활성화를 위해 설정으로 이동 안내 팝업 오픈 입니다.
                    CMAlertView().setAlertView(detailObject: "만보기 서비스이용을 위해  \n 건강앱에 들어가셔서 데이터 접근 권한을 허용해주세요." as AnyObject, cancelText: "확인") { event in
                        "x-apple-health://".openUrl()
                    }
                }
            }
            
        }
    }
    
    
    func openUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    @objc func updateTime(){
        
        var steps : Int = 0
        let count = self.mPeometerCount
        
        if CMPedometer.isStepCountingAvailable(){
            
            self.pedoMeter.startUpdates(from: Date()) { (date, error) in
                
                DispatchQueue.main.async {
                    if error == nil{
                        if let response = date {
            
                            steps += response.numberOfSteps.intValue
                            
                            if steps >= response.numberOfSteps.intValue
                            {
                                steps = response.numberOfSteps.intValue
                            }
                            
                            self.mPeometerCount = count + response.numberOfSteps.intValue
                            self.__setLayout()
                        }
                    }
                    else
                    {
                        /// 만보기 서비스 이용활성화를 위해 설정으로 이동 안내 팝업 오픈 입니다.
                        CMAlertView().setAlertView(detailObject: "만보기 서비스이용을 위해  \n 동작 및 피트니스 접근 권한을 허용해 주세요." as AnyObject, cancelText: "확인") { event in
                            UIApplication.openSettingsURLString.openUrl()
                        }
                        
                    }
                }
            }
        }
        else
        {
            Slog("is not StepCountingAvailable")
        }
    }
    
    
    
    
    func getData()
    {
        self.viewModel.getPedometer().sink { result in
            
        } receiveValue: { response in
            if response != nil
            {
                self.ibLabelReward.text = "\(response!._data!._total_rcv_point!)P"
                self.__setLayout()
            }
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    func getWeekPedoMeter(callback : @escaping ((_ : [[String:Any]]) -> Void))
    {
        let today  = Date()
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let initManbogoDate = formatter.date(from: SharedDefaults.default.pedometerFirstDate) ?? Date()
        
        
        
        for i in -7 ..< 1
        {
            let specificDay = Calendar.current.date(byAdding: .day, value: i, to: today)
            
            if initManbogoDate <= specificDay!{
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let date = formatter.string(from: Date(timeIntervalSince1970: specificDay!.timeIntervalSince1970))
                
                
                HealthKitManager.getSpecificDaysStepsCount(forSpecificDate: specificDay!) { (steps) in
                    
                    if steps != 0.0 {
                        DispatchQueue.main.async {
                            var data = [String:Any]()
                            data["date"] = date
                            data["steps"] = Int(steps)
                            self.mStpesInfo.append(data)
                            
                            callback(self.mStpesInfo)
                            self.mCallback =  callback
                        }
                        
                    }
                }
                
            }
            
            
        }
        
    }
    
    
    
    func sendData(data : [[String:Any]])
    {
        Slog("success_result")
    }
    
    
    func sendWeekData(data : [[String:Any]])
    {
        
        let timestamp = "\(Date().ticks)"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)

        let param = AES256Util.encrypt(string: jsonString!, timestamp: timestamp)
        Slog("encrypt_param::\(param)")
        let decrypt = AES256Util.decrypt(encoded: param, timestamp:  timestamp)

        Slog("decrypt_param::\(decrypt)")
        
        var parameters  : [String:Any] = [:]
        parameters = ["verification" : param + timestamp, "info_list": data]
        
        /// 만보고 정보르 업데이트 합니다.
        self.viewModel.setPedometerUpdate(parameters).sink { result in
            
        } receiveValue: { response in
            
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    func testWeekData()
    {
        
        let timestamp = "\(Date().ticks)"
    
        let data = [["date":"20220315","steps":"1800"]]
     
        Slog("check::\(   data.description)")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let param = AES256Util.encrypt(string: jsonString!, timestamp: timestamp)

        Slog("encrypt_param::\(param)")
        let decrypt = AES256Util.decrypt(encoded: param, timestamp:  timestamp)

        Slog("decrypt_param::\(decrypt)")
        
        var parameters  : [String:Any] = [:]
        parameters = ["verification" : param + timestamp, "info_list": data]
        
        /// 만보고 정보르 업데이트 합니다.
        self.viewModel.setPedometerUpdate(parameters).sink { result in
            
        } receiveValue: { response in
            
        }.store(in: &self.viewModel.cancellableSet)
    }
    
    
    
    func __setLayout()
    {
        let result              = CGFloat(self.mPeometerCount)
        let stepCount           = String(self.mPeometerCount)
        self.ibLabelStep.text   = stepCount.insertComma
        self.ibProgressView.progress = Float(result / 10000)
        
        if self.mPeometerCount > 100
        {
            self.ibWalkingLeading.constant = (CGFloat(ibProgressView.progress) * (UIScreen.main.bounds.width - 62))
            self.ibWalkingLeading.constant = self.ibWalkingLeading.constant - 10
        }
        else
        {
            self.ibWalkingLeading.constant = -1.5
        }
        
        
        if self.mPeometerCount >= 10000
        {
            self.ibImageViewWalking.isHidden = false
            if let data = self.viewModel.pedometerRewardResponse
            {
                if data._data!._reward_yn! == "N"
                {
                    self.changeButtonColor(button: self.ibBtnReward, selected: true)
                }
                else
                {
                    self.changeButtonColor(button: self.ibBtnReward, selected: false)
                }
                
            }
            
        }
        else
        {
            Slog("selected false")
            if self.mPeometerCount == 0
            {
                self.ibImageViewWalking.isHidden = true
            }
            else
            {
                self.ibImageViewWalking.isHidden = false
            }
            
            self.changeButtonColor(button: self.ibBtnReward, selected: false)
        }
        
        
        
    }
    
    func animate()
    {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push //1.
        animation.subtype = CATransitionSubtype.fromTop
        self.ibLabelStep.text =  String(self.mPeometerCount)
        animation.duration = 0.25
        self.ibLabelStep.layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    
    func getReward()
    {
        let timestamp   = "\(UInt64(Int64(Date().timeIntervalSince1970 * 1000)))"
        let param       = AES256Util.encrypt(string: "\(self.mPeometerCount)", timestamp: timestamp)
        Slog("get_reward_encrypt_param::\(param)")
        let decrypt     = AES256Util.decrypt(encoded: param, timestamp:  timestamp)
        Slog("get_reward_decrypt_param::\(decrypt)")
        
        var parameters  : [String:Any] = [:]
        parameters      = ["verification": param + timestamp, "steps" :  self.mPeometerCount]
        /// 만보기 리워드를 요청 합니다.
        self.viewModel.getPedometerReward( parameters ).sink { result in
            
        } receiveValue: { response in
            if response != nil
            {
                let data                    = response!._data
                self.ibLabelReward.text    = "\(data!._total_rcv_point!)P"
                self.ibLabelPoint.text     = "\(data!._rcv_point!)P"
                self.__setLayout()
                self.ibViewPopUp.isHidden  = false
                self.showCoins()
            }
        }.store(in: &self.baseViewModel.cancellableSet)
    }
    
    
    
    @objc func willEnterForeground(notification : Notification)
    {
        self.getHealthData()
//        self.updateTime()
    }
    
    
    @IBAction func onTappedBanner(_ sender: UIButton) {
        
    }
    
    
    @IBAction func onTappedReward(_ sender: UIButton) {
        self.getReward()
    }
    
    func __setProgressLayout(progress:UIProgressView){
        progress.transform = progress.transform.scaledBy(x: 1, y: 4)
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.layer.sublayers![1].cornerRadius = 4
        progress.subviews[1].clipsToBounds = true
    }
    
    func changeButtonColor(button: UIButton, selected : Bool) {
        
        var color : UIColor
        
        if selected {
            color = UIColor(red:124/255, green: 77/255, blue: 209/255, alpha: 1.0)
            button.setTitleColor(UIColor.white, for: .normal)
            
            self.ibViewSecond.borderColor = color
            self.ibViewSecond.borderWidth = 1
            self.ibImageViewWalking.image = UIImage(named: "completion")
            self.ibLabelStep.textColor = color
            self.ibLabelPoint.text = "\(self.mPoint)" + "P"
            self.ibProgressView.progressTintColor =  UIColor(red:124/255, green: 77/255, blue: 209/255, alpha: 1.0)
            
        }else {
            color = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1.0)
            button.setTitleColor(UIColor(red: 184/255, green: 184/255, blue: 184/255, alpha: 1.0), for:.normal )
            
            self.ibViewSecond.borderColor = .none
            self.ibViewSecond.borderWidth = 0
            self.ibImageViewWalking.image = UIImage(named: "walking")
            self.ibLabelStep.textColor = UIColor(red:57/255, green: 92/255, blue: 145/255, alpha: 1.0)
            self.ibProgressView.progressTintColor =  UIColor(red:57/255, green: 92/255, blue: 145/255, alpha: 1.0)
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: button.frame.width, height: button.frame.height)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if selected {
            button.setBackgroundImage(image, for: .normal)
            button.isUserInteractionEnabled = true
        }else {
            button.setBackgroundImage(image, for: .normal)
            button.isUserInteractionEnabled = false
        }
        
    }
    
    @IBAction func onTappedClose(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true, animatedType: .down, completion: {
            
        })
    }
    
    @IBAction func onTappedConfirm(_ sender: UIButton) {
        self.ibViewPopUp.isHidden = true
    }
    
    private func setUpEmitterLayer() {
        // layer에 뿌려질 셀
        emitterLayer.emitterCells = [emojiEmiterCell]
    }
    
    private var emojiEmiterCell: CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "imgCoin2")?.cgImage
        
        //얼마나 유지될거냐 (number of seconds an object lives) 이거 짧게 주면 중간에 사라질수도
        cell.lifetime = 3
        //1초에 몇개 생성할거냐. (number of objects created per second)
        cell.birthRate = 100
        
        //크기
        cell.scale = 0.15
        //particle 마다 달라질 수 있는 scale 의 범위
        cell.scaleRange = 0.05
        
        //얼마나 빠른 속도로 회전할것인가. 0이면 회전 효과 없음
        cell.spin = 5
        //spin 범위
        cell.spinRange = 10
        
        // particle 이 방출되는 각도. 따라서 0 이면 linear 하게 방출됨.
        // 2pi = 360 도 = particle이 모든 방향으로 분산 됨.
        cell.emissionRange = CGFloat.pi * 2
        
        // 수치가 높을 수록 particle 이 빠르게, 더 멀리 방출되는 효과.
        // yAcceleration에 의해 영향 받음
        cell.velocity = 700
        //velocity 값의 범위를 뜻함.
        // 만약 기본 velocity가 700이고, velocityRange 가 50 이면,
        // 각 particle은 650-750 사이의 velocity 값을 갖게 됨
        cell.velocityRange = 50
        // gravity 효과.
        // 양수면 중력이 적용되는 것처럼 보이고, 음수면 중력이 없어져서 날아가는 것 처럼 보임.
        // velocity 와 yAcceleration의 조합이 distance 를 결정
        cell.yAcceleration = 1200
        
        return cell
    }
    
    private func setUpTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.ibViewPopUp.addGestureRecognizer(tap)
        self.ibViewPopUp.isUserInteractionEnabled = true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let x = sender.location(in: view).x
        let y = sender.location(in: view).y
        
        //방출 point
        emitterLayer.emitterPosition = CGPoint(x: x, y: y)
        
        //cell 의 birth rate와 곱해져서 총 birth rate 가 정해짐
        emitterLayer.birthRate = 1
        
        //birthRate를 0을 설정해주지 않으면 시간동안 계속 cell을 방출함.
        // 한번 방출하고 끝내는것 처럼 보이게 엄청 짧게 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            //birth rate 가 0이 되면 더 이상 값을 방출하지 않는 것처럼 보임
            self?.emitterLayer.birthRate = 0
        }
        // 레이어 얹어주면 방출 시작되는 것 보임.
        // 신기한건 클릭할때마다 addSublayer가 불리니까 layer가 계속 쌓일거 같은데 count 로 찍어보면 계속 1임
        self.ibViewPopUp.layer.addSublayer(emitterLayer)
        
    }
    
    func showCoins()
    {
        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY - 100
        
        //방출 point
        emitterLayer.emitterPosition = CGPoint(x: midX, y: midY)
        
        //cell 의 birth rate와 곱해져서 총 birth rate 가 정해짐
        emitterLayer.birthRate = 1
        
        //birthRate를 0을 설정해주지 않으면 시간동안 계속 cell을 방출함.
        // 한번 방출하고 끝내는것 처럼 보이게 엄청 짧게 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            //birth rate 가 0이 되면 더 이상 값을 방출하지 않는 것처럼 보임
            self?.emitterLayer.birthRate = 0
        }
        // 레이어 얹어주면 방출 시작되는 것 보임.
        // 신기한건 클릭할때마다 addSublayer가 불리니까 layer가 계속 쌓일거 같은데 count 로 찍어보면 계속 1임
        self.ibViewPopUp.layer.addSublayer(emitterLayer)
        
    }
    
    
    @IBAction func onTappedRank(_ sender: UIButton) {
        
        self.mStpesInfo.removeAll()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let date = formatter.string(from: Date(timeIntervalSince1970: Date().timeIntervalSince1970))
        
        var data = [String:Any]()
        data["date"] = date
        data["steps"] = self.mPeometerCount
        self.mStpesInfo.append(data)
        
        self.sendWeekData(data: self.mStpesInfo)
        self.view.setDisplayWebView(WebPageConstants.URL_PEDO_RANK, modalPresent: true, titleBarType: 2)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}




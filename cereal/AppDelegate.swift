//
//  AppDelegate.swift
//  cereal
//
//  Created by DaeHoon Chung on 2023/03/27.
//

import UIKit
import Firebase
import Fabric
import FirebaseMessaging
import UserNotifications
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    /// 기본 베이스 모델 설정 입니다.
    var viewModel : BaseViewModel = BaseViewModel()
    
    
    /**
     앱 최초 실행 진입 입니다.
     - Date : 2023.04.06
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// 시큐온 키패드 HotFix (23.04.10)
        /// 이전 프레임워크를 제거하고, 전달받은 프레임워크로 교체 이후, 아래 코드를 호출합니다.
        (XKConfigure.sharedInstance()! as AnyObject).setTlsCoinfgWithModule(TLS_MODULE_EXTERNAL_0, version: TLS_VERSION_1_2)
        /// Fabric Crashlystics (크래시 리포트) 설정 합니다.
        Fabric.sharedSDK().debug = true
        /// FirebaseApp (FCM) 설정관련 연결 입니다.
        FirebaseApp.configure()
        /// 키체인 사용여부를 체크 합니다.
        self.viewModel.setKeyChainEnabled()
        /// 탈옥 단말 체크 합니다.
        self.viewModel.setSecureCheck()
        /// FCM PUSH 정보를 받을 델리게이트 메서드를 연결 합니다.
        self.viewModel.setFcmRegister( appDelegate: self )
        
        /// 외부 에서 데이터를 받아서 실행되는 경우 입니다.
        if let launchOptions = launchOptions
        {
            /// FCM PUSH 선택으로 앱 실행된 경우 입니다.
            if let remoteNotification = launchOptions[.remoteNotification] as?  [AnyHashable : Any]
            {
                Slog("DID PUSH  : \(remoteNotification)",category: .apns )
                if let startUrl = remoteNotification["url"] as? String {
                    Slog("DID PUSH URL : \(startUrl)",category: .apns )
                    /// PUSH 관련 정보 URL 을 받아 앱 메인에서 디스플레이 하도록 합니다.
                    BaseViewModel.shared.pushUrl = startUrl
                }
            }
            /// 외부에서 Link 정보를 받아 앱 실행 되는 경우 입니다. ( cereal://movepage?url=URL )
            else if let url = launchOptions[.url] as? URL
            {
                Slog("DID DEEPLINK : \(url)",category: .deeplink )
                /// Deeplink 접근할 URL 정보를 요청 합니다.
                self.viewModel.getDeepLink(deelLinkUrl: url).sink { deeplink in
                    Slog("DID DEEPLINK URL : \(deeplink)",category: .deeplink )
                    /// DeepLink 접근할.URL 정보를 받습니다.
                    BaseViewModel.shared.deepLinkUrl = NC.S(deeplink)
                }.store(in: &self.viewModel.cancellableSet)
            }
        }
        return true
    }

    
    /**
     앱 실행중 딥링크 진입 입니다.
     - Description
        - cereal://movepage?url=URL정보로 약속합니다.
     - Date : 2023.04.06
     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Slog("OPEN DEEPLINK : \(url)",category: .deeplink )
        /// Deeplink 접근할 URL 정보를 요청 합니다.
        self.viewModel.getDeepLink(deelLinkUrl: url).sink { deeplink in
            Slog("OPEN DEEPLINK URL : \(deeplink)",category: .deeplink )
            /// DeepLink 접근할.URL 정보를 받습니다.
            BaseViewModel.shared.deepLinkUrl = NC.S(deeplink)
        }.store(in: &self.viewModel.cancellableSet)
        return true
    }
    
    
    /**
     APNS Device Token 정보를 받습니다.
     - Date : 2023.04.06
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error
            {
                Slog("Error fetching FCM registration token: \(error)", category: .apns )
            }
            else if let token = token
            {
                Slog("FCM registration token: \(token)", category: .apns )
                if let custItem = SharedDefaults.getKeyChainCustItem()
                {
                    custItem.fcm_token = token
                    SharedDefaults.setKeyChainCustItem(custItem)
                }
            }
        }
    }
}


// MARK: - APNS 연동 데이터 처리 입니다.
extension AppDelegate : UNUserNotificationCenterDelegate
{
    /**
     PUSH 적용할 설정 정보를 추가 합니다.
     - Date : 2023.04.06
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert,.sound,.badge])
    }
    
    
    /**
     실시간 PUSH 정보를 처리 합니다.
     - Date : 2023.04.06
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let application = UIApplication.shared
        let userInfo = response.notification.request.content.userInfo
        Slog("OPEN PUSH  : \(userInfo)",category: .apns )
        /// 앱이 켜져있는 상태에서 푸쉬 알림을 눌렀을 때 입니다.
        if application.applicationState == .active
        {
            if let url = userInfo["url"] as? String {
                Slog("OPEN PUSH URL : \(url)",category: .apns )
                BaseViewModel.shared.pushUrl = url
            }
        }
        else
        {
            /// PUSH 데이터를 넘깁니다.
            if let url = userInfo["url"] as? String {
                Slog("OPEN PUSH URL : \(url)",category: .apns )
                BaseViewModel.shared.pushUrl = url
            }
        }
        completionHandler()
    }
}


// MARK: - MessagingDelegate ( FCM TOKEN )
extension AppDelegate : MessagingDelegate
{
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        /// 로그인 정보가 있는지를 체크합니다.
        if let login = BaseViewModel.loginResponse
        {
            /// 현 로그인 유지 상태인지를 체크 합니다.
            if let islogin = login.islogin,
               islogin == true
            {
                if let custItem = SharedDefaults.getKeyChainCustItem()
                {
                    Slog("MessagingDelegate token: \(fcmToken!)", category: .apns )
                    /// FCM 토큰 정보를 신규로 추가 합니다.
                    custItem.fcm_token = fcmToken
                    SharedDefaults.setKeyChainCustItem(custItem)
                    /// FCM PUSH Token 정보를 업로드 합니다.
                    let _ = self.viewModel.setFcmTokenRegister()
                }
            }
        }
    }
}

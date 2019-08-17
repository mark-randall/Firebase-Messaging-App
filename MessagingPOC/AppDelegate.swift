//
//  AppDelegate.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseUI
import GoogleSignIn
import UserNotifications
import Fabric
import Crashlytics

// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
    
    private var rootCoordinator: RootCoordinator?
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        guard
            let firebasePlistFileName = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let firebaseOptions = FirebaseOptions(contentsOfFile: firebasePlistFileName)
            else {
                preconditionFailure()
        }
        FirebaseApp.configure(options: firebaseOptions)
        
        // Configure crash reporting
        Fabric.with([Crashlytics.self])
        
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // Configure APNs
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        try? Auth.auth().signOut()
        rootCoordinator = RootCoordinator(flow: .root, presentingViewController: window?.rootViewController)
        rootCoordinator?.start()

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        #if DEBUG
        print("FCM registration token: \(fcmToken)")
        #endif
        
        //userRepository?.updatePushToken(to: fcmToken)
    }
}

// MARK: - UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
      
        return false
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
//        if let connectionRequest = NetworkingPendingConnectionLink(dictionary: notification.request.content.userInfo) {
//            //deepLinkManager?.handleConnectionRequestNotification(connectionRequest)
//            completionHandler([])
//        } else {
//            completionHandler([.alert, .badge, .sound])
//        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        //deepLinkManager?.handlePushNotification(with: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //deepLinkManager?.handlePushNotification(with: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


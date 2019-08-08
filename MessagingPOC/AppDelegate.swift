//
//  AppDelegate.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import UIKit
import Firebase
import FirebaseMessaging
import FirebaseUI
import GoogleSignIn
import UserNotifications
import Fabric
import Crashlytics


// MARK: - Firestore

extension Firestore {
    
    static let defaultStore: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }()
}


// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
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
        
        // Configure Firebase Auth UI
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.providers = [FUIGoogleAuth(), FUIEmailAuth()]
        
        // Configure crash reporting
        Fabric.with([Crashlytics.self])
        
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // Configure APNs
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        return true
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

// MARK: - FUIAuthDelegate

/// Used to customize the UI for Firebase Auth UI
extension AppDelegate: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        
        // UserRepository handles success by listening for FirebaseAuth addStateDidChangeListener
        // Current assumption is that this error doesn't need to be presented to the user
        if let error = error {
            
            let ns = error as NSError
            // If it's just the generic error that gets thrown when the login modal is dismissed
            // without a login, we will ignore it.
            guard ns.code != 1 else {
                //AnalyticsManager.shared.logCustomEvent(event: AnalyticsManager.SignInEvent.signFlowCompleted(result: .canceled))
                return
            }
            
            //AnalyticsManager.shared.logCustomEvent(event: AnalyticsManager.SignInEvent.signFlowCompleted(result: .failed))
            //window?.rootViewController?.getVisibleViewController().presentError(error)
            return
        }
        
        //AnalyticsManager.shared.logCustomEvent(event: AnalyticsManager.SignInEvent.signFlowCompleted(result: .successful))
        //NotificationCenter.default.post(name: GlobalNotification.AuthWillComplete.name, object: self, userInfo: [:])
    }
}



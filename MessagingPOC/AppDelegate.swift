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
    
    func configForFirebase() -> ServiceLocator {
        return FirebaseServiceLocator()
    }
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let serviceLocator = configForFirebase()
        
        // Configure APN
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        // Prompt for APNs
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: { (granted, error) in
        })
        
        rootCoordinator = RootCoordinator(flow: .root, presentingViewController: window!.rootViewController!, serviceLocator: serviceLocator)
        do {
            try rootCoordinator?.start(topViewController: window!.rootViewController!)
        } catch {
            print(error)
        }

        return true
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
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


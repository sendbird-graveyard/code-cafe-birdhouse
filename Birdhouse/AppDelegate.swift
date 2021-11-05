//
//  AppDelegate.swift
//  Birdhouse
//
//  Created by Minhyuk Kim on 2021/10/14.
//

import UIKit
import SendBirdUIKit
import SendBirdCalls

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: - Configure Application Id
        let appId: String = "ADD6749C-9165-48E4-ABEB-BF58F7C399DF"
        <#InitSendbird#>
        
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

//
//  AppDelegate.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/24/15.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        self.window?.rootViewController = viewController
        
        self.window?.makeKeyAndVisible()
        return true
    }
}

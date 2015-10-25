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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let viewController = ViewController()
        self.window?.rootViewController = viewController
        
        self.window?.makeKeyAndVisible()
        return true
    }
}

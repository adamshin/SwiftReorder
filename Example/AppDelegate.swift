//
//  AppDelegate.swift
//  SwiftReorder
//
//  Created by Adam Shin on 5/13/16.
//  Copyright © 2016 Adam Shin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        
        let navController = UINavigationController()
        let viewController = RootViewController()
        navController.pushViewController(viewController, animated: false)
        window?.rootViewController = navController
        
        return true
    }

}

//
//  AppDelegate.swift
//  TookKitDemo
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit
import ToolKit


class FloatingDevKitViewController : UIViewController {
    
}

class DevKitWindow : UIWindow {

    //    @available(*,unavailable,message: "Please don't use it by your own")
    override init(frame: CGRect) {
        
        let preferredFrame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 65)
        super.init(frame: preferredFrame)
        
        rootViewController = UIViewController()
        rootViewController?.view.frame = self.bounds
        rootViewController?.view.backgroundColor = UIColor.green.withAlphaComponent(0.5)
    }
    
//    @available(*,unavailable,message: "Please don't use it by your own")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    enum DockPosition {
        case Top(offset:CGPoint), Right(offset:CGPoint), Bottom(offset:CGPoint), Left(offset:CGPoint)
    }
    
    func dock(to position: DockPosition) {
        switch position {
        case .Top(let offset):
            self.frame.origin.x = offset.x
            self.frame.origin.y = offset.y
        case .Bottom(let offset):
            self.frame.origin.x = offset.x
            self.frame.origin.y = UIScreen.main.bounds.height - self.bounds.height + offset.y
        case .Left(let offset):
            self.frame.origin.x = offset.x
            self.frame.origin.y = UIApplication.shared.statusBarFrame.height + offset.y
        case .Right(let offset):
            self.frame.origin.x = UIScreen.main.bounds.width - self.bounds.width + offset.x
            self.frame.origin.y = UIApplication.shared.statusBarFrame.height + offset.y
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var devkitWindow : DevKitWindow?
    var window: UIWindow?
    
    func activateDevKitWindow() {
        devkitWindow = DevKitWindow(frame: UIScreen.main.bounds)
        devkitWindow?.windowLevel = UIWindowLevelStatusBar
        devkitWindow?.makeKeyAndVisible()
        devkitWindow?.dock(to: DevKitWindow.DockPosition.Bottom(offset: CGPoint.init(x: 0, y: -45)))
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


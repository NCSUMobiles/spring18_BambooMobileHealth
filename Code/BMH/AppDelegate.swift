//
//  AppDelegate.swift
//  BMH
//
//  Created by Kalpesh Padia on 3/27/18.
//  Copyright © 2018 Bamboo Mobile Health. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        

        // configure firebase
        FirebaseApp.configure()
        
        if let userId = LoginHelper.getLogedInUser(){
            var tabBarController = setViewControllerOnWindowFromId(storyBoardId: "tabBarController")
            AppDelegate.initialTabConterllerSetup(rootTabBarController: tabBarController)
        }else{
            setViewControllerOnWindowFromId(storyBoardId: "loginViewController")
        }
        
        
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

    func setViewControllerOnWindowFromId(storyBoardId : String) -> UIViewController{
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: storyBoardId) as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        return initialViewController
    }
    
    static func initialTabConterllerSetup( rootTabBarController : UIViewController){
        // customize the color of the page control
        let violetColor = UIColor.init(red: 62/255.0, green: 100/255.0, blue: 251/255.0, alpha: 1)
        let purpleColor = UIColor.init(red: 178/255.0, green: 58/255.0, blue: 251/255.0, alpha: 1)
    
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = violetColor
        pageControl.currentPageIndicatorTintColor = purpleColor
        pageControl.backgroundColor = UIColor.clear
    
        // set the custom images for selected item
        let tabBarController = rootTabBarController as! UITabBarController
        let tabBar = tabBarController.tabBar
        tabBar.items![0].selectedImage = UIImage(named: "progress")?.withRenderingMode(.alwaysOriginal)
        tabBar.items![1].selectedImage = UIImage(named: "history")?.withRenderingMode(.alwaysOriginal)
        tabBar.items![2].selectedImage = UIImage(named: "record")?.withRenderingMode(.alwaysOriginal)
        tabBar.items![3].selectedImage = UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal)
    
        // set the tint of text
        tabBar.tintColor = violetColor
    }

}


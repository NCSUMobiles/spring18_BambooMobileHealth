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
    
    var activities : [ActEx]!
    var exercises : [ActEx]!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // configure firebase
        FirebaseApp.configure()
	
        // load activities and exercises from JSON
        loadFromJSON()
        
        // also update goal values by reading from DB if available
        updateFromDB()
        
        if LoginHelper.getLogedInUser() != nil{
            let tabBarController = setViewControllerOnWindowFromId(storyBoardId: "tabBarController")
            initialTabConterllerSetup(rootTabBarController: tabBarController)
        }else{
            _ = setViewControllerOnWindowFromId(storyBoardId: "loginViewController")
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
    
    func loadFromJSON() {
        if let path = Bundle.main.path(forResource: "ActExList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                
                activities = []
                let activitiesArray = parsedData["activities"] as! [Any]
                for case let activity as Dictionary<String, String> in activitiesArray {
                    var actEx = ActEx()
                    actEx.imageName = activity["image"]!
                    actEx.name = activity["name"]!
                    actEx.goalUnits = activity["units"]!
                    actEx.goalTime = activity["per"]!
                    
                    // some dummy value -> should be updated from DB
                    actEx.goalValue = Int(arc4random_uniform(2000)) + 1
                    
                    activities.append(actEx)
                }
                
                exercises = []
                let exercisesArray = parsedData["exercises"] as! [Any]
                for case let exercise as Dictionary<String, String> in exercisesArray {
                    var actEx = ActEx()
                    actEx.imageName = exercise["image"]!
                    actEx.name = exercise["name"]!
                    actEx.goalUnits = exercise["units"]!
                    actEx.goalTime = exercise["per"]!
                    
                    // some dummy value -> should be updated from DB
                    actEx.goalValue = Int(arc4random_uniform(30))  + 1
                    
                    exercises.append(actEx)
                }
                
                if let activityExerciseGoals = SettingsHelper.getActivityExerciseGoalValues() as? [[String:Int]]{
                    for var i in 0..<activities.count{
                        let element  = activities[i]
                        if let val = activityExerciseGoals[0][element.name]{
                            activities[i].goalValue = val
                        }
                    }
                    
                    for var i in 0..<exercises.count{
                        let element = exercises[i]
                        if let val = activityExerciseGoals[1][element.name]{
                            exercises[i].goalValue = val
                        }
                    }
                    
                }
                
            } catch {
                // handle error
            }
        }
    }
    
    func updateFromDB() {
    }
    
    func setViewControllerOnWindowFromId(storyBoardId : String) -> UIViewController{
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: storyBoardId) as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        return initialViewController
    }
    
    func initialTabConterllerSetup( rootTabBarController : UIViewController){
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


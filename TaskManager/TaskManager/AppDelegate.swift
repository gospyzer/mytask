//
//  AppDelegate.swift
//  TaskManager
//
//  Created by Hima on 17/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit
import IQKeyboardManager
import SVProgressHUD
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var keyPurchased: String = "keyPurchased"
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var navigationController: UINavigationController? // Navigation controller
    static var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate! as! AppDelegate
    }

    var isPurchased: Bool = false

    /// ADMob Interstitial
    var interstitial: GADInterstitial!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let ispurchased = fetchUserDefault(Key: keyPurchased)
        isPurchased = ispurchased

        if !isPurchased {
            /// Start GAD
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            UserDefaults.standard.set(0, forKey: "fullAd")
            UserDefaults.standard.synchronize()
        }

        Initialization()
        IQKeyboardManager.shared().isEnabled = true

        

        
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            didAllow, _ in
            if !didAllow {
                print("User has declined notifications")
            }
        }

        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let initialViewController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarID") as! UITabBarController
        for tabBarItem in initialViewController.tabBar.items! {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        initialViewController.selectedIndex = 0
        navigationController = UINavigationController(rootViewController: initialViewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func checkFullAd() {
        let ispurchased = fetchUserDefault(Key: keyPurchased)
        isPurchased = ispurchased
        if !isPurchased {
            if let isFullAd: Int = UserDefaults.standard.integer(forKey: "fullAd") {
                if isFullAd == 2 {
                    setUpInterstial()
                    UserDefaults.standard.set(0, forKey: "fullAd")
                    UserDefaults.standard.synchronize()
                }
                else{
                    UserDefaults.standard.set(isFullAd+1, forKey: "fullAd")
                    UserDefaults.standard.synchronize()
                }
            }
            else{
                UserDefaults.standard.set(1, forKey: "fullAd")
                UserDefaults.standard.synchronize()
            }
        }
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
    
    //MARK: - Initialization
       
   func Initialization() {
       
       // Create DB and tables
       DBManager.sharedInstance.createDB()
       DBManager.sharedInstance.createTable()
    
        copyHTMLFileToDocDir(fileExtension: ".html")
//           //Get passcode
//           strPasscode = UserDefaults.standard.string(forKey: "passcode")
//
//           //
//           isTimeAppOpen = UserDefaults.standard.bool(forKey: "firsttime")
   }
    
    func copyHTMLFileToDocDir(fileExtension: String) {
        if let resPath = DBundlePathToTaskTableHTMLTemplate {
            do {
                let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
                for fileName in filteredFiles {
                    if let documentsURL = documentsURL {
                        let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                        let destURL = documentsURL.appendingPathComponent(fileName)
                        do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch { }
                    }
                }
            } catch { }
        }
        
        if let resPath = DBundlePathToTaskTablePDFHTMLTemplate {
            do {
                let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
                for fileName in filteredFiles {
                    if let documentsURL = documentsURL {
                        let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                        let destURL = documentsURL.appendingPathComponent(fileName)
                        do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch { }
                    }
                }
            } catch { }
        }
    }
    
    func getDocDir() -> String {
           return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
       }

    // MARK: - Save value to userdefault

    func saveUserDefault(value: Any, Key: String) {
        UserDefaults.standard.set(value, forKey: Key)
        isPurchased = value as! Bool
    }

    func fetchUserDefault(Key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: Key) ?? false
    }

    // Mark: - Full Ad
    func setUpInterstial() {
        interstitial = createAndLoadInterstitial()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            //self.loadFullScreenAd()
        }
    }

    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial1 = GADInterstitial(adUnitID: fullAdID)
        interstitial1.delegate = self
        interstitial1.load(GADRequest())
        return interstitial1
    }
}

extension AppDelegate: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
        if interstitial.isReady {
            ad.present(fromRootViewController: AppDelegate.sharedInstance.window!.rootViewController!)
        }
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
}


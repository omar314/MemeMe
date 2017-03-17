//
//  AppDelegate.swift
//  MemeMe
//
//  Created by Omar Gonzalez on 3/13/17.
//  Copyright © 2017 Omar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    customUI()
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
  }

  func applicationWillTerminate(_ application: UIApplication) {
  }

  private func customUI() {
    
    let matteBlack = UIColor(white: 0.1, alpha: 1.0)
    
    UINavigationBar.appearance().barTintColor = .white
    let titleDict: NSDictionary = [
      NSForegroundColorAttributeName: matteBlack,
      NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)
    ]
    UINavigationBar.appearance().titleTextAttributes = titleDict as? [String: AnyObject]
    UINavigationBar.appearance().tintColor = matteBlack

    
    UIToolbar.appearance().tintColor = matteBlack
    UIToolbar.appearance().barTintColor = .white
    
  }
}


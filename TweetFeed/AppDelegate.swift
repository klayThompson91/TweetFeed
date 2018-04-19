//
//  AppDelegate.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/13/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginViewControllerDelegate {
    

    var window: UIWindow?
    var loginViewController = LoginViewController()
    var tabBarController = UITabBarController()
    
    var tweetFeedNavigationController = UINavigationController()
    var settingsNavigationController = UINavigationController()
    var searchNavigationController = UINavigationController()
    
    var tweetFeedViewController = TweetFeedViewController()
    var settingsViewController = SettingsViewController()
    var userSearchViewController = UserSearchViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserSignOut(_:)), name: NotificationConstants.userSignedOut, object: nil)
        setupContainerTabBarAndNavigationControllers()
        loginViewController.delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = (TweetFeedUserCredentials().accessToken() != "") ? tabBarController : loginViewController
        window?.makeKeyAndVisible()
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String else { return false }
        guard sourceApplication == "com.apple.SafariViewService" else { return false }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
        let authenticationModel = AuthenticationCredentialsModel(urlComponents.query ?? "")
        NotificationCenter.default.post(name: NotificationConstants.twitterAuthRedirect, object: nil, userInfo: [OAuthConstants.tokenKey : authenticationModel])
        return true
    }
    
    func loginViewControllerAuthenticatedUser() {
        if !(window?.rootViewController is UITabBarController) {
            tabBarController.selectedIndex = 0
            window?.rootViewController = tabBarController
        }
    }

    @objc private func handleUserSignOut(_ notification: Notification) {
        if !(window?.rootViewController is LoginViewController) {
            window?.rootViewController = loginViewController
            loginViewController.resetSession()
        }
    }
    
    private func setupContainerTabBarAndNavigationControllers() {
        tweetFeedNavigationController = UINavigationController(rootViewController: tweetFeedViewController)
        settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        searchNavigationController = UINavigationController(rootViewController: userSearchViewController)
        tabBarController.viewControllers = [tweetFeedNavigationController, searchNavigationController, settingsNavigationController]
        TweetFeedStyle.styleTabBar(tabBarController.tabBar)
        settingsViewController.tabBarItem = TabBarItemFactory.makeTabBarItem(title: "", selectedImage: TweetFeedImages.settingsTabBarSelectedImage, unselectedImage: TweetFeedImages.settingsTabBarUnselectedImage)
        tweetFeedViewController.tabBarItem = TabBarItemFactory.makeTabBarItem(title: "", selectedImage: TweetFeedImages.feedTabBarSelectedImage, unselectedImage: TweetFeedImages.feedTabBarUnselectedImage)
        userSearchViewController.tabBarItem = TabBarItemFactory.makeTabBarItem(title: "", selectedImage: TweetFeedImages.peopleSearchTabBarSelectedImage, unselectedImage: TweetFeedImages.peopleSearchTabBarUnselectedImage)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


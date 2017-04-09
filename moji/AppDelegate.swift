//
//  AppDelegate.swift
//  moji
//
//  Created by Macbook on 1/21/17.
//  Copyright © 2017 Digitally Savvy. All rights reserved.
//

import UIKit
import CoreData
import KudanAR

//var VideoPreviewURL : NSURL?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		print("checking API KEY")
		// set KudanAR API Key
		let apiKey : ARAPIKey = ARAPIKey.sharedInstance()
		apiKey.setAPIKey("G+1QjdR1ZUMdvXdF6tMJfYqhMWE0RzOs5h0V+SPIBLjMepHxD/jEtEkatP0NDloqNm3ImRRzUU+sL6/nkU/hsehq8Cmsc8RShxsFg4Rr9kqGuM2nxeWO9sf8jzls/eYqzTagJg1WLi55STuT8WXgZCucxritCcjOqyyTY2mEl3nI/DxkXJs8PeEWDQOsyFKhiKKobr6hno9gC+2ehgSe+o/qnYeB0e1oncmt7HSRZ6sctkc3Yr9UpIbT66yEr9ENq1evT6HAr7Y+aUE/U8hI+6KR9wQmH9vSPWPmfs0hDs8Z+eJ7lbU+3b3FThM6CNuUFX4DtuZzY6v3nUc+Fgsgn3tex5Rab0zNRW17k8+CMCsUc0eSKTQHGq18HcqI1/5/ps73eqhtwiQn/XDoCVllE9mLMahZihG5ULrI3Yamavn9IudkMZRMQH5D2tsvFBU420vBzOkPgjKLxGQ45IXtwDosb/Sc1ZHfUBUm2d50ZPk4EHSNMrLlXkfHakQu+r7iSVZjEDVJ7et8FcLS78Rjq+PS1Pj2sEBGBqIcw24XVbOE+v/+zGMe7MQM0pjbrzFX9q/pHPeZrSc047MkhWuSTDpJICi1vJb8pvKdp8645EIZo/ygWwM41WO9a/s8ECLVdtncWOoSmkdMg87ZIeFHyp0T+tySv1qUOODuahWqn5o=")
		// set Flurry Session
		Flurry.setSessionReportsOnCloseEnabled(true); //  send session data when the user exits the app and when the user starts the app.
		Flurry.setSessionReportsOnPauseEnabled(true); //  send session data when the user pauses the app and when a user starts the app.
		let UUIDValue = UIDevice.current.identifierForVendor!.uuidString // unique id for user
		Flurry.setUserID(UUIDValue); // for tracking Users by their ID
		Flurry.startSession("S4BBF8RKB4KB65JFT6RN");
		
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
		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}

	// MARK: - Core Data stack

	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "moji")
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error as NSError? {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	             
	            /*
	             Typical reasons for an error here include:
	             * The parent directory does not exist, cannot be created, or disallows writing.
	             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	             * The device is out of space.
	             * The store could not be migrated to the current model version.
	             Check the error message to determine what the actual problem was.
	             */
	            fatalError("Unresolved error \(error), \(error.userInfo)")
	        }
	    })
	    return container
	}()

	// MARK: - Core Data Saving support

	func saveContext () {
	    let context = persistentContainer.viewContext
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            let nserror = error as NSError
	            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	        }
	    }
	}

}


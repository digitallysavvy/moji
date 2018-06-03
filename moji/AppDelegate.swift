//
//  AppDelegate.swift
//  moji
//
//  Created by Hermes Frangoudis on 1/21/17.
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
        apiKey.setAPIKey("nbR1lCHdPeXXVFx4ZXuQXOmzey7JNoO9UzESTq/ti09CCW9eRUoFiSiVEUiT6LLoVEPzsm8X7TOgm3AQ5Sv+z+6FHI+c1pCaGgWvasOTvnIs9Xe1LjEEBOZY4CEIHGBuTQnXXFi+tkOtwLGUs8//1IqOseL1UtlWuPuZnCKOFq09RXK7ZnUna3FkKD5HLzLktMCQUlDDE+lTQcfHioBfaAPnhyl2xKhznX1BmZKIt3cWP3x5WwmAKVHXjGN4OZnQV+ckBGhbUGxTNXF07/aiiSygoUIKuv03R5zD/KWrxePDNxDpw5lLKusE9FVUPObPF4dWLHnAdu1j2CCScb2HsNFta8AewF20jPyMUESEnw6qF+qCYEh1J2VARQB/0kQmw9o0QNtNrlHKBsm1Xh4dI4zDhJbV55HjFiA4Pt5ImU8M0aJji5CCH/rZ6+iB3bIi4T7czn5H/NA1+gTAIl9vgwb19gf4b9Irjzpqvotrea+6aPBOx59eEc/E5BKaLIChWP8KtOXEfiR1P8ycjBuUmjT+uJmcj/9FrCXnBwR/DOL4V5Cu7ZOLYPIdr4DZJv/H4sVb/k68TZqHwoOGzPw1RyPBfZttZciVxnbDl0gmXlB2qVwEIG4TFGPV6+5njnL//giVRZihu20sAfxIC++zVsoxJtUj6JWlLC9VMsldp+E=")
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


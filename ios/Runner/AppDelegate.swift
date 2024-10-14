import UIKit
import Flutter

import awesome_notifications
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Awesome Notifications setup
    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    // Setup background fetch
    if #available(iOS 13.0, *) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.tushar_db.dailyNotification", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGAppRefreshTask)
        }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @available(iOS 13.0, *)
  func scheduleBackgroundTask() {
    let request = BGAppRefreshTaskRequest(identifier: "com.example.tushar_db.dailyNotification")
    request.earliestBeginDate = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())
    
    do {
      try BGTaskScheduler.shared.submit(request)
      print("Background task scheduled successfully")
    } catch {
      print("Could not schedule background task: \(error)")
    }
  }
  
  @available(iOS 13.0, *)
  func handleBackgroundTask(task: BGAppRefreshTask) {
    scheduleBackgroundTask() // Reschedule the task for the next day
    
    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }
    
    // Trigger the daily notification
    DispatchQueue.main.async {
      if let flutterViewController = self.window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(
          name: "com.example.tushar_db/background_fetch",
          binaryMessenger: flutterViewController.binaryMessenger)
        channel.invokeMethod("triggerDailyNotification", arguments: nil)
      }
    }
    
    task.setTaskCompleted(success: true)
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    if #available(iOS 13.0, *) {
      scheduleBackgroundTask()
    }
  }
}
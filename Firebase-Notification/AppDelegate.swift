//
//  AppDelegate.swift
//  Firebase-Notification
//
//  Created by rico on 12.12.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,  // Uygulama ilk acildiginda calisan kisim.
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure() // -> Firebase baslatiliyor
        Messaging.messaging().delegate = self
        registerForPushNotifications(application)
        
        return true
    }
    
    // MARK: - Bildirim Izinleri ve Kurulum
    func registerForPushNotifications(_ application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("✅ Izin verildi.")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications() // APNs servisine kayit oluyoruz
                }
            } else {
                print("❌ Kullanici izin vermedi. :(")
            }
            
            if let error = error {
                print("Yetkilendirme hatasi: \(error.localizedDescription)")
            }
        }
        UNUserNotificationCenter.current().delegate = self // Uygulama acikken bildirimleri yonetmek icin delegate atamasi
    }
    
    // MARK: - APNs Token Yonetimi
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // APNs token'i manuel olarak Firebase Messaging servisine tanimliyoruz.
        // Bu islem swizzling hatalarini ve token eslesmeme sorununu tamamiyla cozen k'simdr.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ APNs Kayit Hatasi: \(error.localizedDescription)")
    }
}

// MARK: -
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // Firebase Token (FCM Token) olustugunda veya yenilendiginde burasi calisir
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("Uyari: FCM Token = nil")
            return
        }
        
        print("ℹ️ FCM Token Olustu: \(token)")
        
        // Token garantilendikten sonra 'all_users' topic'ine abone oluyoruz
        Messaging.messaging().subscribe(toTopic: "all_users") { error in
            if let error = error {
                print("❌ Abonelik hatasi: \(error.localizedDescription)")
            } else {
                print("✅ BASARILI: 'all_users' topic'ine abone olundu!")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list]) // Uygulama acik olsa bile banner goster ve ses cal
    }
}

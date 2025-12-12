//
//  Firebase_NotificationApp.swift
//  Firebase-Notification
//
//  Created by rico on 12.12.2025.
//

import SwiftUI

@main
struct Firebase_NotificationApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // AppDelegate SwiftUI life-cycle baglama.
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

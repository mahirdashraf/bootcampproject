//
//  superduperprojectApp.swift
//  superduperproject
//
//  Created by Ashley Ni on 3/16/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct superduperprojectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var auth = AuthViewModel()
    @StateObject var userVM = UserViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(userVM)
                .onReceive(auth.$user) { user in
                    let uid = user?.uid
                    userVM.setAuthenticatedUserID(uid?.isEmpty == true ? nil : uid)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                userVM.handleAppDidBecomeActive()
            case .background:
                userVM.handleAppDidEnterBackground()
            default:
                break
            }
        }
    }
}

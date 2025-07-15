//
//  ContentView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var locationManager = LocationManager()
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if userManager.currentUser.hasCompletedOnboarding {
                AnyView(MainTabView(
                    userManager: userManager,
                    locationManager: locationManager
                ))
            } else {
                if userManager.isFirstLaunch && !showOnboarding {
                    WelcomeView(showOnboarding: $showOnboarding)
                } else {
                    OnboardingFlow()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

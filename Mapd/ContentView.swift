//
//  ContentView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Group {
            if userManager.user.hasCompletedOnboarding {
                MainTabView(
                    userManager: userManager,
                    locationManager: locationManager
                )
            } else {
                if userManager.isFirstLaunch {
                    WelcomeView(userManager: userManager)
                } else {
                    OnboardingFlow(
                        userManager: userManager,
                        locationManager: locationManager
                    )
                }
            }
        }
        .onAppear {
            userManager.initializeUser()
        }
    }
}

#Preview {
    ContentView()
}

//
//  MainTabView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var locationManager: LocationManager
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView(
                userManager: userManager,
                locationManager: locationManager
            )
            .tabItem {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                Text("Home")
            }
            .tag(0)
            
            // Search Tab
            SearchView(
                locationManager: locationManager
            )
            .tabItem {
                Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                Text("Search")
            }
            .tag(1)
            
            // Places Tab
            PlacesView(
                userManager: userManager,
                locationManager: locationManager
            )
            .tabItem {
                Image(systemName: selectedTab == 2 ? "location.fill" : "location")
                Text("Places")
            }
            .tag(2)
            
            // Trips Tab
            TripsView(
                userManager: userManager,
                locationManager: locationManager
            )
            .tabItem {
                Image(systemName: selectedTab == 3 ? "airplane.circle.fill" : "airplane")
                Text("Trips")
            }
            .tag(3)
            
            // Profile Tab
            ProfileView(
                userManager: userManager
            )
            .tabItem {
                Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                Text("Profile")
            }
            .tag(4)
        }
        .accentColor(MapdColors.accent)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(MapdColors.cardBackground)
        
        // Selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(MapdColors.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(MapdColors.accent),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Normal item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(MapdColors.mediumGray)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(MapdColors.mediumGray),
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView(
        userManager: UserManager(),
        locationManager: LocationManager()
    )
}
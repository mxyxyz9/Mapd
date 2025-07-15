//
//  ProfileView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import Foundation

struct ProfileView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MapdSpacing.lg) {
                    // Profile Header
                    ProfileHeader(user: userManager.currentUser) {
                        showingEditProfile = true
                    }
                    
                    // Stats Section
                    ProfileStatsSection(user: userManager.currentUser)
                    
                    // Travel Style & Interests
                    TravelPreferencesSection(user: userManager.currentUser)
                    
                    // Recent Activity
                    RecentActivitySection(user: userManager.currentUser)
                    
                    // Settings & Actions
                    ProfileActionsSection {
                        showingSettings = true
                    }
                }
                .padding(.horizontal, MapdSpacing.screenPadding)
                .padding(.bottom, MapdSpacing.xl)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(userManager: userManager)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(userManager: userManager)
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    let user: User
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: MapdSpacing.lg) {
            // Profile Image
            Button(action: onEdit) {
                ZStack {
                    if let profileImage = user.profileImageName {
                        AsyncImage(url: URL(string: profileImage)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(MapdColors.mediumGray)
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(MapdColors.lightGray)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(MapdColors.mediumGray)
                            )
                    }
                    
                    // Edit overlay
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(MapdColors.accent)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                                .offset(x: 5, y: 5)
                        }
                    }
                }
            }
            
            // User Info
            VStack(spacing: MapdSpacing.sm) {
                Text(user.name.isEmpty ? "Traveler" : user.name)
                    .font(MapdTypography.heading1)
                    .foregroundColor(MapdColors.darkText)
                
                if !user.interests.isEmpty {
                    Text(user.interests.map { $0.rawValue }.joined(separator: " • "))
                        .font(MapdTypography.caption)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                }
                
                // Travel Style Badge
                HStack(spacing: MapdSpacing.xs) {
                    Image(systemName: user.travelStyle.icon)
                        .font(.caption)
                        .foregroundColor(user.travelStyle.color)
                    
                    Text(user.travelStyle.rawValue)
                        .font(MapdTypography.small)
                        .foregroundColor(user.travelStyle.color)
                }
                .padding(.horizontal, MapdSpacing.sm)
                .padding(.vertical, MapdSpacing.xs)
                .background(user.travelStyle.color.opacity(0.1))
                .cornerRadius(MapdRadius.button)
            }
        }
    }
}

// MARK: - Profile Stats Section
struct ProfileStatsSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Travel Stats")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: MapdSpacing.md) {
                ProfileStatCard(
                    title: "Places Visited",
                    value: "\(user.visitedPlaces.count)",
                    icon: "location.fill",
                    color: MapdColors.accent
                )
                
                ProfileStatCard(
                    title: "Countries",
                    value: "\(Set(user.visitedPlaces.map { $0.country }).count)",
                    icon: "globe",
                    color: MapdColors.success
                )
                
                ProfileStatCard(
                    title: "Bucket List",
                    value: "\(user.bucketList.count)",
                    icon: "heart.fill",
                    color: MapdColors.warning
                )
                
                ProfileStatCard(
                    title: "Trips Planned",
                    value: "\(user.trips.count)",
                    icon: "airplane",
                    color: MapdColors.error
                )
            }
        }
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        MapdCard {
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: MapdSpacing.xs) {
                    Text(value)
                        .font(MapdTypography.heading1)
                        .foregroundColor(MapdColors.darkText)
                    
                    Text(title)
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(MapdSpacing.md)
        }
    }
}

// MARK: - Travel Preferences Section
struct TravelPreferencesSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Travel Preferences")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            VStack(spacing: MapdSpacing.md) {
                // Travel Style
                PreferenceRow(
                    title: "Travel Style",
                    value: user.travelStyle.rawValue,
                    icon: user.travelStyle.icon,
                    color: user.travelStyle.color
                )
                
                // Interests
                VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                    HStack {
                        Image(systemName: "heart.circle")
                            .foregroundColor(MapdColors.accent)
                        Text("Interests")
                            .font(MapdTypography.bodyBold)
                            .foregroundColor(MapdColors.darkText)
                        Spacer()
                    }
                    
                    if user.interests.isEmpty {
                        Text("No interests selected")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: MapdSpacing.xs) {
                            ForEach(user.interests, id: \.self) { interest in
                                InterestChip(interest: interest)
                            }
                        }
                    }
                }
                .padding(MapdSpacing.md)
                .background(MapdColors.cardBackground)
                .cornerRadius(MapdRadius.card)
            }
        }
    }
}

struct PreferenceRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: MapdSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                Text(title)
                    .font(MapdTypography.bodyBold)
                    .foregroundColor(MapdColors.darkText)
                
                Text(value)
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
            }
            
            Spacer()
        }
        .padding(MapdSpacing.md)
        .background(MapdColors.cardBackground)
        .cornerRadius(MapdRadius.card)
    }
}

struct InterestChip: View {
    let interest: TravelInterest
    
    var body: some View {
        HStack(spacing: MapdSpacing.xs) {
            Image(systemName: interest.icon)
                .font(.caption2)
                .foregroundColor(interest.color)
            
            Text(interest.rawValue)
                .font(MapdTypography.small)
                .foregroundColor(MapdColors.darkText)
        }
        .padding(.horizontal, MapdSpacing.sm)
        .padding(.vertical, MapdSpacing.xs)
        .background(interest.color.opacity(0.1))
        .cornerRadius(MapdRadius.button)
    }
}

// MARK: - Profile Actions Section
struct ProfileActionsSection: View {
    let onSettings: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Settings")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            VStack(spacing: MapdSpacing.sm) {
                ProfileActionRow(
                    title: "Edit Profile",
                    icon: "person.circle",
                    action: { /* Edit profile */ }
                )
                
                ProfileActionRow(
                    title: "Privacy Settings",
                    icon: "lock.circle",
                    action: { /* Privacy settings */ }
                )
                
                ProfileActionRow(
                    title: "Notifications",
                    icon: "bell.circle",
                    action: { /* Notification settings */ }
                )
                
                ProfileActionRow(
                    title: "Export Data",
                    icon: "square.and.arrow.up.circle",
                    action: { /* Export data */ }
                )
                
                ProfileActionRow(
                    title: "Settings",
                    icon: "gear.circle",
                    action: onSettings
                )
            }
        }
    }
}

struct ProfileActionRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(MapdColors.accent)
                    .frame(width: 24)
                
                Text(title)
                    .font(MapdTypography.body)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(MapdColors.mediumGray)
            }
            .padding(MapdSpacing.md)
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views
struct EditProfileView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Edit Profile - Coming Soon")
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Settings - Coming Soon")
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    ProfileView(userManager: UserManager())
}
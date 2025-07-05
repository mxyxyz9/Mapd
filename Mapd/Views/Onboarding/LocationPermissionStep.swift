//
//  LocationPermissionStep.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import CoreLocation

struct LocationPermissionStep: View {
    @ObservedObject var locationManager: LocationManager
    @State private var hasRequestedPermission = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: MapdSpacing.xl) {
                VStack(spacing: MapdSpacing.md) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(MapdColors.accent)
                    
                    Text("Enable Location Services")
                        .font(MapdTypography.display)
                        .foregroundColor(MapdColors.dark)
                        .multilineTextAlignment(.center)
                    
                    Text("Help us discover amazing places near you and track your travel adventures")
                        .font(MapdTypography.body)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: MapdSpacing.lg) {
                    // Benefits
                    VStack(spacing: MapdSpacing.md) {
                        LocationBenefitRow(
                            icon: "map.fill",
                            title: "Discover Nearby Places",
                            description: "Find interesting spots and attractions around you"
                        )
                        
                        LocationBenefitRow(
                            icon: "location.fill",
                            title: "Auto-Track Visits",
                            description: "Automatically log places you've been to"
                        )
                        
                        LocationBenefitRow(
                            icon: "compass.drawing",
                            title: "Smart Recommendations",
                            description: "Get personalized suggestions based on your location"
                        )
                        
                        LocationBenefitRow(
                            icon: "shield.fill",
                            title: "Privacy Protected",
                            description: "Your location data stays private and secure"
                        )
                    }
                    
                    // Permission Status
                    LocationPermissionStatus(authorizationStatus: locationManager.authorizationStatus)
                    
                    // Action Button
                    VStack(spacing: MapdSpacing.md) {
                        if locationManager.authorizationStatus == .notDetermined {
                            MapdButton(
                                "Enable Location Services",
                                icon: "location.fill",
                                style: .primary,
                                size: .large
                            ) {
                                locationManager.requestLocationPermission()
                                hasRequestedPermission = true
                            }
                        } else if locationManager.authorizationStatus == .denied {
                            VStack(spacing: MapdSpacing.sm) {
                                MapdButton(
                                    "Open Settings",
                                    icon: "gear",
                                    style: .primary,
                                    size: .large
                                ) {
                                    openAppSettings()
                                }
                                
                                Text("You can enable location services in Settings > Privacy & Security > Location Services")
                                    .font(MapdTypography.small)
                                    .foregroundColor(MapdColors.mediumGray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        if hasRequestedPermission || locationManager.authorizationStatus != .notDetermined {
                            Text("Don't worry, you can always change this later in Settings")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.mediumGray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding(.horizontal, MapdSpacing.screenPadding)
            .padding(.vertical, MapdSpacing.xl)
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct LocationBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: MapdSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(MapdColors.accent)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                Text(title)
                    .font(MapdTypography.bodyBold)
                    .foregroundColor(MapdColors.darkText)
                
                Text(description)
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

struct LocationPermissionStatus: View {
    let authorizationStatus: CLAuthorizationStatus
    
    var body: some View {
        HStack(spacing: MapdSpacing.md) {
            Image(systemName: statusIcon)
                .font(.title3)
                .foregroundColor(statusColor)
            
            VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                Text(statusTitle)
                    .font(MapdTypography.bodyBold)
                    .foregroundColor(MapdColors.darkText)
                
                Text(statusDescription)
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
            }
            
            Spacer()
        }
        .padding(MapdSpacing.md)
        .background(statusBackgroundColor)
        .cornerRadius(MapdRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: MapdRadius.card)
                .stroke(statusColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var statusIcon: String {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        @unknown default:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return MapdColors.success
        case .denied, .restricted:
            return MapdColors.error
        case .notDetermined:
            return MapdColors.warning
        @unknown default:
            return MapdColors.mediumGray
        }
    }
    
    private var statusBackgroundColor: Color {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return MapdColors.success.opacity(0.1)
        case .denied, .restricted:
            return MapdColors.error.opacity(0.1)
        case .notDetermined:
            return MapdColors.warning.opacity(0.1)
        @unknown default:
            return MapdColors.lightGray
        }
    }
    
    private var statusTitle: String {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location Services Enabled"
        case .denied:
            return "Location Services Denied"
        case .restricted:
            return "Location Services Restricted"
        case .notDetermined:
            return "Location Permission Pending"
        @unknown default:
            return "Unknown Status"
        }
    }
    
    private var statusDescription: String {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Great! We can now provide location-based features"
        case .denied:
            return "You can enable this later in Settings if you change your mind"
        case .restricted:
            return "Location services are restricted on this device"
        case .notDetermined:
            return "Tap the button above to enable location services"
        @unknown default:
            return "Unable to determine location permission status"
        }
    }
}

#Preview {
    LocationPermissionStep(locationManager: LocationManager())
}
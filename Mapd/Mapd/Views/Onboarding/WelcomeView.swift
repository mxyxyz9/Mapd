//
//  WelcomeView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import Foundation

struct WelcomeView: View {
    @Binding var showOnboarding: Bool
    @State private var animateElements = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                MapdColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Hero Section
                    VStack(spacing: MapdSpacing.xl) {
                        // App Logo/Icon
                        ZStack {
                            Circle()
                                .fill(MapdColors.accent.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 60))
                                .foregroundColor(MapdColors.accent)
                        }
                        .scaleEffect(animateElements ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateElements)
                        
                        // Title and Tagline
                        VStack(spacing: MapdSpacing.md) {
                            Text("Mapd")
                                .font(MapdTypography.display)
                                .foregroundColor(MapdColors.dark)
                                .opacity(animateElements ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateElements)
                            
                            Text("Track Your Adventures")
                                .font(MapdTypography.heading1)
                                .foregroundColor(MapdColors.mediumGray)
                                .multilineTextAlignment(.center)
                                .opacity(animateElements ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.8).delay(0.4), value: animateElements)
                        }
                        
                        // Description
                        Text("Discover new places, mark your visits, and plan amazing trips with smart checklists")
                            .font(MapdTypography.body)
                            .foregroundColor(MapdColors.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, MapdSpacing.xl)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.8).delay(0.6), value: animateElements)
                    }
                    
                    Spacer()
                    
                    // Features Preview
                    VStack(spacing: MapdSpacing.lg) {
                        HStack(spacing: MapdSpacing.md) {
                            FeaturePreviewCard(
                                icon: "mappin.circle.fill",
                                title: "Track Visits",
                                description: "Mark places you've been",
                                color: MapdColors.accent
                            )
                            
                            FeaturePreviewCard(
                                icon: "dice.fill",
                                title: "Discover",
                                description: "Find random destinations",
                                color: MapdColors.info
                            )
                        }
                        .opacity(animateElements ? 1.0 : 0.0)
                        .offset(y: animateElements ? 0 : 50)
                        .animation(.easeInOut(duration: 0.8).delay(0.8), value: animateElements)
                        
                        HStack(spacing: MapdSpacing.md) {
                            FeaturePreviewCard(
                                icon: "list.clipboard.fill",
                                title: "Plan Trips",
                                description: "Smart travel checklists",
                                color: MapdColors.warning
                            )
                            
                            FeaturePreviewCard(
                                icon: "heart.fill",
                                title: "Bucket List",
                                description: "Save dream destinations",
                                color: Color.pink
                            )
                        }
                        .opacity(animateElements ? 1.0 : 0.0)
                        .offset(y: animateElements ? 0 : 50)
                        .animation(.easeInOut(duration: 0.8).delay(1.0), value: animateElements)
                    }
                    
                    Spacer()
                    
                    // Get Started Button
                    VStack(spacing: MapdSpacing.md) {
                        MapdButton(
                            "Get Started",
                            icon: "arrow.right",
                            style: .primary,
                            size: .large
                        ) {
                            showOnboarding = true
                        }
                        .opacity(animateElements ? 1.0 : 0.0)
                        .offset(y: animateElements ? 0 : 30)
                        .animation(.easeInOut(duration: 0.8).delay(1.2), value: animateElements)
                        
                        Text("Free to use, no account required")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.8).delay(1.4), value: animateElements)
                    }
                    .padding(.horizontal, MapdSpacing.screenPadding)
                    .padding(.bottom, MapdSpacing.xl)
                }
            }
        }
        .onAppear {
            animateElements = true
        }
    }
}

struct FeaturePreviewCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: MapdSpacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(MapdRadius.medium)
            
            VStack(spacing: MapdSpacing.xs) {
                Text(title)
                    .font(MapdTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(MapdColors.darkText)
                
                Text(description)
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.mediumGray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(MapdSpacing.md)
        .background(MapdColors.cardBackground)
        .cornerRadius(MapdRadius.card)
        .shadow(
            color: MapdShadows.light.color,
            radius: MapdShadows.light.radius,
            x: 0,
            y: MapdShadows.light.y
        )
    }
}

#Preview {
    WelcomeView(showOnboarding: .constant(false))
}
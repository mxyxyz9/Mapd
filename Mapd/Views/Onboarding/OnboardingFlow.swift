//
//  OnboardingFlow.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var locationManager = LocationManager()
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var selectedTravelStyle: TravelStyle = .adventure
    @State private var selectedInterests: Set<TravelInterest> = []
    @State private var showingImagePicker = false
    
    let totalSteps = 3
    
    var body: some View {
        NavigationView {
            ZStack {
                MapdColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Header
                    OnboardingHeader(
                        currentStep: currentStep + 1,
                        totalSteps: totalSteps,
                        onBack: currentStep > 0 ? { currentStep -= 1 } : nil
                    )
                    
                    // Content
                    TabView(selection: $currentStep) {
                        // Step 1: Profile Creation
                        ProfileCreationStep(
                            userName: $userName,
                            selectedTravelStyle: $selectedTravelStyle,
                            showingImagePicker: $showingImagePicker
                        )
                        .tag(0)
                        
                        // Step 2: Location Permission
                        LocationPermissionStep(locationManager: locationManager)
                            .tag(1)
                        
                        // Step 3: Interest Selection
                        InterestSelectionStep(selectedInterests: $selectedInterests)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                    
                    // Bottom Navigation
                    OnboardingBottomNavigation(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        canProceed: canProceedToNextStep,
                        onNext: handleNextStep,
                        onComplete: completeOnboarding
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 0: return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: return true // Location permission is optional
        case 2: return selectedInterests.count >= 3
        default: return false
        }
    }
    
    private func handleNextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation {
                currentStep += 1
            }
        }
    }
    
    private func completeOnboarding() {
        // Save user data
        userManager.updateUserProfile(
            name: userName,
            travelStyle: selectedTravelStyle,
            interests: Array(selectedInterests)
        )
        
        userManager.setLocationPermission(
            locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways
        )
        
        userManager.completeOnboarding()
    }
}

// MARK: - Onboarding Header
struct OnboardingHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onBack: (() -> Void)?
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            HStack {
                if let onBack = onBack {
                    IconButton(icon: "chevron.left", size: .medium) {
                        onBack()
                    }
                } else {
                    Spacer()
                        .frame(width: 40)
                }
                
                Spacer()
                
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
                
                Spacer()
                
                Spacer()
                    .frame(width: 40)
            }
            
            // Progress Bar
            ProgressView(value: Double(currentStep), total: Double(totalSteps))
                .progressViewStyle(LinearProgressViewStyle(tint: MapdColors.accent))
                .scaleEffect(x: 1, y: 2)
        }
        .padding(.horizontal, MapdSpacing.screenPadding)
        .padding(.top, MapdSpacing.md)
    }
}

// MARK: - Bottom Navigation
struct OnboardingBottomNavigation: View {
    let currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let onNext: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            if currentStep == totalSteps - 1 {
                MapdButton(
                    "Complete Setup",
                    icon: "checkmark",
                    style: .primary,
                    size: .large
                ) {
                    onComplete()
                }
                .disabled(!canProceed)
                .opacity(canProceed ? 1.0 : 0.6)
            } else {
                MapdButton(
                    "Continue",
                    icon: "arrow.right",
                    style: .primary,
                    size: .large
                ) {
                    onNext()
                }
                .disabled(!canProceed)
                .opacity(canProceed ? 1.0 : 0.6)
            }
            
            if currentStep < totalSteps - 1 {
                Button("Skip for now") {
                    onNext()
                }
                .font(MapdTypography.caption)
                .foregroundColor(MapdColors.mediumGray)
            }
        }
        .padding(.horizontal, MapdSpacing.screenPadding)
        .padding(.bottom, MapdSpacing.xl)
    }
}

// MARK: - Step 1: Profile Creation
struct ProfileCreationStep: View {
    @Binding var userName: String
    @Binding var selectedTravelStyle: TravelStyle
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: MapdSpacing.xl) {
                VStack(spacing: MapdSpacing.md) {
                    Text("Let's get to know you")
                        .font(MapdTypography.display)
                        .foregroundColor(MapdColors.dark)
                        .multilineTextAlignment(.center)
                    
                    Text("Tell us a bit about yourself to personalize your travel experience")
                        .font(MapdTypography.body)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: MapdSpacing.lg) {
                    // Profile Photo (Optional)
                    VStack(spacing: MapdSpacing.md) {
                        Button(action: { showingImagePicker = true }) {
                            ZStack {
                                Circle()
                                    .fill(MapdColors.lightGray)
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundColor(MapdColors.mediumGray)
                            }
                        }
                        
                        Text("Add Photo (Optional)")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    
                    // Name Input
                    VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                        Text("What's your name?")
                            .font(MapdTypography.heading2)
                            .foregroundColor(MapdColors.darkText)
                        
                        TextField("Enter your name", text: $userName)
                            .font(MapdTypography.body)
                            .padding(MapdSpacing.md)
                            .background(MapdColors.cardBackground)
                            .cornerRadius(MapdRadius.input)
                            .overlay(
                                RoundedRectangle(cornerRadius: MapdRadius.input)
                                    .stroke(MapdColors.lightGray, lineWidth: 1)
                            )
                    }
                    
                    // Travel Style Selection
                    VStack(alignment: .leading, spacing: MapdSpacing.md) {
                        Text("What's your travel style?")
                            .font(MapdTypography.heading2)
                            .foregroundColor(MapdColors.darkText)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: MapdSpacing.md) {
                            ForEach(TravelStyle.allCases, id: \.self) { style in
                                TravelStyleCard(
                                    style: style,
                                    isSelected: selectedTravelStyle == style
                                ) {
                                    selectedTravelStyle = style
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, MapdSpacing.screenPadding)
            .padding(.vertical, MapdSpacing.xl)
        }
    }
}

struct TravelStyleCard: View {
    let style: TravelStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MapdSpacing.md) {
                Image(systemName: style.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? MapdColors.accent : MapdColors.mediumGray)
                
                VStack(spacing: MapdSpacing.xs) {
                    Text(style.rawValue)
                        .font(MapdTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(MapdColors.darkText)
                    
                    Text(style.description)
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(MapdSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: MapdRadius.card)
                    .stroke(isSelected ? MapdColors.accent : MapdColors.lightGray, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingFlow()
}
//
//  InterestSelectionStep.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct InterestSelectionStep: View {
    @Binding var selectedInterests: Set<TravelInterest>
    
    private let minimumSelections = 3
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            VStack(spacing: MapdSpacing.xl) {
                VStack(spacing: MapdSpacing.md) {
                    Text("What interests you?")
                        .font(MapdTypography.display)
                        .foregroundColor(MapdColors.dark)
                        .multilineTextAlignment(.center)
                    
                    Text("Select at least \(minimumSelections) interests to help us personalize your travel recommendations")
                        .font(MapdTypography.body)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: MapdSpacing.lg) {
                    // Selection Counter
                    SelectionCounter(
                        selectedCount: selectedInterests.count,
                        minimumCount: minimumSelections
                    )
                    
                    // Interest Grid
                    LazyVGrid(columns: columns, spacing: MapdSpacing.md) {
                        ForEach(TravelInterest.allCases, id: \.self) { interest in
                            InterestCard(
                                interest: interest,
                                isSelected: selectedInterests.contains(interest)
                            ) {
                                toggleInterest(interest)
                            }
                        }
                    }
                    
                    // Helper Text
                    VStack(spacing: MapdSpacing.sm) {
                        if selectedInterests.count < minimumSelections {
                            Text("Select \(minimumSelections - selectedInterests.count) more to continue")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.warning)
                        } else {
                            Text("Perfect! You can always update your interests later")
                                .font(MapdTypography.caption)
                                .foregroundColor(MapdColors.success)
                        }
                        
                        Text("These help us suggest places and experiences you'll love")
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, MapdSpacing.screenPadding)
            .padding(.vertical, MapdSpacing.xl)
        }
    }
    
    private func toggleInterest(_ interest: TravelInterest) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedInterests.contains(interest) {
                selectedInterests.remove(interest)
            } else {
                selectedInterests.insert(interest)
            }
        }
    }
}

struct SelectionCounter: View {
    let selectedCount: Int
    let minimumCount: Int
    
    var body: some View {
        HStack(spacing: MapdSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(selectedCount >= minimumCount ? MapdColors.success : MapdColors.mediumGray)
            
            VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                Text("\(selectedCount) selected")
                    .font(MapdTypography.bodyBold)
                    .foregroundColor(MapdColors.darkText)
                
                Text("Minimum \(minimumCount) required")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
            }
            
            Spacer()
            
            // Progress Indicator
            ZStack {
                Circle()
                    .stroke(MapdColors.lightGray, lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: min(Double(selectedCount) / Double(minimumCount), 1.0))
                    .stroke(
                        selectedCount >= minimumCount ? MapdColors.success : MapdColors.accent,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: selectedCount)
                
                Text("\(selectedCount)")
                    .font(MapdTypography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(selectedCount >= minimumCount ? MapdColors.success : MapdColors.accent)
            }
        }
        .padding(MapdSpacing.md)
        .background(MapdColors.cardBackground)
        .cornerRadius(MapdRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: MapdRadius.card)
                .stroke(
                    selectedCount >= minimumCount ? MapdColors.success.opacity(0.3) : MapdColors.lightGray,
                    lineWidth: 1
                )
        )
    }
}

struct InterestCard: View {
    let interest: TravelInterest
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MapdSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? interest.color.opacity(0.2) : MapdColors.lightGray)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: interest.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? interest.color : MapdColors.mediumGray)
                }
                
                VStack(spacing: MapdSpacing.xs) {
                    Text(interest.rawValue)
                        .font(MapdTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(MapdColors.darkText)
                        .multilineTextAlignment(.center)
                    
                    Text(interest.description)
                        .font(MapdTypography.small)
                        .foregroundColor(MapdColors.mediumGray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(MapdSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: MapdRadius.card)
                    .stroke(
                        isSelected ? interest.color : MapdColors.lightGray,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? interest.color.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Quick Selection Buttons
struct QuickSelectionButtons: View {
    @Binding var selectedInterests: Set<TravelInterest>
    
    private let popularInterests: [TravelInterest] = [
        .culture, .food, .nature, .adventure, .photography, .history
    ]
    
    private let relaxationInterests: [TravelInterest] = [
        .beaches, .wellness, .luxury, .food, .shopping, .nightlife
    ]
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            Text("Quick Select")
                .font(MapdTypography.bodyBold)
                .foregroundColor(MapdColors.darkText)
            
            HStack(spacing: MapdSpacing.sm) {
                QuickSelectButton(
                    title: "Popular",
                    icon: "star.fill",
                    interests: popularInterests
                ) {
                    selectedInterests.formUnion(popularInterests)
                }
                
                QuickSelectButton(
                    title: "Relaxation",
                    icon: "leaf.fill",
                    interests: relaxationInterests
                ) {
                    selectedInterests.formUnion(relaxationInterests)
                }
                
                QuickSelectButton(
                    title: "Clear All",
                    icon: "xmark",
                    interests: []
                ) {
                    selectedInterests.removeAll()
                }
            }
        }
    }
}

struct QuickSelectButton: View {
    let title: String
    let icon: String
    let interests: [TravelInterest]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(MapdTypography.small)
            }
            .padding(.horizontal, MapdSpacing.sm)
            .padding(.vertical, MapdSpacing.xs)
            .background(MapdColors.lightGray)
            .foregroundColor(MapdColors.mediumGray)
            .cornerRadius(MapdRadius.button)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    InterestSelectionStep(selectedInterests: .constant([.culture, .food, .nature]))
}
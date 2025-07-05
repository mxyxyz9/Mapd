//
//  MapdButton.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

struct MapdButton: View {
    let title: String
    let icon: String?
    let style: MapdButtonStyle
    let size: ButtonSize
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        style: MapdButtonStyle = .primary,
        size: ButtonSize = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.textColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconFont)
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(size.textFont)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(style.textColor)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(minHeight: size.minHeight)
            .background(style.backgroundColor)
            .cornerRadius(MapdRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: MapdRadius.button)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .disabled(isLoading)
        .buttonStyle(PlainButtonStyle())
    }
}

enum ButtonSize {
    case small
    case medium
    case large
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return MapdSpacing.md
        case .medium: return MapdSpacing.lg
        case .large: return MapdSpacing.xl
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return MapdSpacing.sm
        case .medium: return MapdSpacing.md
        case .large: return MapdSpacing.md
        }
    }
    
    var minHeight: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 52
        }
    }
    
    var textFont: Font {
        switch self {
        case .small: return MapdTypography.caption
        case .medium: return MapdTypography.body
        case .large: return MapdTypography.heading2
        }
    }
    
    var iconFont: Font {
        switch self {
        case .small: return .caption
        case .medium: return .body
        case .large: return .title3
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MapdSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(MapdRadius.medium)
                
                Text(title)
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.darkText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(MapdColors.accent)
                .cornerRadius(28)
                .shadow(
                    color: MapdShadows.medium.color,
                    radius: MapdShadows.medium.radius,
                    x: 0,
                    y: MapdShadows.medium.y
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Chip Button
struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MapdTypography.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : MapdColors.darkText)
                .padding(.horizontal, MapdSpacing.md)
                .padding(.vertical, MapdSpacing.sm)
                .background(isSelected ? MapdColors.accent : MapdColors.background)
                .cornerRadius(MapdRadius.chip)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: IconButtonSize
    let style: IconButtonStyle
    let action: () -> Void
    
    init(
        icon: String,
        size: IconButtonSize = .medium,
        style: IconButtonStyle = .default,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(size.font)
                .foregroundColor(style.foregroundColor)
                .frame(width: size.frameSize, height: size.frameSize)
                .background(style.backgroundColor)
                .cornerRadius(size.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum IconButtonSize {
    case small
    case medium
    case large
    
    var frameSize: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 40
        case .large: return 48
        }
    }
    
    var font: Font {
        switch self {
        case .small: return .caption
        case .medium: return .body
        case .large: return .title3
        }
    }
    
    var cornerRadius: CGFloat {
        frameSize / 2
    }
}

enum IconButtonStyle {
    case `default`
    case filled
    case outlined
    
    var backgroundColor: Color {
        switch self {
        case .default: return Color.clear
        case .filled: return MapdColors.accent
        case .outlined: return Color.clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .default: return MapdColors.darkText
        case .filled: return .white
        case .outlined: return MapdColors.accent
        }
    }
}

#Preview {
    VStack(spacing: MapdSpacing.lg) {
        // Primary buttons
        HStack(spacing: MapdSpacing.md) {
            MapdButton("Primary", style: .primary) {}
            MapdButton("Secondary", style: .secondary) {}
            MapdButton("Ghost", style: .ghost) {}
        }
        
        // Button with icon
        MapdButton("Add Place", icon: "plus.circle.fill", style: .primary) {}
        
        // Loading button
        MapdButton("Loading", style: .primary, isLoading: true) {}
        
        // Quick action buttons
        HStack(spacing: MapdSpacing.md) {
            QuickActionButton(
                title: "Mark as Visited",
                icon: "mappin.circle.fill",
                color: MapdColors.accent
            ) {}
            
            QuickActionButton(
                title: "Random Destination",
                icon: "dice.fill",
                color: MapdColors.info
            ) {}
        }
        
        // Chip buttons
        HStack(spacing: MapdSpacing.sm) {
            ChipButton(title: "Adventure", isSelected: true) {}
            ChipButton(title: "Relaxation", isSelected: false) {}
            ChipButton(title: "Cultural", isSelected: false) {}
        }
        
        // Icon buttons
        HStack(spacing: MapdSpacing.md) {
            IconButton(icon: "heart", style: .default) {}
            IconButton(icon: "heart.fill", style: .filled) {}
            IconButton(icon: "heart", style: .outlined) {}
        }
        
        // Floating action button
        FloatingActionButton(icon: "plus") {}
    }
    .padding()
    .background(MapdColors.background)
}
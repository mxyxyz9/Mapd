//
//  DesignSystem.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI

// MARK: - Color Palette
struct MapdColors {
    // Primary Colors
    static let accent = Color(hex: "9ACD32") // Lime green
    static let dark = Color(hex: "2C3E50") // Dark navy/charcoal
    
    // Neutrals
    static let background = Color(hex: "F5F5F0") // Warm off-white/cream
    static let cardBackground = Color.white
    static let lightGray = Color(hex: "E8E8E8")
    static let mediumGray = Color(hex: "A0A0A0")
    static let darkText = Color(hex: "2C2C2C")
    
    // Semantic Colors
    static let success = Color(hex: "9ACD32")
    static let info = Color(hex: "5A9FD8")
    static let warning = Color(hex: "F39C12")
    static let error = Color(hex: "E74C3C")
}

// MARK: - Typography
struct MapdTypography {
    // Display - Main screen titles, hero text
    static let display = Font.system(size: 30, weight: .bold, design: .default)
    
    // Heading 1 - Card titles, section headers
    static let heading1 = Font.system(size: 25, weight: .semibold, design: .default)
    
    // Heading 2 - Subheadings, important labels
    static let heading2 = Font.system(size: 19, weight: .semibold, design: .default)
    
    // Heading 3 - Smaller subheadings
    static let heading3 = Font.system(size: 17, weight: .semibold, design: .default)
    
    // Body - Primary body text, descriptions
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)
    static let bodyBold = Font.system(size: 16, weight: .bold, design: .default)
    
    // Caption - Secondary text, metadata
    static let caption = Font.system(size: 14, weight: .regular, design: .default)
    
    // Small - Labels, fine print
    static let small = Font.system(size: 12, weight: .medium, design: .default)
}

// MARK: - Spacing
struct MapdSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    
    // Patterns
    static let screenPadding: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let componentSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 24
}

// MARK: - Border Radius
struct MapdRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
    static let pill: CGFloat = 50
    
    // Usage
    static let card: CGFloat = 16
    static let button: CGFloat = 12
    static let input: CGFloat = 12
    static let chip: CGFloat = 20
}

// MARK: - Shadows
struct MapdShadows {
    static let light = Shadow(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )
    
    static let medium = Shadow(
        color: Color.black.opacity(0.12),
        radius: 12,
        x: 0,
        y: 4
    )
    
    static let heavy = Shadow(
        color: Color.black.opacity(0.16),
        radius: 24,
        x: 0,
        y: 8
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex Support
extension Color {
    public init(hex hexString: String) {
        let trimmedHexString = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: trimmedHexString).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch trimmedHexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions for Design System
extension View {
    func mapdCardStyle() -> some View {
        self
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
            .shadow(
                color: MapdShadows.light.color,
                radius: MapdShadows.light.radius,
                x: MapdShadows.light.x,
                y: MapdShadows.light.y
            )
    }
    
    func mapdButtonStyle(style: MapdButtonStyle = .primary) -> some View {
        self
            .font(MapdTypography.bodyMedium)
            .foregroundColor(style.textColor)
            .padding(.horizontal, MapdSpacing.lg)
            .padding(.vertical, MapdSpacing.md)
            .background(style.backgroundColor)
            .cornerRadius(MapdRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: MapdRadius.button)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
    }
    
    func mapdChipStyle(isSelected: Bool = false) -> some View {
        self
            .font(MapdTypography.caption)
            .foregroundColor(isSelected ? .white : MapdColors.darkText)
            .padding(.horizontal, MapdSpacing.md)
            .padding(.vertical, MapdSpacing.sm)
            .background(isSelected ? MapdColors.accent : MapdColors.background)
            .cornerRadius(MapdRadius.chip)
    }
}

// MARK: - Button Styles
enum MapdButtonStyle {
    case primary
    case secondary
    case ghost
    
    var backgroundColor: Color {
        switch self {
        case .primary: return MapdColors.accent
        case .secondary: return Color.clear
        case .ghost: return Color.clear
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return MapdColors.dark
        case .ghost: return MapdColors.dark
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary: return Color.clear
        case .secondary: return MapdColors.lightGray
        case .ghost: return Color.clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .primary: return 0
        case .secondary: return 1
        case .ghost: return 0
        }
    }
}
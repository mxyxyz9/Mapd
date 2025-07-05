//
//  SearchView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var selectedCategory: SearchCategory = .all
    @State private var recentSearches: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                SearchHeader(
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    onSearch: performSearch
                )
                
                // Content
                if searchText.isEmpty {
                    SearchEmptyState(
                        recentSearches: recentSearches,
                        onRecentSearchTap: { search in
                            searchText = search
                            performSearch()
                        }
                    )
                } else if isSearching {
                    SearchLoadingState()
                } else if searchResults.isEmpty {
                    SearchNoResultsState(searchText: searchText)
                } else {
                    SearchResultsList(
                        results: searchResults,
                        onResultTap: { result in
                            // Handle result selection
                            addToRecentSearches(searchText)
                        }
                    )
                }
                
                Spacer()
            }
            .background(MapdColors.background)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadRecentSearches()
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSearching = true
        
        Task {
            do {
                let results = try await locationManager.searchPlaces(
                    query: searchText,
                    region: locationManager.currentLocation?.coordinate
                )
                
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.searchResults = []
                    self.isSearching = false
                }
            }
        }
    }
    
    private func addToRecentSearches(_ search: String) {
        let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty && !recentSearches.contains(trimmedSearch) {
            recentSearches.insert(trimmedSearch, at: 0)
            if recentSearches.count > 10 {
                recentSearches.removeLast()
            }
            saveRecentSearches()
        }
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recent_searches") ?? []
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recent_searches")
    }
}

// MARK: - Search Category
enum SearchCategory: String, CaseIterable {
    case all = "All"
    case restaurants = "Restaurants"
    case attractions = "Attractions"
    case hotels = "Hotels"
    case parks = "Parks"
    case museums = "Museums"
    
    var icon: String {
        switch self {
        case .all: return "magnifyingglass"
        case .restaurants: return "fork.knife"
        case .attractions: return "star"
        case .hotels: return "bed.double"
        case .parks: return "tree"
        case .museums: return "building.columns"
        }
    }
}

// MARK: - Search Header
struct SearchHeader: View {
    @Binding var searchText: String
    @Binding var selectedCategory: SearchCategory
    let onSearch: () -> Void
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            // Search Bar
            HStack(spacing: MapdSpacing.md) {
                HStack(spacing: MapdSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(MapdColors.mediumGray)
                    
                    TextField("Search places...", text: $searchText)
                        .font(MapdTypography.body)
                        .onSubmit {
                            onSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                }
                .padding(MapdSpacing.md)
                .background(MapdColors.cardBackground)
                .cornerRadius(MapdRadius.input)
                .overlay(
                    RoundedRectangle(cornerRadius: MapdRadius.input)
                        .stroke(MapdColors.lightGray, lineWidth: 1)
                )
            }
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MapdSpacing.sm) {
                    ForEach(SearchCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                            if !searchText.isEmpty {
                                onSearch()
                            }
                        }
                    }
                }
                .padding(.horizontal, MapdSpacing.screenPadding)
            }
        }
        .padding(.top, MapdSpacing.md)
        .background(MapdColors.background)
    }
}

struct CategoryChip: View {
    let category: SearchCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(MapdTypography.small)
            }
            .padding(.horizontal, MapdSpacing.md)
            .padding(.vertical, MapdSpacing.sm)
            .background(isSelected ? MapdColors.accent : MapdColors.cardBackground)
            .foregroundColor(isSelected ? .white : MapdColors.mediumGray)
            .cornerRadius(MapdRadius.button)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search States
struct SearchEmptyState: View {
    let recentSearches: [String]
    let onRecentSearchTap: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MapdSpacing.lg) {
                // Recent Searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: MapdSpacing.md) {
                        Text("Recent Searches")
                            .font(MapdTypography.heading2)
                            .foregroundColor(MapdColors.darkText)
                        
                        VStack(spacing: MapdSpacing.sm) {
                            ForEach(recentSearches.prefix(5), id: \.self) { search in
                                RecentSearchRow(search: search) {
                                    onRecentSearchTap(search)
                                }
                            }
                        }
                    }
                }
                
                // Quick Search Suggestions
                VStack(alignment: .leading, spacing: MapdSpacing.md) {
                    Text("Quick Search")
                        .font(MapdTypography.heading2)
                        .foregroundColor(MapdColors.darkText)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: MapdSpacing.md) {
                        QuickSearchCard(title: "Restaurants", icon: "fork.knife", color: MapdColors.accent)
                        QuickSearchCard(title: "Coffee Shops", icon: "cup.and.saucer", color: MapdColors.warning)
                        QuickSearchCard(title: "Parks", icon: "tree", color: MapdColors.success)
                        QuickSearchCard(title: "Museums", icon: "building.columns", color: MapdColors.error)
                    }
                }
                
                // Search Tips
                SearchTipsSection()
            }
            .padding(.horizontal, MapdSpacing.screenPadding)
            .padding(.vertical, MapdSpacing.lg)
        }
    }
}

struct RecentSearchRow: View {
    let search: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.md) {
                Image(systemName: "clock")
                    .foregroundColor(MapdColors.mediumGray)
                    .frame(width: 20)
                
                Text(search)
                    .font(MapdTypography.body)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
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

struct QuickSearchCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: MapdSpacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(MapdTypography.caption)
                .foregroundColor(MapdColors.darkText)
        }
        .padding(MapdSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(MapdColors.cardBackground)
        .cornerRadius(MapdRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: MapdRadius.card)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SearchTipsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Search Tips")
                .font(MapdTypography.heading3)
                .foregroundColor(MapdColors.darkText)
            
            VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                SearchTip(text: "Try searching for specific place names")
                SearchTip(text: "Use categories like 'restaurants near me'")
                SearchTip(text: "Search by city or neighborhood")
                SearchTip(text: "Look for attractions, hotels, or activities")
            }
        }
        .padding(MapdSpacing.md)
        .background(MapdColors.cardBackground)
        .cornerRadius(MapdRadius.card)
    }
}

struct SearchTip: View {
    let text: String
    
    var body: some View {
        HStack(spacing: MapdSpacing.sm) {
            Image(systemName: "lightbulb")
                .font(.caption)
                .foregroundColor(MapdColors.warning)
            
            Text(text)
                .font(MapdTypography.small)
                .foregroundColor(MapdColors.mediumGray)
        }
    }
}

struct SearchLoadingState: View {
    var body: some View {
        VStack(spacing: MapdSpacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Searching...")
                .font(MapdTypography.body)
                .foregroundColor(MapdColors.mediumGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchNoResultsState: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: MapdSpacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(MapdColors.mediumGray)
            
            VStack(spacing: MapdSpacing.sm) {
                Text("No results found")
                    .font(MapdTypography.heading2)
                    .foregroundColor(MapdColors.darkText)
                
                Text("Try searching for '\(searchText)' with different keywords")
                    .font(MapdTypography.body)
                    .foregroundColor(MapdColors.mediumGray)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: MapdSpacing.sm) {
                Text("Suggestions:")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
                
                Text("• Check your spelling")
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.mediumGray)
                
                Text("• Try more general terms")
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.mediumGray)
                
                Text("• Search by category")
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.mediumGray)
            }
        }
        .padding(MapdSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchResultsList: View {
    let results: [MKMapItem]
    let onResultTap: (MKMapItem) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: MapdSpacing.md) {
                ForEach(results, id: \.self) { result in
                    SearchResultRow(result: result) {
                        onResultTap(result)
                    }
                }
            }
            .padding(.horizontal, MapdSpacing.screenPadding)
            .padding(.vertical, MapdSpacing.lg)
        }
    }
}

struct SearchResultRow: View {
    let result: MKMapItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.md) {
                // Category Icon
                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundColor(MapdColors.accent)
                    .frame(width: 24)
                
                // Place Info
                VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                    Text(result.name ?? "Unknown Place")
                        .font(MapdTypography.bodyBold)
                        .foregroundColor(MapdColors.darkText)
                        .lineLimit(1)
                    
                    if let category = result.pointOfInterestCategory?.rawValue {
                        Text(category.capitalized)
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    
                    if let address = formatAddress() {
                        Text(address)
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Distance (if available)
                VStack(alignment: .trailing, spacing: MapdSpacing.xs) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(MapdColors.mediumGray)
                }
            }
            .padding(MapdSpacing.md)
            .background(MapdColors.cardBackground)
            .cornerRadius(MapdRadius.card)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryIcon: String {
        guard let category = result.pointOfInterestCategory else { return "mappin" }
        
        switch category {
        case .restaurant: return "fork.knife"
        case .museum: return "building.columns"
        case .park: return "tree"
        case .beach: return "beach.umbrella"
        case .hospital: return "cross"
        case .school: return "graduationcap"
        case .store: return "bag"
        default: return "mappin"
        }
    }
    
    private func formatAddress() -> String? {
        let placemark = result.placemark
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

#Preview {
    SearchView(locationManager: LocationManager())
}
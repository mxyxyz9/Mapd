//
//  AddPlaceView.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import SwiftUI
import MapKit
import PhotosUI

struct AddPlaceView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var placeName = ""
    @State private var city = ""
    @State private var country = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var dateVisited = Date()
    @State private var rating: Double = 0
    @State private var notes = ""
    @State private var selectedTags: Set<String> = []
    @State private var customTag = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoURLs: [String] = []
    @State private var isVisited = true
    @State private var isFavorite = false
    
    @State private var showingLocationPicker = false
    @State private var showingTagInput = false
    @State private var isLoading = false
    
    private let predefinedTags = [
        "Restaurant", "Museum", "Park", "Beach", "Mountain", "City", "Historic",
        "Shopping", "Nightlife", "Adventure", "Relaxing", "Cultural", "Nature",
        "Architecture", "Food", "Art", "Music", "Sports", "Family", "Romantic"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MapdSpacing.lg) {
                    // Basic Information
                    BasicInfoSection(
                        placeName: $placeName,
                        city: $city,
                        country: $country,
                        selectedCoordinate: $selectedCoordinate,
                        onLocationTap: { showingLocationPicker = true }
                    )
                    
                    // Visit Details
                    VisitDetailsSection(
                        isVisited: $isVisited,
                        dateVisited: $dateVisited,
                        rating: $rating,
                        isFavorite: $isFavorite
                    )
                    
                    // Photos
                    PhotosSection(
                        selectedPhotos: $selectedPhotos,
                        photoURLs: $photoURLs
                    )
                    
                    // Notes
                    NotesSection(notes: $notes)
                    
                    // Tags
                    TagsSection(
                        selectedTags: $selectedTags,
                        customTag: $customTag,
                        predefinedTags: predefinedTags,
                        onAddCustomTag: addCustomTag,
                        onShowTagInput: { showingTagInput = true }
                    )
                    
                    // Current Location Helper
                    if locationManager.hasLocationPermission {
                        CurrentLocationHelper(
                            locationManager: locationManager,
                            onUseCurrentLocation: useCurrentLocation
                        )
                    }
                }
                .padding(.horizontal, MapdSpacing.screenPadding)
                .padding(.bottom, 100)
            }
            .background(MapdColors.background)
            .navigationTitle("Add Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePlace()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                selectedCoordinate: $selectedCoordinate,
                city: $city,
                country: $country
            )
        }
        .alert("Add Custom Tag", isPresented: $showingTagInput) {
            TextField("Tag name", text: $customTag)
            Button("Add") {
                addCustomTag()
            }
            Button("Cancel", role: .cancel) { }
        }
        .overlay {
            if isLoading {
                LoadingOverlay()
            }
        }
    }
    
    private var canSave: Bool {
        !placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func useCurrentLocation() {
        guard let location = locationManager.currentLocation else { return }
        
        selectedCoordinate = location.coordinate
        
        // Reverse geocode to get city and country
        Task {
            if let locationName = await locationManager.reverseGeocode(coordinate: location.coordinate) {
                await MainActor.run {
                    let components = locationName.components(separatedBy: ", ")
                    if components.count >= 2 {
                        self.city = components[0]
                        self.country = components.last ?? ""
                    }
                }
            }
        }
    }
    
    private func addCustomTag() {
        let trimmedTag = customTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !selectedTags.contains(trimmedTag) {
            selectedTags.insert(trimmedTag)
            customTag = ""
        }
    }
    
    private func savePlace() {
        guard canSave else { return }
        
        isLoading = true
        
        let newPlace = Place(
            id: UUID(),
            name: placeName.trimmingCharacters(in: .whitespacesAndNewlines),
            country: country.trimmingCharacters(in: .whitespacesAndNewlines),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            coordinate: selectedCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            dateVisited: isVisited ? dateVisited : nil,
            rating: rating > 0 ? rating : nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
            photos: photoURLs,
            tags: Array(selectedTags),
            isVisited: isVisited,
            isFavorite: isFavorite
        )
        
        if isVisited {
            userManager.addVisitedPlace(newPlace)
        } else {
            userManager.addToBucketList(newPlace)
        }
        
        isLoading = false
        dismiss()
    }
}

// MARK: - Basic Info Section
struct BasicInfoSection: View {
    @Binding var placeName: String
    @Binding var city: String
    @Binding var country: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    let onLocationTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Basic Information")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            VStack(spacing: MapdSpacing.md) {
                // Place Name
                VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                    Text("Place Name *")
                        .font(MapdTypography.caption)
                        .foregroundColor(MapdColors.mediumGray)
                    
                    TextField("Enter place name", text: $placeName)
                        .font(MapdTypography.body)
                        .padding(MapdSpacing.md)
                        .background(MapdColors.cardBackground)
                        .cornerRadius(MapdRadius.input)
                        .overlay(
                            RoundedRectangle(cornerRadius: MapdRadius.input)
                                .stroke(MapdColors.lightGray, lineWidth: 1)
                        )
                }
                
                // Location
                HStack(spacing: MapdSpacing.md) {
                    // City
                    VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                        Text("City *")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        TextField("City", text: $city)
                            .font(MapdTypography.body)
                            .padding(MapdSpacing.md)
                            .background(MapdColors.cardBackground)
                            .cornerRadius(MapdRadius.input)
                            .overlay(
                                RoundedRectangle(cornerRadius: MapdRadius.input)
                                    .stroke(MapdColors.lightGray, lineWidth: 1)
                            )
                    }
                    
                    // Country
                    VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                        Text("Country *")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        TextField("Country", text: $country)
                            .font(MapdTypography.body)
                            .padding(MapdSpacing.md)
                            .background(MapdColors.cardBackground)
                            .cornerRadius(MapdRadius.input)
                            .overlay(
                                RoundedRectangle(cornerRadius: MapdRadius.input)
                                    .stroke(MapdColors.lightGray, lineWidth: 1)
                            )
                    }
                }
                
                // Map Location
                Button(action: onLocationTap) {
                    HStack(spacing: MapdSpacing.md) {
                        Image(systemName: "map")
                            .foregroundColor(MapdColors.accent)
                        
                        VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                            Text("Location on Map")
                                .font(MapdTypography.bodyBold)
                                .foregroundColor(MapdColors.darkText)
                            
                            if let coordinate = selectedCoordinate {
                                Text("\(coordinate.latitude, specifier: "%.4f"), \(coordinate.longitude, specifier: "%.4f")")
                                    .font(MapdTypography.small)
                                    .foregroundColor(MapdColors.mediumGray)
                            } else {
                                Text("Tap to select location")
                                    .font(MapdTypography.small)
                                    .foregroundColor(MapdColors.mediumGray)
                            }
                        }
                        
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
    }
}

// MARK: - Visit Details Section
struct VisitDetailsSection: View {
    @Binding var isVisited: Bool
    @Binding var dateVisited: Date
    @Binding var rating: Double
    @Binding var isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Visit Details")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            VStack(spacing: MapdSpacing.md) {
                // Visit Status
                HStack(spacing: MapdSpacing.lg) {
                    Button(action: { isVisited = true }) {
                        HStack(spacing: MapdSpacing.sm) {
                            Image(systemName: isVisited ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isVisited ? MapdColors.success : MapdColors.mediumGray)
                            Text("Visited")
                                .font(MapdTypography.body)
                                .foregroundColor(isVisited ? MapdColors.darkText : MapdColors.mediumGray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { isVisited = false }) {
                        HStack(spacing: MapdSpacing.sm) {
                            Image(systemName: !isVisited ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(!isVisited ? MapdColors.warning : MapdColors.mediumGray)
                            Text("Want to Visit")
                                .font(MapdTypography.body)
                                .foregroundColor(!isVisited ? MapdColors.darkText : MapdColors.mediumGray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                
                if isVisited {
                    // Date Visited
                    VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                        Text("Date Visited")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        DatePicker(
                            "Date Visited",
                            selection: $dateVisited,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    }
                    
                    // Rating
                    VStack(alignment: .leading, spacing: MapdSpacing.sm) {
                        Text("Rating")
                            .font(MapdTypography.caption)
                            .foregroundColor(MapdColors.mediumGray)
                        
                        StarRatingView(rating: $rating)
                    }
                }
                
                // Favorite Toggle
                Toggle(isOn: $isFavorite) {
                    HStack(spacing: MapdSpacing.sm) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(isFavorite ? MapdColors.error : MapdColors.mediumGray)
                        Text("Add to Favorites")
                            .font(MapdTypography.body)
                            .foregroundColor(MapdColors.darkText)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: MapdColors.accent))
            }
        }
    }
}

// MARK: - Star Rating View
struct StarRatingView: View {
    @Binding var rating: Double
    
    var body: some View {
        HStack(spacing: MapdSpacing.sm) {
            ForEach(1...5, id: \.self) { star in
                Button(action: {
                    rating = Double(star)
                }) {
                    Image(systemName: Double(star) <= rating ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(Double(star) <= rating ? MapdColors.warning : MapdColors.lightGray)
                }
            }
            
            if rating > 0 {
                Text("\(rating, specifier: "%.0f")/5")
                    .font(MapdTypography.caption)
                    .foregroundColor(MapdColors.mediumGray)
            }
        }
    }
}

// MARK: - Photos Section
struct PhotosSection: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var photoURLs: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Photos")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 5,
                matching: .images
            ) {
                HStack(spacing: MapdSpacing.md) {
                    Image(systemName: "camera")
                        .foregroundColor(MapdColors.accent)
                    
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        Text("Add Photos")
                            .font(MapdTypography.bodyBold)
                            .foregroundColor(MapdColors.darkText)
                        
                        Text("Select up to 5 photos")
                            .font(MapdTypography.small)
                            .foregroundColor(MapdColors.mediumGray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus")
                        .foregroundColor(MapdColors.accent)
                }
                .padding(MapdSpacing.md)
                .background(MapdColors.cardBackground)
                .cornerRadius(MapdRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: MapdRadius.card)
                        .stroke(MapdColors.lightGray, lineWidth: 1, dash: [5])
                )
            }
            
            if !selectedPhotos.isEmpty {
                Text("\(selectedPhotos.count) photo\(selectedPhotos.count == 1 ? "" : "s") selected")
                    .font(MapdTypography.small)
                    .foregroundColor(MapdColors.mediumGray)
            }
        }
    }
}

// MARK: - Notes Section
struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Notes")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            TextField("Add your thoughts, memories, or tips about this place...", text: $notes, axis: .vertical)
                .font(MapdTypography.body)
                .padding(MapdSpacing.md)
                .background(MapdColors.cardBackground)
                .cornerRadius(MapdRadius.input)
                .overlay(
                    RoundedRectangle(cornerRadius: MapdRadius.input)
                        .stroke(MapdColors.lightGray, lineWidth: 1)
                )
                .lineLimit(5...10)
        }
    }
}

// MARK: - Tags Section
struct TagsSection: View {
    @Binding var selectedTags: Set<String>
    @Binding var customTag: String
    let predefinedTags: [String]
    let onAddCustomTag: () -> Void
    let onShowTagInput: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            HStack {
                Text("Tags")
                    .font(MapdTypography.heading2)
                    .foregroundColor(MapdColors.darkText)
                
                Spacer()
                
                Button("Add Custom") {
                    onShowTagInput()
                }
                .font(MapdTypography.caption)
                .foregroundColor(MapdColors.accent)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: MapdSpacing.sm) {
                ForEach(predefinedTags, id: \.self) { tag in
                    TagChip(
                        tag: tag,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                }
                
                // Custom tags
                ForEach(Array(selectedTags.filter { !predefinedTags.contains($0) }), id: \.self) { tag in
                    TagChip(
                        tag: tag,
                        isSelected: true,
                        isCustom: true
                    ) {
                        selectedTags.remove(tag)
                    }
                }
            }
        }
    }
}

struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let isCustom: Bool
    let action: () -> Void
    
    init(tag: String, isSelected: Bool, isCustom: Bool = false, action: @escaping () -> Void) {
        self.tag = tag
        self.isSelected = isSelected
        self.isCustom = isCustom
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MapdSpacing.xs) {
                Text(tag)
                    .font(MapdTypography.small)
                    .lineLimit(1)
                
                if isCustom && isSelected {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, MapdSpacing.sm)
            .padding(.vertical, MapdSpacing.xs)
            .background(isSelected ? MapdColors.accent : MapdColors.cardBackground)
            .foregroundColor(isSelected ? .white : MapdColors.mediumGray)
            .cornerRadius(MapdRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: MapdRadius.button)
                    .stroke(isSelected ? Color.clear : MapdColors.lightGray, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Current Location Helper
struct CurrentLocationHelper: View {
    @ObservedObject var locationManager: LocationManager
    let onUseCurrentLocation: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: MapdSpacing.md) {
            Text("Quick Actions")
                .font(MapdTypography.heading2)
                .foregroundColor(MapdColors.darkText)
            
            Button(action: onUseCurrentLocation) {
                HStack(spacing: MapdSpacing.md) {
                    Image(systemName: "location.fill")
                        .foregroundColor(MapdColors.accent)
                    
                    VStack(alignment: .leading, spacing: MapdSpacing.xs) {
                        Text("Use Current Location")
                            .font(MapdTypography.bodyBold)
                            .foregroundColor(MapdColors.darkText)
                        
                        if let locationName = locationManager.currentLocationName {
                            Text(locationName)
                                .font(MapdTypography.small)
                                .foregroundColor(MapdColors.mediumGray)
                        } else {
                            Text("Fill location details automatically")
                                .font(MapdTypography.small)
                                .foregroundColor(MapdColors.mediumGray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(MapdColors.mediumGray)
                }
                .padding(MapdSpacing.md)
                .background(MapdColors.cardBackground)
                .cornerRadius(MapdRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: MapdRadius.card)
                        .stroke(MapdColors.accent.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: MapdSpacing.md) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Saving place...")
                    .font(MapdTypography.body)
                    .foregroundColor(.white)
            }
            .padding(MapdSpacing.xl)
            .background(Color.black.opacity(0.8))
            .cornerRadius(MapdRadius.card)
        }
    }
}

// MARK: - Location Picker (Placeholder)
struct LocationPickerView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var city: String
    @Binding var country: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Location Picker")
                    .font(MapdTypography.heading1)
                
                Text("Map integration coming soon")
                    .font(MapdTypography.body)
                    .foregroundColor(MapdColors.mediumGray)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Select Location")
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
    AddPlaceView(
        userManager: UserManager(),
        locationManager: LocationManager()
    )
}
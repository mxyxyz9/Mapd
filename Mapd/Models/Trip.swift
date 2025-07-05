//
//  Trip.swift
//  Mapd
//
//  Created by Pala Rushil on 7/5/25.
//

import Foundation

struct Trip: Identifiable, Codable {
    let id = UUID()
    var name: String
    var destination: Place
    var startDate: Date
    var endDate: Date
    var numberOfTravelers: Int
    var tripType: TripType
    var checklist: [ChecklistItem]
    var isCompleted: Bool
    
    init(name: String, destination: Place, startDate: Date, endDate: Date, numberOfTravelers: Int = 1, tripType: TripType = .solo) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.numberOfTravelers = numberOfTravelers
        self.tripType = tripType
        self.checklist = ChecklistItem.generateSmartChecklist(for: destination, tripType: tripType, duration: Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1)
        self.isCompleted = false
    }
    
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
    }
    
    var checklistProgress: Double {
        guard !checklist.isEmpty else { return 0 }
        let completedItems = checklist.filter { $0.isCompleted }.count
        return Double(completedItems) / Double(checklist.count)
    }
    
    var daysUntilDeparture: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? 0
    }
}

enum TripType: String, CaseIterable, Codable {
    case solo = "Solo"
    case couple = "Couple"
    case family = "Family"
    case friends = "Friends"
    
    var icon: String {
        switch self {
        case .solo: return "person.fill"
        case .couple: return "heart.fill"
        case .family: return "house.fill"
        case .friends: return "person.3.fill"
        }
    }
}

struct ChecklistItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var category: ChecklistCategory
    var priority: Priority
    var isCompleted: Bool
    var reminderDate: Date?
    
    init(title: String, category: ChecklistCategory, priority: Priority = .medium, isCompleted: Bool = false, reminderDate: Date? = nil) {
        self.title = title
        self.category = category
        self.priority = priority
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
    }
}

enum ChecklistCategory: String, CaseIterable, Codable {
    case documents = "Documents"
    case health = "Health"
    case packing = "Packing"
    case preparation = "Preparation"
    case activities = "Activities"
    
    var icon: String {
        switch self {
        case .documents: return "doc.text.fill"
        case .health: return "cross.fill"
        case .packing: return "bag.fill"
        case .preparation: return "creditcard.fill"
        case .activities: return "ticket.fill"
        }
    }
    
    var color: String {
        switch self {
        case .documents: return "blue"
        case .health: return "red"
        case .packing: return "green"
        case .preparation: return "orange"
        case .activities: return "purple"
        }
    }
}

enum Priority: String, CaseIterable, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

// MARK: - Smart Checklist Generation
extension ChecklistItem {
    static func generateSmartChecklist(for destination: Place, tripType: TripType, duration: Int) -> [ChecklistItem] {
        var items: [ChecklistItem] = []
        
        // Documents
        items.append(ChecklistItem(title: "Valid Passport", category: .documents, priority: .high))
        items.append(ChecklistItem(title: "Flight Tickets", category: .documents, priority: .high))
        items.append(ChecklistItem(title: "Travel Insurance", category: .documents, priority: .medium))
        
        // International travel requirements
        if destination.country != "USA" {
            items.append(ChecklistItem(title: "Check Visa Requirements", category: .documents, priority: .high))
        }
        
        // Health
        items.append(ChecklistItem(title: "Check Vaccination Requirements", category: .health, priority: .medium))
        items.append(ChecklistItem(title: "Pack Medications", category: .health, priority: .medium))
        
        // Packing based on duration
        if duration <= 3 {
            items.append(ChecklistItem(title: "Pack Light Luggage", category: .packing, priority: .low))
        } else {
            items.append(ChecklistItem(title: "Pack Checked Luggage", category: .packing, priority: .medium))
        }
        
        items.append(ChecklistItem(title: "Weather-appropriate Clothing", category: .packing, priority: .medium))
        items.append(ChecklistItem(title: "Phone Charger", category: .packing, priority: .medium))
        
        // Preparation
        items.append(ChecklistItem(title: "Exchange Currency", category: .preparation, priority: .medium))
        items.append(ChecklistItem(title: "Notify Bank of Travel", category: .preparation, priority: .medium))
        items.append(ChecklistItem(title: "Download Offline Maps", category: .preparation, priority: .low))
        
        // Activities
        items.append(ChecklistItem(title: "Research Local Attractions", category: .activities, priority: .low))
        items.append(ChecklistItem(title: "Book Accommodation", category: .activities, priority: .high))
        
        return items
    }
}

// MARK: - Sample Data
extension Trip {
    static let sampleTrips = [
        Trip(name: "Paris Adventure", destination: Place.samplePlaces[0], startDate: Date().addingTimeInterval(86400 * 30), endDate: Date().addingTimeInterval(86400 * 37), numberOfTravelers: 2, tripType: .couple)
    ]
}
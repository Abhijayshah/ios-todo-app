import Foundation
import EventKit
import Combine

class CalendarService: ObservableObject {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    
    @Published var isAccessGranted = false
    
    private init() {
        checkAccess()
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAccessGranted = granted
            }
        }
    }
    
    func checkAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAccessGranted = (status == .authorized)
    }
    
    func syncTaskToCalendar(title: String, dueDate: Date, notes: String?) {
        guard isAccessGranted else { return }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = dueDate
        event.endDate = dueDate.addingTimeInterval(3600) // Default 1 hour duration
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event saved to calendar")
        } catch {
            print("Error saving event: \(error)")
        }
    }
}

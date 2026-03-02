import Foundation
import CoreData

extension SymptomEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SymptomEntry> {
        return NSFetchRequest<SymptomEntry>(entityName: "SymptomEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var selectedSymptoms: String?
    @NSManaged public var topCondition: String?
    @NSManaged public var urgencyLevel: String?
    @NSManaged public var notes: String?
}

extension SymptomEntry: Identifiable {}


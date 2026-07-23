import Foundation

struct AcademicSubject: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isActive: Bool = true
}

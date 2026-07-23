import Foundation

enum StandardWiseSampleData {
    static let mathSubjectID = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
    static let elaSubjectID = UUID(uuidString: "00000000-0000-0000-0000-000000000102")!
    static let scienceSubjectID = UUID(uuidString: "00000000-0000-0000-0000-000000000103")!

    static let grade6ID = UUID(uuidString: "00000000-0000-0000-0000-000000000206")!
    static let grade7ID = UUID(uuidString: "00000000-0000-0000-0000-000000000207")!
    static let grade8ID = UUID(uuidString: "00000000-0000-0000-0000-000000000208")!
    static let grade9ID = UUID(uuidString: "00000000-0000-0000-0000-000000000209")!

    static let subjects = [
        AcademicSubject(id: mathSubjectID, name: "Math"),
        AcademicSubject(id: elaSubjectID, name: "ELA"),
        AcademicSubject(id: scienceSubjectID, name: "Science")
    ]

    static let grades = [
        GradeLevel(id: grade6ID, name: "6th"),
        GradeLevel(id: grade7ID, name: "7th"),
        GradeLevel(id: grade8ID, name: "8th"),
        GradeLevel(id: grade9ID, name: "9th")
    ]
}

enum LocalPersistence {
    static func load<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }

        return try? JSONDecoder().decode(type, from: data)
    }

    static func save<Value: Encodable>(_ value: Value, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }

        UserDefaults.standard.set(data, forKey: key)
    }
}

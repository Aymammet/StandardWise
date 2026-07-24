import FirebaseFirestore
import Foundation

enum FirebaseStandardsService {
    struct StandardsData {
        let subjects: [AcademicSubject]
        let grades: [GradeLevel]
        let standards: [LearningStandard]
    }

    static func loadStandardsData(
        fallbackSubjects: [AcademicSubject],
        fallbackGrades: [GradeLevel],
        fallbackStandards: [LearningStandard]
    ) async throws -> StandardsData {
        var subjects = try await fetchSubjects()
        var grades = try await fetchGrades()
        var standards = try await fetchStandards()

        if subjects.isEmpty {
            try await saveSubjects(fallbackSubjects)
            subjects = fallbackSubjects
        }

        if grades.isEmpty {
            try await saveGrades(fallbackGrades)
            grades = fallbackGrades
        }

        if standards.isEmpty {
            try await saveStandards(fallbackStandards)
            standards = fallbackStandards
        }

        return StandardsData(
            subjects: subjects.sorted { $0.name < $1.name },
            grades: sortedGrades(grades),
            standards: standards.sorted { $0.code < $1.code }
        )
    }

    static func saveSubject(_ subject: AcademicSubject) async throws {
        try await Firestore.firestore()
            .collection("subjects")
            .document(subject.id.uuidString)
            .setData(
                [
                    "id": subject.id.uuidString,
                    "name": subject.name,
                    "isActive": subject.isActive,
                    "updatedAt": FieldValue.serverTimestamp()
                ],
                merge: true
            )
    }

    static func saveStandard(_ standard: LearningStandard) async throws {
        try await Firestore.firestore()
            .collection("standards")
            .document(standard.id.uuidString)
            .setData(
                [
                    "id": standard.id.uuidString,
                    "subjectID": standard.subjectID.uuidString,
                    "gradeID": standard.gradeID.uuidString,
                    "subjectName": standard.subjectName,
                    "gradeName": standard.gradeName,
                    "code": standard.code,
                    "name": standard.name,
                    "description": standard.description,
                    "isActive": standard.isActive,
                    "updatedAt": FieldValue.serverTimestamp()
                ],
                merge: true
            )
    }

    private static func fetchSubjects() async throws -> [AcademicSubject] {
        let snapshot = try await Firestore.firestore()
            .collection("subjects")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let id = uuid(from: data["id"]) ?? UUID(uuidString: document.documentID),
                let name = data["name"] as? String
            else {
                return nil
            }

            return AcademicSubject(
                id: id,
                name: name,
                isActive: data["isActive"] as? Bool ?? true
            )
        }
    }

    private static func fetchGrades() async throws -> [GradeLevel] {
        let snapshot = try await Firestore.firestore()
            .collection("grades")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let id = uuid(from: data["id"]) ?? UUID(uuidString: document.documentID),
                let name = data["name"] as? String
            else {
                return nil
            }

            return GradeLevel(id: id, name: name)
        }
    }

    private static func fetchStandards() async throws -> [LearningStandard] {
        let snapshot = try await Firestore.firestore()
            .collection("standards")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let id = uuid(from: data["id"]) ?? UUID(uuidString: document.documentID),
                let subjectID = uuid(from: data["subjectID"]),
                let gradeID = uuid(from: data["gradeID"]),
                let subjectName = data["subjectName"] as? String,
                let gradeName = data["gradeName"] as? String,
                let code = data["code"] as? String,
                let name = data["name"] as? String,
                let description = data["description"] as? String
            else {
                return nil
            }

            return LearningStandard(
                id: id,
                subjectID: subjectID,
                gradeID: gradeID,
                subjectName: subjectName,
                gradeName: gradeName,
                code: code,
                name: name,
                description: description,
                isActive: data["isActive"] as? Bool ?? true
            )
        }
    }

    private static func saveSubjects(_ subjects: [AcademicSubject]) async throws {
        for subject in subjects {
            try await saveSubject(subject)
        }
    }

    private static func saveGrades(_ grades: [GradeLevel]) async throws {
        for (index, grade) in grades.enumerated() {
            try await Firestore.firestore()
                .collection("grades")
                .document(grade.id.uuidString)
                .setData(
                    [
                        "id": grade.id.uuidString,
                        "name": grade.name,
                        "sortOrder": index,
                        "updatedAt": FieldValue.serverTimestamp()
                    ],
                    merge: true
                )
        }
    }

    private static func saveStandards(_ standards: [LearningStandard]) async throws {
        for standard in standards {
            try await saveStandard(standard)
        }
    }

    private static func uuid(from value: Any?) -> UUID? {
        guard let string = value as? String else { return nil }
        return UUID(uuidString: string)
    }

    private static func sortedGrades(_ grades: [GradeLevel]) -> [GradeLevel] {
        grades.sorted { first, second in
            gradeNumber(from: first.name) < gradeNumber(from: second.name)
        }
    }

    private static func gradeNumber(from name: String) -> Int {
        Int(name.filter(\.isNumber)) ?? Int.max
    }
}

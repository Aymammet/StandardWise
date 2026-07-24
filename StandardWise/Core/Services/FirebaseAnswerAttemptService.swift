import FirebaseFirestore
import Foundation

enum FirebaseAnswerAttemptService {
    static func loadAttempts() async throws -> [AnswerAttempt] {
        let snapshot = try await Firestore.firestore()
            .collection("answerAttempts")
            .getDocuments()

        return snapshot.documents
            .compactMap { attempt(from: $0) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    static func saveAttempt(_ attempt: AnswerAttempt) async throws {
        try await Firestore.firestore()
            .collection("answerAttempts")
            .document(attempt.id.uuidString)
            .setData(
                [
                    "id": attempt.id.uuidString,
                    "userID": attempt.userID.uuidString,
                    "questionID": attempt.questionID.uuidString,
                    "subjectName": attempt.subjectName,
                    "gradeName": attempt.gradeName,
                    "standardCode": attempt.standardCode,
                    "submittedAnswer": attempt.submittedAnswer,
                    "isCorrect": attempt.isCorrect,
                    "createdAt": Timestamp(date: attempt.createdAt)
                ],
                merge: true
            )
    }

    private static func attempt(from document: QueryDocumentSnapshot) -> AnswerAttempt? {
        let data = document.data()
        guard
            let id = uuid(from: data["id"]) ?? UUID(uuidString: document.documentID),
            let userID = uuid(from: data["userID"]),
            let questionID = uuid(from: data["questionID"]),
            let subjectName = data["subjectName"] as? String,
            let gradeName = data["gradeName"] as? String,
            let standardCode = data["standardCode"] as? String,
            let submittedAnswer = data["submittedAnswer"] as? String,
            let isCorrect = data["isCorrect"] as? Bool
        else {
            return nil
        }

        return AnswerAttempt(
            id: id,
            userID: userID,
            questionID: questionID,
            subjectName: subjectName,
            gradeName: gradeName,
            standardCode: standardCode,
            submittedAnswer: submittedAnswer,
            isCorrect: isCorrect,
            createdAt: dateValue(from: data["createdAt"]) ?? Date()
        )
    }

    private static func uuid(from value: Any?) -> UUID? {
        guard let string = value as? String else { return nil }
        return UUID(uuidString: string)
    }

    private static func dateValue(from value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }

        return value as? Date
    }
}

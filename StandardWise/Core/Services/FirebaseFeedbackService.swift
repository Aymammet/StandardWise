import FirebaseFirestore
import Foundation

enum FirebaseFeedbackService {
    static func loadFeedback() async throws -> [QuestionFeedback] {
        let snapshot = try await Firestore.firestore()
            .collection("feedback")
            .getDocuments()

        return snapshot.documents
            .compactMap { feedback(from: $0) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    static func saveFeedback(_ feedback: QuestionFeedback) async throws {
        try await Firestore.firestore()
            .collection("feedback")
            .document(feedback.id.uuidString)
            .setData(
                [
                    "id": feedback.id.uuidString,
                    "userID": feedback.userID.uuidString,
                    "questionID": feedback.questionID.uuidString,
                    "message": feedback.message,
                    "status": feedback.status.rawValue,
                    "createdAt": Timestamp(date: feedback.createdAt),
                    "updatedAt": FieldValue.serverTimestamp()
                ],
                merge: true
            )
    }

    private static func feedback(from document: QueryDocumentSnapshot) -> QuestionFeedback? {
        let data = document.data()
        guard
            let id = uuid(from: data["id"]) ?? UUID(uuidString: document.documentID),
            let userID = uuid(from: data["userID"]),
            let questionID = uuid(from: data["questionID"]),
            let message = data["message"] as? String
        else {
            return nil
        }

        let statusValue = data["status"] as? String

        return QuestionFeedback(
            id: id,
            userID: userID,
            questionID: questionID,
            message: message,
            status: statusValue.flatMap(FeedbackStatus.init(rawValue:)) ?? .new,
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

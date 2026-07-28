import FirebaseFirestore
import Foundation

enum FirebaseQuestionsService {
    static func loadQuestions(fallbackQuestions: [Question]) async throws -> [Question] {
        var questions = try await fetchQuestions()

        if questions.isEmpty {
            try? await saveQuestions(fallbackQuestions)
            questions = fallbackQuestions
        }

        return questions.sorted { first, second in
            first.updatedAt > second.updatedAt
        }
    }

    static func saveQuestion(_ question: Question) async throws {
        try await Firestore.firestore()
            .collection("questions")
            .document(question.id.uuidString)
            .setData(data(from: question), merge: true)
    }

    private static func fetchQuestions() async throws -> [Question] {
        let snapshot = try await Firestore.firestore()
            .collection("questions")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            question(from: document)
        }
    }

    private static func saveQuestions(_ questions: [Question]) async throws {
        for question in questions {
            try await saveQuestion(question)
        }
    }

    private static func data(from question: Question) -> [String: Any] {
        var data: [String: Any] = [
            "id": question.id.uuidString,
            "subjectID": question.subjectID.uuidString,
            "gradeID": question.gradeID.uuidString,
            "standardID": question.standardID.uuidString,
            "standardCode": question.standardCode,
            "prompt": question.prompt,
            "type": question.type.rawValue,
            "choices": question.choices.map { choice in
                [
                    "id": choice.id,
                    "text": choice.text
                ]
            },
            "correctAnswer": question.correctAnswer,
            "acceptedAlternateAnswers": question.acceptedAlternateAnswers,
            "explanation": question.explanation,
            "isActive": question.isActive,
            "createdAt": Timestamp(date: question.createdAt),
            "updatedAt": Timestamp(date: question.updatedAt)
        ]

        if let difficulty = question.difficulty {
            data["difficulty"] = difficulty
        }

        if let createdByAdminID = question.createdByAdminID {
            data["createdByAdminID"] = createdByAdminID.uuidString
        }

        if let imageBase64 = question.imageBase64 {
            data["imageBase64"] = imageBase64
        }

        return data
    }

    private static func question(from document: QueryDocumentSnapshot) -> Question? {
        let data = document.data()
        guard
            let id = uuid(from: data["id"]) ?? UUID(uuidString: document.documentID),
            let subjectID = uuid(from: data["subjectID"]),
            let gradeID = uuid(from: data["gradeID"]),
            let standardID = uuid(from: data["standardID"]),
            let standardCode = data["standardCode"] as? String,
            let prompt = data["prompt"] as? String,
            let typeValue = data["type"] as? String,
            let type = QuestionType(rawValue: typeValue),
            let correctAnswer = data["correctAnswer"] as? String,
            let explanation = data["explanation"] as? String
        else {
            return nil
        }

        return Question(
            id: id,
            subjectID: subjectID,
            gradeID: gradeID,
            standardID: standardID,
            standardCode: standardCode,
            prompt: prompt,
            type: type,
            choices: choices(from: data["choices"]),
            correctAnswer: correctAnswer,
            acceptedAlternateAnswers: data["acceptedAlternateAnswers"] as? [String] ?? [],
            explanation: explanation,
            difficulty: data["difficulty"] as? String,
            isActive: data["isActive"] as? Bool ?? true,
            createdByAdminID: uuid(from: data["createdByAdminID"]),
            createdAt: dateValue(from: data["createdAt"]) ?? Date(),
            updatedAt: dateValue(from: data["updatedAt"]) ?? Date(),
            imageBase64: data["imageBase64"] as? String
        )
    }

    private static func choices(from value: Any?) -> [AnswerChoice] {
        guard let dictionaries = value as? [[String: Any]] else {
            return []
        }

        return dictionaries.compactMap { dictionary in
            guard
                let id = dictionary["id"] as? String,
                let text = dictionary["text"] as? String
            else {
                return nil
            }

            return AnswerChoice(id: id, text: text)
        }
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

import Foundation
import UIKit

enum QuestionType: String, Codable, CaseIterable, Identifiable {
    case multipleChoice
    case input

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .multipleChoice:
            return "Multiple choice"
        case .input:
            return "Input answer"
        }
    }
}

struct AnswerChoice: Identifiable, Codable, Equatable {
    let id: String
    let text: String
}

struct Question: Identifiable, Codable, Equatable {
    let id: UUID
    let subjectID: UUID
    let gradeID: UUID
    let standardID: UUID
    let standardCode: String
    let prompt: String
    let type: QuestionType
    let choices: [AnswerChoice]
    let correctAnswer: String
    let acceptedAlternateAnswers: [String]
    let explanation: String
    let difficulty: String?
    let isActive: Bool
    let createdByAdminID: UUID?
    let createdAt: Date
    let updatedAt: Date
    /// Base64-encoded JPEG for an optional photo or screenshot attached to the
    /// question (for example a diagram or reading passage). Kept small enough
    /// (resized and compressed on the admin device) to fit inside a single
    /// Firestore document alongside the rest of the question's fields.
    let imageBase64: String?

    init(
        id: UUID = UUID(),
        subjectID: UUID,
        gradeID: UUID,
        standardID: UUID,
        standardCode: String,
        prompt: String,
        type: QuestionType,
        choices: [AnswerChoice] = [],
        correctAnswer: String,
        acceptedAlternateAnswers: [String] = [],
        explanation: String,
        difficulty: String? = nil,
        isActive: Bool = true,
        createdByAdminID: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        imageBase64: String? = nil
    ) {
        self.id = id
        self.subjectID = subjectID
        self.gradeID = gradeID
        self.standardID = standardID
        self.standardCode = standardCode
        self.prompt = prompt
        self.type = type
        self.choices = choices
        self.correctAnswer = correctAnswer
        self.acceptedAlternateAnswers = acceptedAlternateAnswers
        self.explanation = explanation
        self.difficulty = difficulty
        self.isActive = isActive
        self.createdByAdminID = createdByAdminID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageBase64 = imageBase64
    }

    /// Decodes `imageBase64` into a displayable image, or `nil` if there is no
    /// attached photo or the stored data can't be decoded.
    var attachedImage: UIImage? {
        guard let imageBase64, let data = Data(base64Encoded: imageBase64) else { return nil }
        return UIImage(data: data)
    }
}

import Foundation

enum ProblemGenerator {
    static func generate(
        subject: String,
        grade: String,
        standardCode: String,
        questions: [Question] = QuestionBank.sampleQuestions,
        standards: [LearningStandard] = LearningStandard.sampleStandards
    ) -> Question? {
        QuestionBank
            .questions(
                in: questions,
                standards: standards,
                subject: subject,
                grade: grade,
                standardCode: standardCode
            )
            .randomElement()
    }
}

import Foundation

enum ProblemGenerator {
    static func generate(
        subject: String,
        grade: String,
        standardCode: String,
        questions: [Question] = QuestionBank.sampleQuestions
    ) -> Question? {
        QuestionBank
            .questions(
                in: questions,
                subject: subject,
                grade: grade,
                standardCode: standardCode
            )
            .randomElement()
    }
}

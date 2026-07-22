import Foundation

enum ProblemGenerator {
    static func generate(subject: String, grade: String, standardCode: String) -> Question? {
        QuestionBank
            .questions(subject: subject, grade: grade, standardCode: standardCode)
            .randomElement()
    }
}

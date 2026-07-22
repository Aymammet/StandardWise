import Foundation

enum QuestionBank {
    static let sampleQuestions: [Question] = [
        inputQuestion(
            standardCode: "6.RP.1",
            prompt: "A recipe uses 3 cups of flour for every 2 cups of sugar. What is the ratio of flour to sugar?",
            correctAnswer: "3:2",
            alternateAnswers: ["3 to 2"],
            explanation: "A ratio compares two quantities. The recipe has 3 cups of flour and 2 cups of sugar, so the ratio of flour to sugar is 3 to 2."
        ),
        multipleChoiceQuestion(
            standardCode: "6.RP.1",
            prompt: "There are 8 red marbles and 12 blue marbles in a bag. What is the ratio of red marbles to blue marbles in simplest form?",
            choices: [
                AnswerChoice(id: "A", text: "8:12"),
                AnswerChoice(id: "B", text: "2:3"),
                AnswerChoice(id: "C", text: "3:2"),
                AnswerChoice(id: "D", text: "12:8")
            ],
            correctAnswer: "B",
            explanation: "The ratio 8:12 can be simplified by dividing both numbers by 4. That gives 2:3."
        ),
        inputQuestion(
            standardCode: "6.EE.3a",
            prompt: "Use the distributive property to rewrite 4(x + 5).",
            correctAnswer: "4x + 20",
            alternateAnswers: ["20 + 4x"],
            explanation: "Multiply 4 by each term inside the parentheses: 4 times x is 4x, and 4 times 5 is 20."
        ),
        multipleChoiceQuestion(
            standardCode: "6.EE.3a",
            prompt: "Which expression is equivalent to 3(y + 6)?",
            choices: [
                AnswerChoice(id: "A", text: "3y + 6"),
                AnswerChoice(id: "B", text: "y + 18"),
                AnswerChoice(id: "C", text: "3y + 18"),
                AnswerChoice(id: "D", text: "18y")
            ],
            correctAnswer: "C",
            explanation: "Use the distributive property: 3 times y is 3y, and 3 times 6 is 18."
        ),
        inputQuestion(
            standardCode: "RL.6.1",
            prompt: "Read a short passage and identify one detail that supports the main character's decision.",
            correctAnswer: "Answers will vary based on the passage.",
            explanation: "Students should quote or paraphrase evidence from the text and explain how it supports their answer."
        ),
        inputQuestion(
            standardCode: "7.RP.2",
            prompt: "A cyclist travels 18 miles in 3 hours. If the speed stays the same, how far will the cyclist travel in 5 hours?",
            correctAnswer: "30 miles",
            alternateAnswers: ["30"],
            explanation: "The unit rate is 18 divided by 3, or 6 miles per hour. In 5 hours, the cyclist travels 6 times 5, which is 30 miles."
        ),
        multipleChoiceQuestion(
            standardCode: "7.RP.2",
            prompt: "A table shows a proportional relationship. If x = 4 when y = 20, what is the constant of proportionality?",
            choices: [
                AnswerChoice(id: "A", text: "4"),
                AnswerChoice(id: "B", text: "5"),
                AnswerChoice(id: "C", text: "16"),
                AnswerChoice(id: "D", text: "20")
            ],
            correctAnswer: "B",
            explanation: "For a proportional relationship, y = kx. Divide 20 by 4 to get k = 5."
        ),
        inputQuestion(
            standardCode: "RL.7.2",
            prompt: "After reading a story, identify its theme and explain how two events from the story develop that theme.",
            correctAnswer: "Answers will vary based on the story.",
            explanation: "A strong response names a theme and connects it to specific events that show how the theme grows across the text."
        ),
        inputQuestion(
            standardCode: "8.EE.5",
            prompt: "A line representing a proportional relationship passes through (0, 0) and (4, 10). What is the slope?",
            correctAnswer: "2.5",
            alternateAnswers: ["5/2"],
            explanation: "Slope is rise over run. From (0, 0) to (4, 10), the rise is 10 and the run is 4, so the slope is 10 divided by 4, or 2.5."
        ),
        inputQuestion(
            standardCode: "RI.8.1",
            prompt: "Read an informational paragraph and cite one sentence that best supports the author's claim.",
            correctAnswer: "Answers will vary based on the paragraph.",
            explanation: "The evidence should directly support the claim, and the explanation should connect the quoted or paraphrased sentence back to the author's point."
        )
    ]

    static func questions(subject: String, grade: String, standardCode: String) -> [Question] {
        sampleQuestions.filter { question in
            question.isActive
                && question.standardCode == standardCode
                && questionSubjectName(question) == subject
                && questionGradeName(question) == grade
        }
    }

    private static func inputQuestion(
        standardCode: String,
        prompt: String,
        correctAnswer: String,
        alternateAnswers: [String] = [],
        explanation: String
    ) -> Question {
        makeQuestion(
            standardCode: standardCode,
            prompt: prompt,
            type: .input,
            correctAnswer: correctAnswer,
            acceptedAlternateAnswers: alternateAnswers,
            explanation: explanation
        )
    }

    private static func multipleChoiceQuestion(
        standardCode: String,
        prompt: String,
        choices: [AnswerChoice],
        correctAnswer: String,
        explanation: String
    ) -> Question {
        makeQuestion(
            standardCode: standardCode,
            prompt: prompt,
            type: .multipleChoice,
            choices: choices,
            correctAnswer: correctAnswer,
            explanation: explanation
        )
    }

    private static func makeQuestion(
        standardCode: String,
        prompt: String,
        type: QuestionType,
        choices: [AnswerChoice] = [],
        correctAnswer: String,
        acceptedAlternateAnswers: [String] = [],
        explanation: String
    ) -> Question {
        let standard = LearningStandard.sampleStandards.first { $0.code == standardCode }

        return Question(
            subjectID: standard?.subjectID ?? StandardWiseSampleData.mathSubjectID,
            gradeID: standard?.gradeID ?? StandardWiseSampleData.grade6ID,
            standardID: standard?.id ?? UUID(),
            standardCode: standardCode,
            prompt: prompt,
            type: type,
            choices: choices,
            correctAnswer: correctAnswer,
            acceptedAlternateAnswers: acceptedAlternateAnswers,
            explanation: explanation
        )
    }

    private static func questionSubjectName(_ question: Question) -> String {
        LearningStandard.sampleStandards.first { $0.id == question.standardID }?.subjectName ?? ""
    }

    private static func questionGradeName(_ question: Question) -> String {
        LearningStandard.sampleStandards.first { $0.id == question.standardID }?.gradeName ?? ""
    }
}

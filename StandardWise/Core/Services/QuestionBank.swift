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
        ),
        multipleChoiceQuestion(
            standardCode: "6.PS.1",
            prompt: "In which state of matter are the particles close together but still able to slide past each other?",
            choices: [
                AnswerChoice(id: "A", text: "Solid"),
                AnswerChoice(id: "B", text: "Liquid"),
                AnswerChoice(id: "C", text: "Gas"),
                AnswerChoice(id: "D", text: "Plasma")
            ],
            correctAnswer: "B",
            explanation: "In a liquid, particles stay close together but can move and slide past one another, which lets a liquid flow and take the shape of its container."
        ),
        inputQuestion(
            standardCode: "6.PS.1",
            prompt: "What are the small particles that make up all matter called?",
            correctAnswer: "atoms",
            alternateAnswers: ["atom"],
            explanation: "All matter is made up of very small particles called atoms."
        ),
        multipleChoiceQuestion(
            standardCode: "7.LS.1",
            prompt: "In a food chain, which organisms use sunlight to make their own food?",
            choices: [
                AnswerChoice(id: "A", text: "Producers"),
                AnswerChoice(id: "B", text: "Consumers"),
                AnswerChoice(id: "C", text: "Decomposers"),
                AnswerChoice(id: "D", text: "Predators")
            ],
            correctAnswer: "A",
            explanation: "Producers, such as plants and algae, use sunlight to make their own food through photosynthesis. Energy then flows to consumers that eat them."
        ),
        inputQuestion(
            standardCode: "A1.SSE.1",
            prompt: "In the expression 5x + 12, what is the coefficient of x?",
            correctAnswer: "5",
            explanation: "A coefficient is the number multiplied by a variable. In 5x + 12, the variable x is multiplied by 5."
        ),
        multipleChoiceQuestion(
            standardCode: "A1.SSE.1",
            prompt: "In the expression 3x^2 + 7x + 4, which term is the constant?",
            choices: [
                AnswerChoice(id: "A", text: "3x^2"),
                AnswerChoice(id: "B", text: "7x"),
                AnswerChoice(id: "C", text: "4"),
                AnswerChoice(id: "D", text: "x")
            ],
            correctAnswer: "C",
            explanation: "A constant is a term without a variable. In 3x^2 + 7x + 4, the term 4 does not change when x changes."
        ),
        inputQuestion(
            standardCode: "RL.9-10.1",
            prompt: "After reading a story, cite one piece of strong textual evidence that supports an inference about a character's motivation.",
            correctAnswer: "Answers will vary based on the story.",
            explanation: "A strong response quotes or paraphrases a specific moment from the text and explains how it supports the inference about the character."
        )
    ]

    static func questions(
        in sourceQuestions: [Question] = sampleQuestions,
        standards: [LearningStandard] = LearningStandard.sampleStandards,
        subject: String,
        grade: String,
        standardCode: String
    ) -> [Question] {
        sourceQuestions.filter { question in
            let standard = standards.first { $0.id == question.standardID }
                ?? standards.first { $0.code == question.standardCode }

            return question.isActive
                && question.standardCode == standardCode
                && standard?.subjectName == subject
                && standard?.gradeName == grade
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

}

@MainActor
final class QuestionStore: ObservableObject {
    @Published private(set) var questions: [Question] {
        didSet {
            LocalPersistence.save(questions, forKey: storageKey)
        }
    }
    @Published private(set) var syncStatusMessage: String?

    private let storageKey = "standardwise.questions"
    private let usesFirebaseQuestions = StandardWiseAuthMode.current == .staging

    /// IDs of questions edited locally that have not confirmed a Firebase save
    /// yet. Firebase refreshes keep the local copy for these IDs so an
    /// in-flight edit is not overwritten by stale remote data.
    private var pendingSyncQuestionIDs: Set<UUID> = []

    init(questions: [Question] = QuestionBank.sampleQuestions) {
        if let savedQuestions = LocalPersistence.load([Question].self, forKey: storageKey) {
            self.questions = savedQuestions
        } else {
            self.questions = questions
            LocalPersistence.save(questions, forKey: storageKey)
        }

        mergeMissingSampleQuestions(questions)

        if usesFirebaseQuestions {
            syncStatusMessage = "Syncing questions from Firebase..."
            Task {
                await loadFirebaseQuestions(fallbackQuestions: questions)
            }
        }
    }

    /// Appends sample questions missing from persisted local data so existing
    /// installs pick up newly added sample content. Sample question IDs are
    /// regenerated each launch, so matching uses standard code plus prompt.
    private func mergeMissingSampleQuestions(_ sampleQuestions: [Question]) {
        for question in sampleQuestions where !questions.contains(where: {
            $0.standardCode == question.standardCode && $0.prompt == question.prompt
        }) {
            questions.append(question)
        }

        LocalPersistence.save(questions, forKey: storageKey)
    }

    var activeQuestions: [Question] {
        questions.filter(\.isActive)
    }

    func save(_ question: Question) {
        if let index = questions.firstIndex(where: { $0.id == question.id }) {
            questions[index] = question
        } else {
            questions.insert(question, at: 0)
        }

        pendingSyncQuestionIDs.insert(question.id)
        syncQuestionToFirebase(question)
    }

    func archive(_ question: Question) {
        let archivedQuestion = Question(
            id: question.id,
            subjectID: question.subjectID,
            gradeID: question.gradeID,
            standardID: question.standardID,
            standardCode: question.standardCode,
            prompt: question.prompt,
            type: question.type,
            choices: question.choices,
            correctAnswer: question.correctAnswer,
            acceptedAlternateAnswers: question.acceptedAlternateAnswers,
            explanation: question.explanation,
            difficulty: question.difficulty,
            isActive: false,
            createdByAdminID: question.createdByAdminID,
            createdAt: question.createdAt,
            updatedAt: Date(),
            imageBase64: question.imageBase64
        )

        save(archivedQuestion)
    }

    func refreshFromFirebaseIfNeeded() async {
        guard usesFirebaseQuestions else { return }
        await loadFirebaseQuestions(fallbackQuestions: questions)
    }

    private func loadFirebaseQuestions(fallbackQuestions: [Question]) async {
        do {
            var remoteQuestions = try await FirebaseQuestionsService.loadQuestions(
                fallbackQuestions: fallbackQuestions
            )

            // Keep local versions of questions with unsynced edits.
            for pendingID in pendingSyncQuestionIDs {
                guard let localQuestion = questions.first(where: { $0.id == pendingID }) else { continue }

                if let index = remoteQuestions.firstIndex(where: { $0.id == pendingID }) {
                    remoteQuestions[index] = localQuestion
                } else {
                    remoteQuestions.insert(localQuestion, at: 0)
                }
            }

            questions = remoteQuestions
            syncStatusMessage = "Questions are synced with Firebase."
        } catch {
            syncStatusMessage = "Using local questions because Firebase is unavailable."
        }
    }

    private func syncQuestionToFirebase(_ question: Question) {
        guard usesFirebaseQuestions else { return }

        Task {
            do {
                try await FirebaseQuestionsService.saveQuestion(question)
                pendingSyncQuestionIDs.remove(question.id)
                syncStatusMessage = "Question saved to Firebase."
            } catch {
                syncStatusMessage = "Question saved locally. Firebase sync failed."
            }
        }
    }
}

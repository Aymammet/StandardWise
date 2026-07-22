import SwiftUI

struct PracticeView: View {
    @State private var selectedGrade = "6th"
    @State private var selectedSubject = "Math"
    @State private var selectedStandardCode = "6.RP.1"
    @State private var currentProblem: Question?
    @State private var emptyMessage = "Choose a grade, subject, and standard, then tap Generate."

    private let grades = StandardWiseSampleData.grades.map(\.name)
    private let subjects = StandardWiseSampleData.subjects.map(\.name)
    private let standards = LearningStandard.sampleStandards

    private var filteredStandards: [LearningStandard] {
        standards.filter { standard in
            standard.gradeName == selectedGrade && standard.subjectName == selectedSubject
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Generate practice problems by Ohio standard.")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Picker("Grade", selection: $selectedGrade) {
                            ForEach(grades, id: \.self) { grade in
                                Text(grade).tag(grade)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedGrade) { _, _ in
                            selectedStandardCode = filteredStandards.first?.code ?? ""
                            currentProblem = nil
                            emptyMessage = "Choose a grade, subject, and standard, then tap Generate."
                        }

                        Picker("Subject", selection: $selectedSubject) {
                            ForEach(subjects, id: \.self) { subject in
                                Text(subject).tag(subject)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedSubject) { _, _ in
                            selectedStandardCode = filteredStandards.first?.code ?? ""
                            currentProblem = nil
                            emptyMessage = "Choose a grade, subject, and standard, then tap Generate."
                        }

                        Picker("Standard", selection: $selectedStandardCode) {
                            ForEach(filteredStandards) { standard in
                                Text(standard.displayName)
                                    .tag(standard.code)
                            }
                        }
                        .pickerStyle(.menu)

                        Button {
                            currentProblem = ProblemGenerator.generate(
                                subject: selectedSubject,
                                grade: selectedGrade,
                                standardCode: selectedStandardCode
                            )
                            emptyMessage = "No questions are available for this standard yet."
                        } label: {
                            Text("Generate")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedStandardCode.isEmpty)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))

                    if let problem = currentProblem {
                        ProblemCard(problem: problem)
                    } else {
                        EmptyProblemView(message: emptyMessage)
                    }
                }
                .padding()
            }
            .navigationTitle("StandardWise")
        }
    }
}

private struct ProblemCard: View {
    let problem: Question
    @State private var showsAnswer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(problem.standardCode)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)

                Text(problem.prompt)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            if problem.type == .multipleChoice {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(problem.choices) { choice in
                        Text("\(choice.id). \(choice.text)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                    }
                }
            }

            Button(showsAnswer ? "Hide Answer" : "Show Answer") {
                showsAnswer.toggle()
            }
            .buttonStyle(.bordered)

            if showsAnswer {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Answer")
                        .font(.headline)
                    Text(problem.correctAnswer)

                    Text("Steps")
                        .font(.headline)
                        .padding(.top, 4)
                    Text(problem.explanation)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        .shadow(
            color: StandardWiseTheme.cardShadowColor,
            radius: StandardWiseTheme.cardShadowRadius,
            y: StandardWiseTheme.cardShadowYOffset
        )
    }
}

private struct EmptyProblemView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ready when you are")
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }
}

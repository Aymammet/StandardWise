import SwiftUI

struct ContentView: View {
    @State private var selectedGrade = "6th"
    @State private var selectedSubject = "Math"
    @State private var selectedStandardCode = "6.RP.1"
    @State private var currentProblem: PracticeProblem?

    private let grades = ["6th", "7th", "8th"]
    private let subjects = ["Math", "ELA"]
    private let standards = OhioStandard.sampleStandards

    private var filteredStandards: [OhioStandard] {
        standards.filter { standard in
            standard.grade == selectedGrade && standard.subject == selectedSubject
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
                        }

                        Picker("Standard", selection: $selectedStandardCode) {
                            ForEach(filteredStandards) { standard in
                                Text("\(standard.code): \(standard.shortDescription)")
                                    .tag(standard.code)
                            }
                        }
                        .pickerStyle(.menu)

                        Button {
                            currentProblem = ProblemGenerator.generate(
                                subject: selectedSubject,
                                standardCode: selectedStandardCode
                            )
                        } label: {
                            Text("Generate")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    if let problem = currentProblem {
                        ProblemCard(problem: problem)
                    } else {
                        EmptyProblemView()
                    }
                }
                .padding()
            }
            .navigationTitle("StandardWise")
        }
    }
}

private struct ProblemCard: View {
    let problem: PracticeProblem
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

            Button(showsAnswer ? "Hide Answer" : "Show Answer") {
                showsAnswer.toggle()
            }
            .buttonStyle(.bordered)

            if showsAnswer {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Answer")
                        .font(.headline)
                    Text(problem.answer)

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
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

private struct EmptyProblemView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ready when you are")
                .font(.headline)
            Text("Choose a grade, subject, and standard, then tap Generate.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

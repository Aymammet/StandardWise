import Foundation

struct OhioStandard: Identifiable {
    let id = UUID()
    let grade: String
    let subject: String
    let code: String
    let shortDescription: String

    static let sampleStandards = [
        OhioStandard(
            grade: "6th",
            subject: "Math",
            code: "6.RP.1",
            shortDescription: "Understand ratio concepts"
        ),
        OhioStandard(
            grade: "6th",
            subject: "Math",
            code: "6.EE.3a",
            shortDescription: "Apply properties to equivalent expressions"
        ),
        OhioStandard(
            grade: "6th",
            subject: "ELA",
            code: "RL.6.1",
            shortDescription: "Cite textual evidence"
        ),
        OhioStandard(
            grade: "7th",
            subject: "Math",
            code: "7.RP.2",
            shortDescription: "Recognize proportional relationships"
        ),
        OhioStandard(
            grade: "7th",
            subject: "ELA",
            code: "RL.7.2",
            shortDescription: "Determine theme or central idea"
        ),
        OhioStandard(
            grade: "8th",
            subject: "Math",
            code: "8.EE.5",
            shortDescription: "Graph proportional relationships"
        ),
        OhioStandard(
            grade: "8th",
            subject: "ELA",
            code: "RI.8.1",
            shortDescription: "Cite textual evidence from informational text"
        )
    ]
}

import Foundation

enum ProblemGenerator {
    static func generate(subject: String, standardCode: String) -> PracticeProblem {
        switch standardCode {
        case "6.RP.1":
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "A recipe uses 3 cups of flour for every 2 cups of sugar. What is the ratio of flour to sugar?",
                answer: "3:2",
                explanation: "A ratio compares two quantities. The recipe has 3 cups of flour and 2 cups of sugar, so the ratio of flour to sugar is 3 to 2."
            )
        case "6.EE.3a":
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "Use the distributive property to rewrite 4(x + 5).",
                answer: "4x + 20",
                explanation: "Multiply 4 by each term inside the parentheses: 4 times x is 4x, and 4 times 5 is 20."
            )
        case "RL.6.1":
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "Read a short passage and identify one detail that supports the main character's decision.",
                answer: "Answers will vary based on the passage.",
                explanation: "Students should quote or paraphrase evidence from the text and explain how it supports their answer."
            )
        case "7.RP.2":
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "A cyclist travels 18 miles in 3 hours. If the speed stays the same, how far will the cyclist travel in 5 hours?",
                answer: "30 miles",
                explanation: "The unit rate is 18 divided by 3, or 6 miles per hour. In 5 hours, the cyclist travels 6 times 5, which is 30 miles."
            )
        case "RL.7.2":
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "After reading a story, identify its theme and explain how two events from the story develop that theme.",
                answer: "Answers will vary based on the story.",
                explanation: "A strong response names a theme and connects it to specific events that show how the theme grows across the text."
            )
        case "8.EE.5":
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "A line representing a proportional relationship passes through (0, 0) and (4, 10). What is the slope?",
                answer: "2.5",
                explanation: "Slope is rise over run. From (0, 0) to (4, 10), the rise is 10 and the run is 4, so the slope is 10 divided by 4, or 2.5."
            )
        case "RI.8.1":
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "Read an informational paragraph and cite one sentence that best supports the author's claim.",
                answer: "Answers will vary based on the paragraph.",
                explanation: "The evidence should directly support the claim, and the explanation should connect the quoted or paraphrased sentence back to the author's point."
            )
        default:
            return PracticeProblem(
                standardCode: standardCode,
                prompt: "Create a practice task aligned to \(subject) standard \(standardCode).",
                answer: "Sample answer depends on the selected standard.",
                explanation: "This placeholder can be replaced as the standards library grows."
            )
        }
    }
}

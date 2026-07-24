# StandardWise QA Checklist

This checklist tracks the main workflows that should be checked before each larger change or commit.

## Latest Check

- Date: July 24, 2026
- Local build: Passed
- Staging build: Passed
- Simulator launch smoke test: Passed
- Automated test target: Not available yet

## Login

- [x] App launches to the login screen in the simulator.
- [ ] Local admin login opens the admin dashboard.
- [ ] Local regular-user login opens the practice screen.
- [ ] Local missing username shows `No username exists.`
- [ ] Local wrong password shows `Wrong password.`
- [ ] Staging admin login opens the admin dashboard.
- [ ] Staging regular-user login opens the practice screen.
- [ ] Staging missing username behavior is verified after Firestore `users` records are seeded.
- [ ] Staging wrong password behavior is verified after Firestore `users` records are seeded.

## Student Practice

- [ ] Subject dropdown shows available subjects.
- [ ] Grade dropdown shows available grades.
- [ ] Standard dropdown filters by selected subject and grade.
- [ ] Generate Question shows a matching question.
- [ ] Generate Question handles empty states when no question exists.
- [ ] Multiple-choice answers can be selected.
- [ ] Multiple-choice correct answer highlights correctly.
- [ ] Multiple-choice incorrect answer highlights selected wrong answer and correct answer.
- [ ] Typed-answer questions accept input.
- [ ] Typed-answer checking supports accepted alternate answers.
- [ ] Check Answer button is full width and disabled until an answer is entered.

## Feedback

- [ ] Regular user can open Send Feedback.
- [ ] Regular user can submit feedback for the current question.
- [ ] Admin can view submitted feedback.
- [ ] Admin can update feedback status.

## Admin

- [ ] Admin can view dashboard metric cards.
- [ ] Admin can open Questions.
- [ ] Admin can add a multiple-choice question.
- [ ] Admin can add a typed-answer question.
- [ ] Admin can edit an existing question.
- [ ] Admin can archive a question.
- [ ] Admin can search and filter questions.
- [ ] Admin can open Standards.
- [ ] Admin can add a subject.
- [ ] Admin can edit a subject.
- [ ] Admin can add a standard.
- [ ] Admin can edit a standard.
- [ ] Admin can archive subjects and standards.
- [ ] Admin can open Users.
- [ ] Admin can open Analytics.

## Known Gaps

- There is no automated test target yet.
- Staging username-specific login messages depend on Firestore `users` documents being created for Firebase Auth users.
- Staging still uses local app data for subjects, standards, questions, feedback, answer attempts, and analytics.

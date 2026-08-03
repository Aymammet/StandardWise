# StandardWise QA Checklist

This checklist tracks the main workflows that should be checked before each larger change or commit.

## Latest Check

- Date: July 28, 2026
- Local build: Passed with `CODE_SIGNING_ALLOWED=NO`
- Staging build: Passed with `CODE_SIGNING_ALLOWED=NO`
- Simulator launch smoke test: Not rerun
- Firestore rules deploy: Passed for project `standardwise-15a83`
- Firestore rules emulator smoke test: Blocked because Java is not installed
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
- [ ] Staging create-account flow sends an email activation link.
- [ ] Staging unverified regular-user login is blocked with the activation reminder.
- [ ] Staging Resend activation email sends another activation message.
- [ ] Staging verified regular-user login succeeds after clicking the activation link.
- [ ] Staging forgot-password flow sends a reset email.

## Auth Email Deliverability

- [ ] Password reset screen tells users to check Inbox, Spam, Junk, or Promotions.
- [ ] Activation email messages tell users to check Inbox, Spam, Junk, or Promotions.
- [ ] Gmail test: record whether activation email lands in Inbox, Spam, or Promotions.
- [ ] Gmail test: record whether password reset email lands in Inbox, Spam, or Promotions.
- [ ] iCloud test: record whether activation and reset emails land in Inbox or Junk.
- [ ] Outlook/Hotmail test: record whether activation and reset emails land in Inbox or Junk.
- [ ] School email test, if available: record whether activation and reset emails arrive or are filtered.
- [ ] Firebase Authentication email templates have StandardWise sender name, subject, and wording.
- [ ] Firebase Authentication custom sender domain is reviewed for production.
- [ ] If a custom sender domain is used, required Firebase DNS records are added and verified.

## Firebase Rules

- [x] `firestore.rules` deploys successfully to `standardwise-15a83`.
- [x] Firebase CLI reports `firestore.rules` compiles successfully.
- [ ] Admin can create/update a question with optional `imageBase64` in Staging.
- [ ] Regular user can read questions in Staging.
- [ ] Regular user cannot create/update questions in Staging.
- [ ] Regular user can create feedback for their own profile in Staging.
- [ ] Regular user cannot read the admin feedback collection in Staging.
- [ ] Admin can read feedback and update feedback status in Staging.

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
- [ ] Admin can see the submitting student's name and email on each feedback item.
- [ ] Admin can update feedback status.

## Admin

- [ ] Admin can view dashboard metric cards.
- [ ] Admin can open Questions.
- [ ] Admin can add a multiple-choice question.
- [ ] Admin can add a typed-answer question.
- [ ] Admin can attach a photo from the photo library when adding or editing a question.
- [ ] Attached question photos preview before saving.
- [ ] Attached question photos display in the student practice session.
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
- Local Firestore rules emulator testing is blocked until Java is installed.
- Physical-device testing is still needed for photo-library permissions and image picking.
- Staging username-specific login messages depend on Firestore `users` documents being created for Firebase Auth users.
- Updated Firestore rules for question images are deployed but still need real Staging app workflow testing.

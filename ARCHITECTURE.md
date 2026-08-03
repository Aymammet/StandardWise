# StandardWise Architecture

How the app is put together, where data lives, and the rules that keep local
and cloud data consistent. Update this file when the store pattern, schemas,
or sync rules change.

## App modes

The active mode comes from the `STANDARDWISE_AUTH_MODE` environment variable,
set per scheme (`StandardWiseEnvironment.swift`). It defaults to `staging`
when unset.

| Scheme | Mode | Auth | Data |
| --- | --- | --- | --- |
| StandardWise Local | `local` | Sample accounts (`admin@standardwise.app` / `admin123`, `student@standardwise.app` / `student123`) | On-device only |
| StandardWise Staging | `staging` | Firebase Authentication (email/password, email verification, Sign in with Apple) | On-device first, synced with Firestore |

## Source layout

```
StandardWise/
  StandardWiseApp.swift        App entry; FirebaseApp.configure()
  RootView.swift               Owns the stores; routes by role after login
  Core/
    Models/                    Value types + their stores
      StandardWiseUser.swift   User + UserRole (admin/regular)
      LearningStandard.swift   Standard model + StandardStore
      Question.swift           Question, QuestionType, AnswerChoice
      AnswerAttempt.swift      Attempt model + AnswerAttemptStore
      QuestionFeedback.swift   Feedback model + FeedbackStore
      StandardWiseSampleData.swift  Stable sample IDs + LocalPersistence
    Services/
      LocalAuthService.swift   Login/register/reset for both modes
      Firebase*.swift          One service enum per Firestore collection group
      QuestionBank.swift       Sample questions + QuestionStore
      ProblemGenerator.swift   (legacy) question selection helper
    Session/AppSession.swift   Login state + user-facing auth error mapping
    DesignSystem/StandardWiseTheme.swift  Brand colors, button/field styles,
                               haptics, sign-out button
    Features/
    Auth/LoginView.swift       Sign in / create account / reset / Apple sign-in
    Practice/PracticeView.swift  Student home, generated-question practice,
                               Today summary
    Admin/AdminDashboardView.swift  Dashboard + all admin pages (questions,
                               standards, users, feedback, analytics)
```

## Data flow and the store pattern

Four `ObservableObject` stores are created once in `RootView` and injected
into feature views: `QuestionStore`, `StandardStore`, `FeedbackStore`, and
`AnswerAttemptStore`.

Every store follows the same rules:

1. **Local first.** State loads from `UserDefaults` (via `LocalPersistence`)
   at init and every mutation persists back immediately. The app is fully
   usable offline.
2. **Sample-data merge.** At init, sample subjects, grades, standards, and
   questions that are missing from persisted data are appended (matched by
   name/code/prompt, never by ID, because sample IDs regenerate each launch).
   Admin-edited or archived entries are not duplicated or resurrected.
3. **Staging sync.** In staging mode, reads pull the full collection from
   Firestore after login (`refreshFromFirebaseIfNeeded`), and writes save
   locally first, then push to Firestore in a background task.
4. **Pending-edit protection.** Each store keeps a `pendingSync*IDs` set of
   locally edited IDs whose Firebase save has not confirmed. A Firestore
   refresh keeps the local copy for those IDs so stale remote data cannot
   overwrite an in-flight edit.
5. **Role-gated reads.** `feedback` and `answerAttempts` are admin-only
   readable under the security rules, so `RootView` only refreshes those two
   stores for admin users. Students still create attempts and feedback (writes
   are allowed).

## Authentication

- `LocalAuthService.authenticate` branches on mode: local checks sample
  credentials; staging signs in with Firebase Auth, verifies the user's email
  for regular email/password accounts, then loads the user's Firestore profile
  via `FirebaseUserService.userProfile` (creating one on first sign-in, with a
  deterministic UUID derived from the Firebase UID as a fallback).
- Registration collects first name, last name, email, and password. Staging
  creates the Firebase Auth account, writes the matching Firestore user
  profile, sends the email activation link, signs the user back out, and
  returns them to the sign-in screen with a "check your email" message.
- Unverified regular users are blocked at sign-in until the activation link is
  used. The sign-in screen can resend the activation email after the user
  re-enters the email and password.
- Password reset uses Firebase's reset-email flow in staging and shows
  guidance to check Inbox, Spam, Junk, or Promotions.
- Sign in with Apple uses Apple's native sign-in button, secure nonce
  generation, Firebase's Apple OAuth credential flow, and regular-user profile
  creation/fallback. Apple Developer and Firebase provider setup are still
  required before production use.
- Role routing happens in `RootView`: admins get `AdminDashboardView`,
  regular users get `PracticeView`.
- `admin@standardwise.app` is a bootstrap admin (hard-coded in
  `LocalAuthService.adminEmails` and mirrored in the security rules) so the
  first admin cannot be locked out before profiles are seeded.

## Firestore schema

Document IDs are the model's UUID string unless noted.

| Collection | Doc ID | Fields |
| --- | --- | --- |
| `users` | lowercased email | `id` (UUID), `firebaseUID`, `name`, `email`, `emailLowercase`, `role` (`admin`\|`regular`), `createdAt`, `lastActiveAt`, `updatedAt` |
| `subjects` | UUID | `id`, `name`, `isActive`, `updatedAt` |
| `grades` | UUID | `id`, `name`, `sortOrder`, `updatedAt` |
| `standards` | UUID | `id`, `subjectID`, `gradeID`, `subjectName`, `gradeName`, `code`, `name`, `description`, `isActive`, `updatedAt` |
| `questions` | UUID | `id`, `subjectID`, `gradeID`, `standardID`, `standardCode`, `prompt`, `type` (`multipleChoice`\|`input`), `choices` [{`id`,`text`}], `correctAnswer`, `acceptedAlternateAnswers`, `explanation`, `difficulty?`, `isActive`, `createdByAdminID?`, `createdAt`, `updatedAt`, `imageBase64?` (base64 JPEG, resized/compressed to stay under ~700 KB so the document stays under Firestore's ~1 MiB limit) |
| `feedback` | UUID | `id`, `userID` (app UUID), `questionID`, `message`, `status` (`new`\|`reviewed`\|`resolved`), `createdAt`, `updatedAt` |
| `answerAttempts` | UUID | `id`, `userID` (app UUID), `questionID`, `subjectName`, `gradeName`, `standardCode`, `submittedAnswer`, `isCorrect`, `createdAt` |

Notes:

- `userID` in `feedback` and `answerAttempts` is the app-level user UUID (the
  `id` field of the user's profile), not the Firebase UID. The security rules
  compare it against `users/{email}.id`.
- Questions denormalize `standardCode` so student generation can fall back to
  code matching when standard document IDs differ between devices. Any lookup
  of a standard for a question must try `standardID` first, then `standardCode`.
- Empty collections are seeded from local sample data on first staging load.
  Non-empty collections are never seeded; new sample content reaches staging
  only through admin edits.

## Security rules (`firestore.rules`)

- Learning content (`subjects`, `grades`, `standards`, `questions`): any
  signed-in user reads; only admins write, with field validation.
- `users`: admins read all; users read/update only their own profile and
  cannot change their own email or role; only the bootstrap admin can create
  an admin profile.
- `feedback` / `answerAttempts`: admins read; students create records only for
  their own `userID` (feedback must start as `new`); only admins update or
  delete.
- Everything else is denied by default.

Known limitations (also tracked in plan.md milestone 22):

- The pre-sign-in `users` existence check is unauthenticated and will be
  denied once rules deploy; login still works via Firebase Auth error mapping.
- Distinct "no username" / "wrong password" errors allow account enumeration
  (accepted trade-off for now).
- Attempts and feedback created while Firebase is unavailable are not
  re-uploaded later; only newly created records sync.

## Design system

`StandardWiseTheme` centralizes the brand: navy accent + gold supporting
highlight, soft tints, success/danger colors, 12pt corner radius, card shadow,
a spring animation, `StandardWisePrimaryButtonStyle`, the `standardWiseField()`
input style, `StandardWiseSignOutButton` (confirmation dialog), and
`StandardWiseHaptics`. The app icon and login logo use the question-mark and
checkmark mark on navy.

Student screens lead with the core workflow: choose subject, grade, and
standard, then tap `Generate question`. The student home includes a Today
summary grouped by practiced standard. Practice sessions continue generating
questions until the student ends the session. Admin screens stay dense and
functional with Swift Charts for analytics.

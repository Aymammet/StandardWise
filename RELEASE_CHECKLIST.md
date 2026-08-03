# StandardWise Release Checklist

Use this checklist when moving from local/staging testing toward TestFlight and
App Store release.

## Firebase Production Setup

- Confirm the Firebase project used for release is the intended production
  project.
- Confirm Firebase Authentication has Email/Password enabled.
- Enable Sign in with Apple in Firebase Authentication before release if the
  Apple button remains in the app.
- Review Firebase Authentication email templates:
  - Sender name: StandardWise
  - Verification email subject and body
  - Password reset subject and body
  - Reply-to address
- Decide whether to configure a custom Firebase Authentication sender domain.
- Deploy the latest `firestore.rules` to the production Firebase project.
- Confirm Firestore database location and data-retention expectations.
- Create or verify the bootstrap admin account.
- Confirm admin users have the `admin` role in Firestore.
- Confirm regular users have the `regular` role in Firestore.

## Apple Developer Setup

- Confirm the bundle identifier matches the Apple Developer app identifier.
- Enable Sign in with Apple for the app identifier if the Apple button remains
  in the app.
- Confirm signing team, profiles, and capabilities in Xcode.
- Confirm app icon and display name are correct.
- Confirm camera/photo-library permission text if camera support is added later.

## Compliance and App Store Materials

- Replace all publication fields in `PRIVACY.md`.
- Get legal review for COPPA/FERPA and children's privacy before publication.
- Decide whether student self-signup is allowed in production.
- Prepare the App Store privacy nutrition-label answers from `PRIVACY.md`.
- Prepare support contact, marketing URL, and privacy-policy URL.
- Prepare screenshots for required device sizes.
- Prepare TestFlight tester notes with login/setup instructions.

## Final Testing

- Run the `StandardWise Local` build.
- Run the `StandardWise Staging` build.
- Test registration, email activation, login, forgot password, and Sign in with
  Apple on a signed simulator or physical device.
- Test regular-user question generation and Today summary.
- Test admin subject, standard, question, feedback, users, and analytics flows.
- Test question images from a physical device photo library.
- Test Light Mode and Dark Mode.
- Complete `QA_CHECKLIST.md`.

## Release Decision

- Confirm the chosen brand direction is navy/gold.
- Confirm Milestone 19 testing is complete or accepted for TestFlight.
- Confirm Milestone 24 documentation is complete enough for TestFlight.
- Archive in Xcode and upload to App Store Connect.
- Start with TestFlight before full App Store release.

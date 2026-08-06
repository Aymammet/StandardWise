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
- Prepare TestFlight beta app description, features-to-test notes, beta review
  information, and feedback email address.
- Prepare TestFlight tester notes with login/setup instructions.
- Decide whether the first TestFlight round is internal only or external.
  External testing can support more testers, but Apple's beta review is required
  for the first external build.

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

## CI Setup

- Add `.github/workflows/ios-build.yml` using the content in
  `CI_WORKFLOW.md`.
- Prefer the `macos-26` GitHub runner while the project targets the newest iOS
  simulator tooling.
- Keep `CODE_SIGNING_ALLOWED=NO` for simulator CI builds.
- Confirm the first workflow run builds both shared schemes.
- If CI fails because of Xcode or simulator availability, update the runner
  image or destination before treating the app build as broken.

## Manual Owner Steps

These steps cannot be completed by code alone:

- Choose the real operator name for `PRIVACY.md`.
- Choose the public support/contact email.
- Choose the privacy-policy effective date.
- Choose whether production allows open student self-signup.
- Get legal/privacy review before public launch.
- Add the CI workflow file in GitHub or reauthenticate GitHub with workflow
  permission.
- Upload the first archive to App Store Connect from Xcode.
- Invite TestFlight testers from App Store Connect.

## Release Decision

- Confirm the chosen brand direction is navy/gold.
- Confirm Milestone 19 testing is complete or accepted for TestFlight.
- Confirm Milestone 24 documentation is complete enough for TestFlight.
- Archive in Xcode and upload to App Store Connect.
- Start with TestFlight before full App Store release.
- Remember that TestFlight builds expire after 90 days, so refresh beta builds
  if testing continues for a long time.

## Reference Links

- Apple TestFlight overview:
  https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview
- Apple app privacy details:
  https://developer.apple.com/app-store/app-privacy-details/
- Apple distribution overview:
  https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases
- GitHub-hosted runners:
  https://docs.github.com/en/actions/reference/runners/github-hosted-runners

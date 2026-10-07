# Lunora — Project Board

> Priority: **P1** = high · **P2** = medium · **P3** = low
> Mark done items by changing `- [ ]` to `- [x]`.

## Done
- [x] Remove tree/sunflower screen, restore calendar in pregnancy mode
- [x] Pregnancy milestone dots on the calendar (folic acid, fertilization, heartbeat...)
- [x] "Week N" labels on calendar rows
- [x] Important Days cards (per selected day)
- [x] Week-by-week navigation (arrows + week picker)
- [x] 40-week pregnancy data set (development text + fruit size)
- [x] Baby Development card — first version
- [x] Appointment system (model, Firestore sync, add UI, local notifications)
- [x] Firestore rules: appointments collection added
- [x] Build fix: `uiLocalNotificationDateInterpretation` parameter
- [x] Reminder fix: instant confirmation + appointment-time notification
- [x] Biological development drawing — 8-stage medical timeline
- [x] Smooth stage transitions (AnimatedSwitcher)
- [x] Baby Development card new layout (left visual / right text)
- [x] "My Growth Garden" tree card
- [x] Top bar simplification (removed extra icons)
- [x] Publish Firestore rules to production
- [x] LMP date picker in settings + editable LMP row

## Done (recent)
- [x] Mood + legend chip buttons below calendar
- [x] Remove unused `tree_growing.json`

## After production launch — re-add / enable (deferred on 2026-10-06)

Hidden or postponed so the first production release only contains features
that actually work. Re-add in post-launch updates.

- [x] **Comment / like notifications** without paying (2026-10-07, 1.0.10):
  the app writes `users/{uid}/activity` records (bell list + in-app alert),
  and **Google Apps Script** (`apps_script/`) sends the phone push every
  5 minutes. The project stays on the free Spark plan.
  - `functions/` (Cloud Functions) is kept for reference only; it needs the
    paid Blaze plan, which the owner declined. If ever deployed, deploy only
    `onCommentCreated` / `onPostLikeWrite` and turn off the Apps Script,
    otherwise every push arrives twice.
- [ ] **Ads (AdMob)** — P2
  - Consent dialog (UMP) for personalised ads; never use health data for ads.
  - Update Play Console: Ads → Yes, Advertising ID → Yes (+ `AD_ID` permission),
    and Data Safety (device IDs shared with ad partners, purpose: advertising).
- [ ] **Premium / subscriptions** — P2
  - Create subscription products in Play Console, put real RevenueCat keys in
    `lib/services/purchase_service.dart`, make the paywall reachable.
  - Update Data Safety: Financial info → purchase history.
- [ ] Profile counters: `users/{uid}.postCount` / `likesReceived` are never
  updated without Cloud Functions; since 1.0.8 the profile computes them from
  the user's posts. If `onPostLikeWrite` is deployed, either keep the computed
  values or switch back to the stored counters — P3
- [ ] Account deletion page (`ayzit-privacy/account-deletion.html`) says
  "Settings → Edit Profile"; in the app it is "Profile → Edit Profile" — P3

## Backlog
- [ ] Fix iOS bundle id (`com.example.yeniUygulama` -> real, consistent id) — P2
- [ ] Test appointment notifications on iOS — P2
- [ ] Link "My Growth Garden" to water intake / step count — P3
- [ ] Integrate a real medical embryo Lottie animation (if a suitable free file is found) — P3
- [ ] Complete macOS Firebase configuration (`TODO` values in `firebase_options.dart`) — P3
- [ ] Enrich / diversify weekly fruit illustrations — P3
- [ ] Note: emulator internet/DNS issues — prefer testing on a real device — P3

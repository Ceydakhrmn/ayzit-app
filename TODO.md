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

## Ready
- [ ] Find a new home for Mood and calendar-legend buttons (removed from top bar) — P2
- [ ] Remove unused files (`tree_growing.json`) — P3

## Backlog
- [ ] Fix iOS bundle id (`com.example.yeniUygulama` -> real, consistent id) — P2
- [ ] Test appointment notifications on iOS — P2
- [ ] Link "My Growth Garden" to water intake / step count — P3
- [ ] Integrate a real medical embryo Lottie animation (if a suitable free file is found) — P3
- [ ] Complete macOS Firebase configuration (`TODO` values in `firebase_options.dart`) — P3
- [ ] Enrich / diversify weekly fruit illustrations — P3
- [ ] Note: emulator internet/DNS issues — prefer testing on a real device — P3

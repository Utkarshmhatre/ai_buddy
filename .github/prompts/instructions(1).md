# INSTRUCTIONS.md — AI Buddy Audit Fixes (for GitHub Copilot Claude)

> Purpose: This file contains a concise, action-oriented set of instructions tailored for use with GitHub Copilot Claude (or a similar code-generation assistant). It translates the Jan 25, 2026 audit into clear engineering tasks, acceptance criteria, tests, and developer workflow notes so Claude can produce implementation-ready code, tests, and migration steps.

---

## Quick summary (what to implement — priority order)
1. **Critical**
   - Connect `MoodHistoryScreen` chart to real Mood data (Isar + MoodBloc).
   - Implement streak tracking on Home dashboard (compute from mood/journal activity).
   - Journal: add search/filter UI, edit capability, manual mood tagging, and rich-text journaling (store Quill delta).
2. **High**
   - Chat: add edit/delete/copy long-press menu, message streaming support, wire voice-input UI placeholder.
   - Wellness exercises: add Box Breathing, Deep Belly, Energizing Breath; customizable duration/cycles and session tracking.
   - Retention: implement auto-purge (configurable) and 30-minute session timeout (lock screen + unlock flow).
   - Home personalization: show user name, rotating daily quotes, dynamic tips.
3. **Medium / Low**
   - Data export UI, enhance database encryption (Isar native + field-level), persist AI insights, small UX polish.

---

## How to use this file with **GitHub Copilot Claude**
1. Break the work into **one feature per PR**. For each feature copy the relevant section below and prompt Claude to implement it.
2. Provide the repository root path and tell Claude which files are tests vs production code.
3. Use the example prompt templates below (section: *Example prompts for Claude*) — they are intentionally prescriptive.
4. Ask Claude to produce: code, tests (unit + widget where applicable), DB migration code, and a short `docs/` entry.

---

## Branch & commit conventions
- Branch: `feat/audit-fixes/<short-descriptor>` e.g. `feat/audit-fixes/mood-chart-real-data`
- Commit style (examples):
  - `feat(mood): connect MoodHistoryScreen to MoodBloc`
  - `fix(journal): add updateEntry & search API`
  - `test(streak): add unit tests for streak edge cases`
- Keep commits small and focused (UI, bloc, repo, tests, migration each in its own commit when possible).

---

## Acceptance criteria (applies to every feature)
- Add unit test(s) for business logic (BLoC/service/repo).
- Add at least one widget test for a new UI path (if UI changed).
- Include DB migration (Isar) where schema changes are required.
- Add a `docs/<feature>.md` short note describing behaviour, toggles, and QA steps.
- PR must include screenshots or animated gif for UI changes.

---

## DB migration rules & patterns (Isar)
- Add new fields as nullable by default; provide a migration step to backfill if needed.
- Keep a `MigrationVxToVy` function under `lib/db/migrations/` and export a `runMigrationsIfNeeded()` helper in `lib/db/isar_config.dart`.
- When converting plain text -> Quill delta, store `{"ops":[{"insert":"<plaintext>\n"}]}` as default delta for backfill.
- New collections (e.g., `ExerciseSession`) should include `id`, `type`, `startedAt`, `durationSec`, `cycles`, `intensity`, `metadata`.

---

## Testing guidance
- Unit tests: use `test/` to validate aggregation, streak logic, search/filter behaviour and repository methods.
- Widget tests: use `flutter_test` to assert UI widgets render expected states when BLoC emits states.
- Integration/smoke tests: include at least one small integration test for chat streaming + edit flow if test infra is present.
- Test data generation: provide `_makeMoodEntry(date, mood, intensity)` helpers used in tests to simulate chronologically ordered inputs.

---

## Recommendation: File targets & BLoC changes (suggested)
- `lib/blocs/mood/mood_bloc.dart`
  - Events: `LoadMoodHistory(period)`, `ChangePeriod`, `MoodHistoryUpdated`
  - States: `MoodHistoryLoading`, `MoodHistoryLoaded(List<SeriesPoint>)`, `MoodHistoryError`
- `lib/repositories/mood_repository.dart`
  - Ensure `Future<List<MoodEntry>> getMoodEntries(DateTime from, DateTime to)` exists.
- `lib/screens/mood/mood_history_screen.dart`
  - Replace mock series with `BlocBuilder<MoodBloc, MoodState>` and `fl_chart` or existing charting widget to display aggregated data.

- `lib/services/streak_service.dart` — compute current and best streak from mood/journal DB records.
- `lib/widgets/home/streak_widget.dart` — small reusable widget with animation.

- `lib/screens/journal/journal_list_screen.dart` — add `SearchBar` + `FilterChips` and wire to `JournalBloc`.
- `lib/screens/journal/journal_entry_screen.dart` — integrate `flutter_quill` editor and add Edit mode.
- `lib/repositories/journal_repository.dart` — add `searchEntries(query, filters)`, `updateEntry(entry)`.

- Chat changes:
  - `lib/widgets/chat/chat_bubble.dart` — add long-press menu (Edit, Delete, Copy, Retry)
  - `lib/blocs/chat/chat_bloc.dart` — add `EditMessage`, `DeleteMessage`, `StreamAiResponse` events
  - `lib/services/ai_service.dart` — expose `Stream<String> streamResponse(...)` for partial tokens

- Exercises:
  - `lib/screens/exercises/*_screen.dart` for each breathing exercise
  - `lib/repositories/exercise_repository.dart` — `saveSession(ExerciseSession s)`

- Retention & session timeout:
  - `lib/services/retention_service.dart`, `lib/services/session_service.dart`
  - Use `workmanager` or `android_alarm_manager` for scheduled purge (document fallback if CI cannot run background jobs).

---

## Example prompts for Claude (copy-paste per PR)

### Example: Mood chart -> real data
> Implement feature: Connect `MoodHistoryScreen` to real mood data.
> - Modify `lib/screens/mood/mood_history_screen.dart` to subscribe to `MoodBloc`.
> - Add `LoadMoodHistory` event in `lib/blocs/mood/mood_bloc.dart` and implement weekly/monthly aggregation logic in bloc or repository.
> - Add unit tests for aggregation and a widget test that asserts chart renders when `MoodHistoryLoaded` is emitted.
> - Add migration, if any new fields required.
>
> Acceptance: Chart displays real data for last 7 and last 30 days; date picker selects ranges; `flutter test` passes.

### Example: Journal search & rich-text
> Implement feature: Journal search, filter, edit and Quill rich-text.
> - Add `SearchBar` and `FilterChips` to `lib/screens/journal/journal_list_screen.dart`.
> - Integrate `flutter_quill` in `lib/screens/journal/journal_entry_screen.dart` and persist `richTextDelta` JSON to Isar.
> - Add repository methods `searchEntries(query, filters)` and `updateEntry(entry)`.
> - Add DB migration to add nullable `richTextDelta` field and backfill by wrapping plaintext into simple delta.
>
> Acceptance: Journal entries can be searched by text, filtered by mood tag, entries can be edited and reflect changes in the list; tests included.

---

## PR template (paste into PR description)
```
## Summary
(Brief one-liner explaining the change)

## Changes
- What changed (files/logic)
- DB migrations included: `lib/db/migrations/<file>`

## Testing
- Unit tests added: `test/...`
- Widget tests added: `test/widgets/...`
- Manual QA steps:
  1. ...

## Screenshots / GIF
(Attach visual proof)

## Checklist
- [ ] Acceptance criteria met
- [ ] Unit tests passing (`flutter test`)
- [ ] Widget tests passing
- [ ] Migration documented
- [ ] `docs/` updated
```

---

## Labels & estimates (for issue tracker)
- `priority/critical` (4-8d) — Mood chart, streaks, journal core
- `priority/high` (3-6d) — Chat edit/streaming, exercises, retention
- `priority/medium` (2-4d) — Home personalization, encryption improvements
- `priority/low` (1-2d) — Data export UI, minor polish

*(Estimates are rough. When creating issues split into smaller tickets: UI, bloc, repo, tests, migration)*

---

## Running locally (developer commands)
- `flutter pub get`
- `flutter test`
- `flutter drive` or `flutter test integration_test` (if integration infra present)
- For Isar migration during dev, run the app and call `runMigrationsIfNeeded()` or use provided dev script `tool/run_migrations.dart` (add if missing).

---

## QA / Manual testing checklist (copy into `docs/qa-<feature>.md`)
1. Verify happy-path: create mood/journal entries and confirm charts/streaks update.
2. Test edit & delete flows for chat messages (undo snackbar for delete).
3. Create a rich-text journal entry, edit it, and export plaintext fallback.
4. Configure retention to 1 day (dev-only), create older entries, run purge, ensure old entries removed.
5. Run unit & widget tests; ensure no regression failures.

---

## Notes & constraints for Claude
- Follow existing coding style and folder structure (BLoC + repository pattern).
- Keep user privacy: do not add any cloud I/O.
- For UI assets (quotes.json), return a small seeded file (20–100 short quotes) and mention where to add more.
- If a native plugin or platform behavior cannot be implemented in the test environment (e.g., background tasks), add the code but document a fallback path and how to test manually on a device.

---

## Deliverable checklist (per PR)
- Code + tests
- Migration script
- docs/<feature>.md
- Screenshots/GIFs
- PR description using template above

---

If you want, I can now:
- generate **one issue card** per critical feature (ready to paste to GitHub issues), or
- create **code skeletons** for `MoodBloc`, `StreakService`, or the `JournalEntry` Isar schema migration.

Pick one and I’ll produce it next.


# fflr 2.0.0

* Deprecate `tidy_matchups()` and replace with `tidy_schedule()`.

* Leave `items` nested in `recent_activity()`.

* Fix bye week scoring for D/ST players in `team_roster()` (#40).

* Change `powerWins` to a normalized `expectedWins` in `tidy_scores()`.

* Add `scoringPeriodId` argument to functions like `recent_activity()` (#32).

* Add `budget_summary()` version of `transaction_counter()`.

* Add `useMatchup` argument to `tidy_scores()` to allow for `scoringPeriodId`.

* Add transaction dates (and more) to `recent_activity()` output.

* Add `best_roster()`, using `team_roster()` and sorting with slot settings.

* `pro_schedule()` (and `nfl_schedule`) are sorted by `date` and `matchupId`.

* Deprecate `all_players()` in favor of more advance `list_players()` (#21).

* Manually override `teamId` in each `team_roster()` data frame.

* Clarify the name of many `*Id` columns (e.g., `teamId`, `matchupId`) (#31).

* Add `combine_history()` utility for `leagueHistory` functions.

* Improve handling of pre-draft and no-history edge cases (#35).

* Improve abbreviation techniques, add all roster slot and position IDs (#29).

* Fix error checking in `ffl_api()`. Returns proper error message when there is
a failure (e.g., non-public league) (#36).

# fflr 1.9.2

* Fix `tidy_scores()` for settings that award home team points.

* Remove bad variables argument from `pro_scores()`.

* Add vignette and update the README and logo.

* Unnest the `currentScoringPeriod` in `ffl_seasons()`.

* Remove `seasonId` argument in sub-functions.

* Use `proTeamId` and `playerId` column names in data.

* Clarify which columns are simulated in `league_simulation()`.

* Add `overwrite` argument to `ffl_id()` to set `options()` regardless.

* Rename `state_correct()` to `stat_corrections()` and update for new back-end.

# fflr 1.9.1

* Rename some functions to match the website section headers (e.g.,
`roster_moves()` to `recent_activity()`).

* Add `pro_events()` and `pro_scores()` for live NFL data.

* Add vignette listing the package functions as they relate to the sections of
the ESPN website.

* Add spell checking.

* Rename some columns to match conversion (#31).

# fflr 1.9.0

* The package has entirely been re-written from the ground-up (#24).

* All functions use the new `try_json()` back-end, which uses `RETRY()` instead
of `fromJSON()`.

* Use the same argument/column names as the API (`leagueId` instead of `lid`).

* Return single-row data frames instead of lists for a single season.

* Add `tidy_*` prefix to function names that manipulate data structure (#26).

* Pass the `...` arguments to `GET()` instead of `fromJSON()` (#25).

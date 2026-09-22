# fflr (development version)

* `evaluate_trade()` gains a `seasonId` argument, defaulting to `ffl_year()`.
  It used to leave the season to `ffl_api()`'s default, which is fixed at the
  release year, so from the next season on it would have scored the wrong
  season's rosters without any error.

# fflr 2026.0.2

* New `evaluate_trade()` scores both teams' optimal starting lineups before
  and after a proposed `give`/`receive` swap, using the league's own lineup
  optimizer (`best_roster()`'s internals) rather than an external trade value
  chart, so results reflect the league's actual roster settings and ESPN's own
  per-week projections. Each row lists who moves into and out of the starting
  lineup, who a team would have to drop to stay under its roster limit, and
  which traded players are on bye. Accepts a vector of `scoringPeriodId`s, or
  `"rest"` for the rest of the regular season. Errors if a `receive` player is
  a free agent and warns if the league's trade deadline has passed.
* New `player_lookup()` looks up arbitrary player IDs -- rostered on any
  team, a free agent, or a defense -- in the shape of a `team_roster()` row.
  `player_info()` can't do this (it 404s on defenses' negative IDs); this is
  the building block `evaluate_trade()` uses to resolve players a team
  doesn't already roster.
* Fix `player_outlook()` mislabeling weekly outlooks: ESPN keys them by week
  and can skip weeks, but they were numbered sequentially from 1, so each was
  tagged with the wrong `scoringPeriodId`.
* Fix `schedule_settings()` returning zero rows: an empty
  `playoffMatchupPeriodLengthByRound` recycled the whole tibble to length 0.
  `matchupPeriods` now correctly maps each `matchupPeriod` to its
  `scoringPeriod`s (the columns were swapped), including multi-week playoff
  matchups that were garbled into periods like `"141"` and `"142"`.
* `list_players()` now returns a zero-row data frame with the usual columns
  instead of erroring when no players meet the filter criteria (e.g.,
  `status = "FREEAGENT"` while all players are locked on waivers).
* Fix `list_players()` erroring when `status` has more than one value.

# fflr 2026.0.1

* Update to 2026 API endpoints and update package data for the 2026 season.
* **Breaking:** ESPN now returns professional team abbreviations in all capital
  letters (`"MIA"` instead of `"Mia"`). This changes the `abbrev` levels in
  `nfl_teams`, the `proTeam` column in `nfl_players`, and everything derived
  from them, including `pro_abbrev()` and the `proTeam` argument of
  `list_players()`. Code that matches on the old mixed-case spelling needs to be
  updated.
* `stat_corrections()` now takes the NFL season from the `date` argument rather
  than using a hard-coded year, so corrections from any past season can be
  retrieved. Dates in January and February belong to the previous season.
* Fix an error in `stat_corrections()` when ESPN returns corrections that carry
  no `splitStats`, which is now the case for some entries every week.
* `league_messages()` now parses whatever message topic types ESPN returns
  instead of a fixed list. ESPN renamed `CHAT` to `CHAT_ALL_MEMBERS` and added
  `ACTIVITY_STATUS`, which had reduced the output to three columns. An empty
  message board now returns a zero-row data frame with all seven columns.
* `pro_events()` drops the `pickcenter`, `againstTheSpread`, and `odds` columns
  newly added by ESPN. They are deeply nested and vary game to game. The
  `percentComplete` column is kept, so the result now has 14 columns. The
  post-season empty data frame gained the columns needed to match.
* Fix the `cookie` argument, which never actually worked (#50). `httr::set_cookies()`
  percent-encodes the value it is given, so the already-encoded `espn_s2` string
  was double-encoded (`%2F` became `%252F`) and ESPN rejected every request with
  a 404. The cookie header is now set directly, and `leagueHistory = TRUE` works
  again for `draft_recap()`, `team_roster()`, `league_standings()`, and the rest.
* New `ffl_cookie()` reads the cookie from the `fflr.cookie` option or the
  `ESPN_S2` environment variable, and is the new default for the `cookie`
  argument of `ffl_api()`. The cookie no longer has to be passed to every call.
* Only the `leagueHistory` endpoint requires the `espn_s2` cookie. A single past
  season can still be requested without one by passing an explicit `seasonId`.
* `recent_activity()` converts the `expirationDate` and `acceptedDate` columns
  to date-times. ESPN returns these two columns, along with `teamActions`, only
  for signed-in requests, so the columns present depend on whether a cookie was
  sent.

# fflr 2025.0.1

* Update to 2025 API endpoints and update package data.
* Added the `cookie` argument to `ffl_api()` which can be passed to any function
  through the `...` argument. The cookie is needed to retrieve historical data
  (using `leagueHistory = TRUE` is no longer enough). The `espn_s2` cookie can
  be obtained from your browser's developer tools. This is a very clunky system
  and I'm working on an easier system.

# fflr 2.3.1

* Update `nfl_players` and `nfl_schedule` for 2024 season.
* Continue updates to switch from 2023 to 2024.

# fflr 2.3.0

* Update the package to work with the new API.
* Update examples and tests for post-season without data.

# fflr 2.2.4

Fix tests for post-season API data formats.

# fflr 2.2.3

* Update maintainer email, website URL, and GitHub URL.
* Switch from MIT license to GPL-3

# fflr 2.2.2

* Adjust more tests for the end of the NFL season and changes to API.

# fflr 2.2.1

* Adjust tests for end of NFL season.
* The functions `league_members()` and `league_teams()` have been adjusted to
  add new columns. The order of columns has also been rearranged to focus on
  the output of each function (all teams or all members), since some teams can
  have multiple owners or multiple teams can have the same owner.
    * Add `firstName` and `lastName` to `league_members()`
    * Add `logo` and `logoType` to `league_teams()`
* Use latest package dependencies.

# fflr 2.2.0

* **Package has been updated for the 2023 season!**
  * Functions now use `seasonId = 2023` by default in `ffl_api()`.
* Update objects with latest data from 2023 season.
* Fix `nfl_players` to include actually all of the players.
* Adjust the free agent information in `nfl_teams`.
* Add more function tests.
* Add `bonusWin` column to `live_scoring()`.

# fflr 2.1.0

* Functions now use `seasonId = 2022` by default in `ffl_api()`.

# fflr 2.0.2

* Return empty `pro_*()` data with relevant message post-season. 

# fflr 2.0.1

* Adjust `player_acquire()` names to match `team_roster()`.
* Fix `list_players()` test error on CRAN.

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

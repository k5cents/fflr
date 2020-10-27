# fflr 0.3.8

* Remove `set_lid()`.
* Fix system sleeping between settings tests.

# fflr 0.3.7

* Add `ffl_merge()` shortcut.
* Separate `player_aquire()` from `team_roster()`.
* Add overview vignette on all features.

# fflr 0.3.6

* Add `player_info()` and add to `nfl_players`.
* Update `nfl_schedule` for COVID-19 delays.
* Allow `live_scoring()` to show players yet to play.

# fflr 0.3.5

* Update function documentation.
* Let `best_roster()` use projections.

# fflr 0.3.4

* Add `player_news()`.
* Improve acquisition data for teams. 

# fflr 0.3.3

* Invert opponent ranks.
* Pivot fantasy schedule long-wise.
* Skip players without stats in `all_players()`.
* Remove IR slots from `best_roster()` and `roster_score()`.

# fflr 0.3.2

* Scrape and improve NFL teams.
* All `pro_schedule()` and save object.
* Update NFL players data.

# fflr 0.3.1

* Add power wins calculation to matchups.
* Make team abbreviations factors ordered by ID.
* `ffl_api()` can now take multiple views as list.
* Scrape live scoring with updated projections.

# fflr 0.3.0

* Rewrite functions to use `getOptions("lid")`.
* Cover all players, transactions, settings, ESPN information.
* Imports httr for the headers needed in `all_players()`.
* Save `players` tibble as of 2020-09-25 01:00.

# fflr 0.2.0

* Cover team rosters, best rosters, weekly matchups.

# fflr 0.1.1

* Erase all functions and start over with simplified philosophy.
* Cover draft history, league members, and league teams.

# fflr 0.0.2

* Added a `NEWS.md` file to track changes to the package.
* Set the factor levels in matchup weeks to `1:16`.

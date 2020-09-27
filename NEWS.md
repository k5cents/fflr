# fflr 0.3.1

* Add power wins calculation to matchups.
* Make team abbreviatins factors ordered by ID.
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

## Test environments

* local: ubuntu-20.04 (release)
* github actions: ubuntu-20.04 (release, devel)
  * <https://github.com/kiernann/fflr/actions>
* github actions: macOS-latest (release)
* github actions: windows-latest (release) 
* win-builder: windows-x86_64-devel
  * <https://win-builder.r-project.org/ANV0wwGa2RnH/>
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
  * <https://builder.r-hub.io/status/fflr_0.3.14.tar.gz-a7c01bf630c84ee6aec27a295a0b463d>
  * <https://builder.r-hub.io/status/fflr_0.3.14.tar.gz-757b9e3b5057454fbaa85d3653528c93>
  * <https://builder.r-hub.io/status/fflr_0.3.14.tar.gz-40b0130eb3464ddaa7db895d371b8190>

## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.

## Resubmission

* Tests now respond properly to functions that only work during a certain 
period of time. They either check for warnings or skip when appropriate.

* More uses of `roster_moves()` now use a known past week. Examples and vignette
should not error week to week, now that new data from _current_ week errors.

## Previous Submission(s)

* The `player_outlook()` and `all_players()` functions now have new arguments
with a default _limit_ to return less data much faster.

* A known past week is used for `roster_moves()` tests. Week to week, this
function returns different data so tests must use a working week.

-----

* _All_ calls to an external API use `tryCatch()` and repeat the request should
it fail initially. The timeout options are no longer changed between attempts,
only sleeping.

* The `all_players()` examples and tests are skipped because they take too long.
The stat scraping is also more careful when handling edge cases and should be
able to run at any time.

* The vignette uses a know, past data point and no longer changes depending on
when it was run; this should prevent calls to `team_roster()`, etc from
returning some data that might not work in the rest of the vignette.

-----

* The `ffl_api()` now uses `tryCatch()` and re-tries to call the API when it
fails, waiting with `Sys.sleep()` between attempts and adjusting the timeout
`options()`. This should help prevent timeout failures in
`jsonlite::fromJSON()`, which are the cause of the error in the last submission
(0.3.9).

```
── 1. Error: teams return for current year (@test-teams.R#5) ──────────────────
Timeout was reached: [fantasy.espn.com] Resolving timed out after 10001 milliseconds
```

-----

* [ESPN](https://en.wikipedia.org/wiki/ESPN) is not really an acronym, it no
longer stands for anything and doesn't need to be explained in the DESCRIPTION.

* Functions and tests that rely on date or internet services fail more
gracefully or skip if the function is not applicable when the test is run.

* Functions that cannot be trusted to return consistent data are not tested in
a way that might fail.

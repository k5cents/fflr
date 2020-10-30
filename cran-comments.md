## Test environments

* local: ubuntu-20.04 (release)
* github actions: ubuntu-20.04 (release, devel)
  * https://github.com/kiernann/fflr/actions
* github actions: macOS-latest (release)
* github actions: windows-latest (release) 
* win-builder: windows-x86_64-devel
  * https://win-builder.r-project.org/ANV0wwGa2RnH/
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
  * https://builder.r-hub.io/status/fflr_0.3.10.tar.gz-8880c48e9fb3456d9237301782b6253c
  * https://builder.r-hub.io/status/fflr_0.3.10.tar.gz-93d173f6f5e64628b4f0703a611f3664
  * https://builder.r-hub.io/status/fflr_0.3.10.tar.gz-4c5998ea86dd4127824cdc5736210ecf

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Resubmission

* The `ffl_api()` now uses `tryCatch()` and re-tries to call the API when it
fails, waiting with `Sys.sleep()` between attempts and adjusting the timeout
`options()`. This should help prevent timeout failures in
`jsonlite::fromJSON()`, which are the cause of the error in the last submission
(0.3.9).

```
── 1. Error: teams return for current year (@test-teams.R#5) ──────────────────
Timeout was reached: [fantasy.espn.com] Resolving timed out after 10001 milliseconds
```

## Previous Submission

* [ESPN](https://en.wikipedia.org/wiki/ESPN) is not really an acronym, it no
longer stands for anything and doesn't need to be explained in the DESCRIPTION.

* Functions and tests that rely on date or internet services fail more
gracefully or skip if the function is not applicable when the test is run.

* Functions that cannot be trusted to return consistent data are not tested in
a way that might fail.

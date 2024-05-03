## Test environments

* local: ubuntu 22.04.4, R 4.1.2
* GitHub Actions (macos-latest, windows-latest, ubuntu-latest x3)
  * https://github.com/k5cents/fflr/actions/runs/8932966428
* R-hub actions (macos, macos-arm64, windows, linux)
  * https://github.com/k5cents/fflr/actions/runs/8932969884
* win-builder: devel

## R CMD check results

0 errors | 0 warnings | 0 note

## Submission

* The package now fails gracefully with an informative message, returning a data
frame with zero rows that doesn't need to pass any tests.

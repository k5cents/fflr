## Test environments

* local: ubuntu 22.04.4, R 4.1.2
* GitHub Actions (macos-latest, windows-latest, ubuntu-latest)
  * https://github.com/k5cents/fflr/actions/runs/6161897291/job/16722168072
* win-builder: devel
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
  * <https://builder.r-hub.io/status/fflr_2.2.0.tar.gz-e6d5e9f3a306438d9f4b703c8ab75dcd>
  * <https://builder.r-hub.io/status/fflr_2.2.0.tar.gz-470f09fea60d4966a47b31f03e5fcc42>
  * <https://builder.r-hub.io/status/fflr_2.2.0.tar.gz-6083cfae67aa49f68c9440c6cbf20e8e>

## R CMD check results

0 errors | 0 warnings | 0 note

## Submission

* The package now fails gracefully with an informative message, returning a data
frame with zero rows that doesn't need to pass any tests.

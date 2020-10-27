## Test environments

* local: ubuntu-20.04 (release)\
* github actions: ubuntu-20.04 (release, devel)
* github actions: macOS-latest (release)
* github actions: windows-latest (release) 
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
* win-builder: windows-x86_64-devel

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Resubmission

* Functions and tests that rely on date or internet services fail more
gracefully or skip if the function is not applicable when the test is run.

* Functions that cannot be trusted to return consistent data are not tested in
a way that might fail.

## Previous Submission

* [ESPN](https://en.wikipedia.org/wiki/ESPN) is not really an acronym, it no
longer stands for anything and doesn't need to be explained in the DESCRIPTION.

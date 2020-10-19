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

* [ESPN](https://en.wikipedia.org/wiki/ESPN) is not really an acronym, it no
longer stands for anything and doesn't need to be explained in the DESCRIPTION.

* `Sys.sleep()` has been removed from `test-settings.R`, reducing the overall
run time from 159.9 to 44.9 seconds. Running all tests without sleeping can
occasionally produce an API error, but it works right now.

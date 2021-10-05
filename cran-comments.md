## Test environments

* GitHub Actions (ubuntu-16.04): devel, release, oldrel, 3.5, 3.4, 3.3
* GitHub Actions (windows): release, oldrel
* GitHub Actions (macOS): release
* win-builder: devel
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
  * <https://builder.r-hub.io/status/fflr_1.9.2.tar.gz-1873409bd86e46cb867adc076ed846ea>
  * <https://builder.r-hub.io/status/fflr_1.9.2.tar.gz-7404bd68cb8f4b9aa3471b2a8fe0d17a>
  * <https://builder.r-hub.io/status/fflr_1.9.2.tar.gz-f9aa3a6726174838aa80a7e104f1ff18>

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Resubmission

> New submission
>   
> Package was archived on CRAN
> 
> CRAN repository db overrides:
>   X-CRAN-Comment: Archived on 2021-03-27 for policy violation.
> 
>   On Internet access.

This package was previously hosted on CRAN as version 0.3.15 as of January 2021.
Due to the nature of the web API being used, data becomes unavailable for a few
months of the year. These changes made the package tests and examples suddenly
fail. The package was subsequently archived on 2021-03-27.

Going forward, work is being done to ensure the functions fail gracefully if the
web API is unavailable during that time of the year. I'm hoping the package can
be re-hosted under the same name. If not, let me know and I can submit as fflr2.

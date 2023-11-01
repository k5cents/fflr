
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/fflr)](https://CRAN.R-project.org/package=fflr)
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/fflr)
[![Codecov test
coverage](https://img.shields.io/codecov/c/github/kiernann/fflr/master.svg)](https://app.codecov.io/gh/kiernann/fflr?branch=master')
[![R build
status](https://github.com/kiernann/fflr/workflows/R-CMD-check/badge.svg)](https://github.com/kiernann/fflr/actions)
<!-- badges: end -->

The fflr package is used to query the [ESPN Fantasy Football
API](https://fantasy.espn.com/apis/v3/games/ffl/). Get data on fantasy
football league members, teams, and individual athletes.

This package has been tested with a narrow subset of possible league
settings. If a function doesn’t work as intended, please file an [issue
on GitHub](https://github.com/kiernann/fflr/issues).

## Installation

You can install the release version of fflr from
[CRAN](https://cran.r-project.org/package=fflr):

``` r
install.packages("fflr")
```

The most recent development version can be installed from
[GitHub](https://github.com/kiernann/fflr):

``` r
# install.packages("remotes")
remotes::install_github("kiernann/fflr")
```

## Usage

``` r
library(fflr)
packageVersion("fflr")
#> [1] '2.2.0'
```

Data is only available for public leagues. See [this help
page](https://web.archive.org/web/20211105212446/https://support.espn.com/hc/en-us/articles/360000064451-Making-a-Private-League-Viewable-to-the-Public)
on how to make a private league public

Functions require a unique `leagueId`, which can be found in any ESPN
page URL.

<pre>https://fantasy.espn.com/football/league?leagueId=<b>42654852</b></pre>

Use `ffl_id()` to set a default `fflr.leagueId` option. Your `.Rprofile`
file can [set this option on
startup](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html).

``` r
ffl_id(leagueId = "42654852")
#> Temporarily set `fflr.leagueId` option to 42654852
#> [1] "42654852"
```

The `leagueId` argument defaults to `ffl_id()` and can be omitted once
set.

``` r
league_info()
#> # A tibble: 1 × 6
#>         id seasonId name             isPublic  size finalScoringPeriod
#>      <int>    <int> <chr>            <lgl>    <int>              <int>
#> 1 42654852     2023 FFLR Test League TRUE         4                 17
league_teams()
#> # A tibble: 4 × 3
#>   abbrev teamId memberId                              
#>   <fct>   <int> <chr>                                 
#> 1 AUS         1 {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
#> 2 BOS         2 {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
#> 3 CHI         3 {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
#> 4 DEN         4 {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
```

The `scoringPeriodId` argument can be used to get data from past weeks.

``` r
all_rost <- team_roster(scoringPeriodId = 1)
all_rost$CHI[, 5:13][-7]
#> # A tibble: 16 × 8
#>    lineupSlot playerId firstName lastName    proTeam position projectedScore actualScore
#>    <fct>         <int> <chr>     <chr>       <fct>   <fct>             <dbl>       <dbl>
#>  1 QB          4040715 Jalen     Hurts       Phi     QB                21.3        12.5 
#>  2 RB          3929630 Saquon    Barkley     NYG     RB                16.9         9.3 
#>  3 RB          4239996 Travis    Etienne Jr. Jax     RB                15.1        21.4 
#>  4 WR          4262921 Justin    Jefferson   Min     WR                20.1        24   
#>  5 WR          4569618 Garrett   Wilson      NYJ     WR                16.4        14.4 
#>  6 TE            15847 Travis    Kelce       KC      TE                 0           0   
#>  7 FLEX        4374302 Amon-Ra   St. Brown   Det     WR                16.7        19.1 
#>  8 D/ST         -16025 49ers     D/ST        SF      D/ST               7.78       14   
#>  9 K           3055899 Harrison  Butker      KC      K                  8.41        8   
#> 10 BE          4429795 Jahmyr    Gibbs       Det     RB                14.0         8   
#> 11 BE          3042519 Aaron     Jones       GB      RB                15.5        26.7 
#> 12 BE          3915511 Joe       Burrow      Cin     QB                19.8         3.18
#> 13 BE          2976499 Amari     Cooper      Cle     WR                13.6         6.7 
#> 14 BE          4697815 Rachaad   White       TB      RB                13.9         6.9 
#> 15 BE          3054850 Alvin     Kamara      NO      RB                 0           0   
#> 16 BE          4038941 Justin    Herbert     LAC     QB                16.9        20.9
```

There are included objects for NFL teams and players.

``` r
nfl_teams
#> # A tibble: 33 × 6
#>    proTeamId abbrev location   name       byeWeek conference
#>        <int> <fct>  <chr>      <chr>        <int> <chr>     
#>  1         0 FA     <NA>       Free Agent      NA <NA>      
#>  2         1 Atl    Atlanta    Falcons         14 NFC       
#>  3         2 Buf    Buffalo    Bills            7 AFC       
#>  4         3 Chi    Chicago    Bears           14 NFC       
#>  5         4 Cin    Cincinnati Bengals         10 AFC       
#>  6         5 Cle    Cleveland  Browns           9 AFC       
#>  7         6 Dal    Dallas     Cowboys          9 NFC       
#>  8         7 Den    Denver     Broncos          9 AFC       
#>  9         8 Det    Detroit    Lions            6 NFC       
#> 10         9 GB     Green Bay  Packers         14 NFC       
#> # ℹ 23 more rows
```

------------------------------------------------------------------------

The fflr project is released with a [Contributor Code of
Conduct](https://kiernann.github.io/fflr/CODE_OF_CONDUCT.html). By
contributing, you agree to abide by its terms.

<!-- refs: start -->
<!-- refs: end -->

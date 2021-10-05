
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/fflr)](https://CRAN.R-project.org/package=fflr)
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/fflr)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/fflr/branch/master/graph/badge.svg)](https://codecov.io/gh/kiernann/fflr?branch=master)
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

You can install the development version of fflr from
[GitHub](https://github.com/kiernann/fflr):

``` r
# install.packages("remotes")
remotes::install_github("kiernann/fflr")
```

## Usage

``` r
library(fflr)
packageVersion("fflr")
#> [1] '1.9.2'
```

Data is only available for public leagues. See [this help
page](https://support.espn.com/hc/en-us/articles/360000064451-Making-a-Private-League-Viewable-to-the-Public)
on how to make a private league public

Functions require a unique `leagueId`, which can be found in any ESPN
page URL.

<pre>https://fantasy.espn.com/football/league?leagueId=<b>42654852</b></pre>

Use `ffl_id()` to set a default `fflr.leagueId` option. Your `.Rprofile`
file can [set this option on
startup](https://support.rstudio.com/hc/en-us/articles/360047157094-Managing-R-with-Rprofile-Renviron-Rprofile-site-Renviron-site-rsession-conf-and-repos-conf).

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
#> 1 42654852     2021 FFLR Test League TRUE         4                 17
league_teams()
#> # A tibble: 4 × 5
#>   abbrev    id location nickname   owners   
#>   <fct>  <int> <chr>    <chr>      <list>   
#> 1 AUS        1 Austin   Astronauts <chr [1]>
#> 2 BOS        2 Boston   Buzzards   <chr [1]>
#> 3 CHI        3 Chicago  Crowns     <chr [1]>
#> 4 DEN        4 Denver   Devils     <chr [1]>
```

The `scoringPeriodId` argument can be used to get data from past weeks.

``` r
team_roster(scoringPeriodId = 1)[[3]][, -c(1:3, 5, 13:15)]
#> # A tibble: 16 × 8
#>    lineupSlot firstName lastName  proTeam position injuryStatus projectedScore actualScore
#>    <fct>      <chr>     <chr>     <fct>   <fct>    <chr>                 <dbl>       <dbl>
#>  1 QB         Josh      Allen     Buf     QB       A                     21.6         17.2
#>  2 RB         Saquon    Barkley   NYG     RB       A                     13.8          3.7
#>  3 RB         Derrick   Henry     Ten     RB       A                     17.3         10.7
#>  4 WR         DeAndre   Hopkins   Ari     WR       A                     17.8         26.3
#>  5 WR         Justin    Jefferson Min     WR       A                     15.4         12.5
#>  6 TE         Darren    Waller    LV      TE       A                     14.2         26.5
#>  7 FX         Austin    Ekeler    LAC     RB       A                     15.0         11.7
#>  8 DS         Ravens    D/ST      Bal     DS       A                      5.86        -1  
#>  9 PK         Justin    Tucker    Bal     PK       A                      8.14        11  
#> 10 BE         Joe       Mixon     Cin     RB       Q                     14.6         25  
#> 11 BE         Keenan    Allen     LAC     WR       A                     14.8         19  
#> 12 BE         Mike      Evans     TB      WR       A                     15.0          5.4
#> 13 BE         Josh      Jacobs    LV      RB       A                     13.1         17  
#> 14 BE         Myles     Gaskin    Mia     RB       A                     10.9         12.6
#> 15 BE         Ja'Marr   Chase     Cin     WR       A                     10.4         20.9
#> 16 BE         Brandon   Aiyuk     SF      WR       A                     13.9          0
```

There are included objects for NFL teams and players.

``` r
nfl_teams
#> # A tibble: 33 × 6
#>    proTeamId abbrev location   name    byeWeek conference
#>        <int> <fct>  <chr>      <chr>     <int> <chr>     
#>  1         0 FA     <NA>       FA            0 <NA>      
#>  2         1 Atl    Atlanta    Falcons       6 NFC       
#>  3         2 Buf    Buffalo    Bills         7 AFC       
#>  4         3 Chi    Chicago    Bears        10 NFC       
#>  5         4 Cin    Cincinnati Bengals      10 AFC       
#>  6         5 Cle    Cleveland  Browns       13 AFC       
#>  7         6 Dal    Dallas     Cowboys       7 NFC       
#>  8         7 Den    Denver     Broncos      11 AFC       
#>  9         8 Det    Detroit    Lions         9 NFC       
#> 10         9 GB     Green Bay  Packers      13 NFC       
#> # … with 23 more rows
```

------------------------------------------------------------------------

The fflr project is released with a [Contributor Code of
Conduct](https://kiernann.com/fflr/CODE_OF_CONDUCT.html). By
contributing, you agree to abide by its terms.

<!-- refs: start -->
<!-- refs: end -->

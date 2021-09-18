
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
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
#> [1] '1.9.0'
```

Data is only available for public leagues. See [this help
page](https://support.espn.com/hc/en-us/articles/360000064451-Making-a-Private-League-Viewable-to-the-Public)
on how to make a private league public

Functions require a unique `leagueId`, which can be found in any ESPN
page URL.

<pre>https://fantasy.espn.com/football/league?leagueId=<b>42654852</b></pre>

Use `ffl_id()` to set and retrieve a default `fflr.leagueId` option.
Edit your `.Rprofile` file to set this option on startup.

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
#> 1 42654852     2021 FFLR Test League TRUE         4                 14
league_teams()
#> # A tibble: 4 × 5
#>   abbrev    id location nickname   owners   
#>   <fct>  <int> <chr>    <chr>      <list>   
#> 1 AUS        1 Austin   Astronauts <chr [1]>
#> 2 BOS        2 Boston   Birds      <chr [1]>
#> 3 CHI        3 Chicago  Crowns     <chr [1]>
#> 4 DEN        4 Denver   Devils     <chr [1]>
```

``` r
team_roster(scoringPeriodId = 1)[[1]][, -c(1:3, 5, 13:15)]
#> # A tibble: 16 × 8
#>    lineupSlotId firstName  lastName    proTeam PositionId injuryStatus projectedScore actualScore
#>    <fct>        <chr>      <chr>       <fct>   <fct>      <chr>                 <dbl>       <dbl>
#>  1 QB           Patrick    Mahomes     KC      QB         A                     22.2         33.3
#>  2 RB           Christian  McCaffrey   Car     RB         A                     21.3         27.7
#>  3 RB           Jonathan   Taylor      Ind     RB         A                     15.6         17.6
#>  4 WR           Davante    Adams       GB      WR         A                     19.9         10.6
#>  5 WR           Calvin     Ridley      Atl     WR         A                     16.0         10.1
#>  6 TE           Mark       Andrews     Bal     TE         A                     12.2          5  
#>  7 FX           Antonio    Gibson      Wsh     RB         A                     16.0         11.8
#>  8 DS           Buccaneers D/ST        TB      DS         A                      4.51        -3  
#>  9 PK           Jason      Myers       Sea     PK         A                      8.04         4  
#> 10 BE           D'Andre    Swift       Det     RB         Q                     13.5         24.4
#> 11 BE           Miles      Sanders     Phi     RB         A                     14.3         17.3
#> 12 BE           Chris      Carson      Sea     RB         A                     12.8         12.7
#> 13 BE           Allen      Robinson II Chi     WR         A                     14.6          9.5
#> 14 BE           Adam       Thielen     Min     WR         A                     14.4         30.2
#> 15 BE           Diontae    Johnson     Pit     WR         A                     13.4         14.6
#> 16 BE           Courtland  Sutton      Den     WR         A                     11.9          2.4
```

There are included objects for NFL teams and players.

``` r
nfl_teams
#> # A tibble: 33 × 6
#>       id abbrev location   name    byeWeek conference
#>    <int> <fct>  <chr>      <chr>     <int> <chr>     
#>  1     0 FA     <NA>       FA            0 <NA>      
#>  2     1 Atl    Atlanta    Falcons       6 NFC       
#>  3     2 Buf    Buffalo    Bills         7 AFC       
#>  4     3 Chi    Chicago    Bears        10 NFC       
#>  5     4 Cin    Cincinnati Bengals      10 AFC       
#>  6     5 Cle    Cleveland  Browns       13 AFC       
#>  7     6 Dal    Dallas     Cowboys       7 NFC       
#>  8     7 Den    Denver     Broncos      11 AFC       
#>  9     8 Det    Detroit    Lions         9 NFC       
#> 10     9 GB     Green Bay  Packers      13 NFC       
#> # … with 23 more rows
```

------------------------------------------------------------------------

The fflr project is released with a [Contributor Code of
Conduct](https://kiernann.com/fflr/CODE_OF_CONDUCT.html). By
contributing, you agree to abide by its terms.

<!-- refs: start -->
<!-- refs: end -->

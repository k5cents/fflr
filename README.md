
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/fflr)](https://CRAN.R-project.org/package=fflr)
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/fflr)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/fflr/branch/master/graph/badge.svg)](https://app.codecov.io/gh/kiernann/fflr?branch=master)
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
#> [1] '1.9.2.9015'
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
#> 1 42654852     2021 FFLR Test League TRUE         4                 17
league_teams()
#> # A tibble: 4 × 5
#>   abbrev teamId location nickname   memberId                              
#>   <fct>   <int> <chr>    <chr>      <chr>                                 
#> 1 AUS         1 Austin   Astronauts {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
#> 2 BOS         2 Boston   Buzzards   {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
#> 3 CHI         3 Chicago  Crowns     {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
#> 4 DEN         4 Denver   Devils     {22DFE7FF-9DF2-4F3B-9FE7-FF9DF2AF3BD2}
```

The `scoringPeriodId` argument can be used to get data from past weeks.

``` r
all_rost <- team_roster(scoringPeriodId = 1)
all_rost$CHI[, 5:13][-7]
#> # A tibble: 16 × 8
#>    lineupSlot playerId firstName lastName  proTeam position projectedScore actualScore
#>    <fct>         <int> <chr>     <chr>     <fct>   <fct>             <dbl>       <dbl>
#>  1 QB          3918298 Josh      Allen     Buf     QB                21.6         17.2
#>  2 RB          3929630 Saquon    Barkley   NYG     RB                13.8          3.7
#>  3 RB          3043078 Derrick   Henry     Ten     RB                17.3         10.7
#>  4 WR            15795 DeAndre   Hopkins   Ari     WR                17.8         26.3
#>  5 WR          4262921 Justin    Jefferson Min     WR                15.4         12.5
#>  6 TE          2576925 Darren    Waller    LV      TE                14.2         26.5
#>  7 FLEX        3068267 Austin    Ekeler    LAC     RB                15.0         11.7
#>  8 D/ST         -16033 Ravens    D/ST      Bal     D/ST               5.86        -1  
#>  9 K             15683 Justin    Tucker    Bal     K                  8.14        11  
#> 10 BE          3116385 Joe       Mixon     Cin     RB                14.6         25  
#> 11 BE            15818 Keenan    Allen     LAC     WR                14.8         19  
#> 12 BE            16737 Mike      Evans     TB      WR                15.0          5.4
#> 13 BE          4047365 Josh      Jacobs    LV      RB                13.1         17  
#> 14 BE          3886818 Myles     Gaskin    Mia     RB                10.9         12.6
#> 15 BE          4362628 Ja'Marr   Chase     Cin     WR                10.4         20.9
#> 16 BE          4360438 Brandon   Aiyuk     SF      WR                13.9          0
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

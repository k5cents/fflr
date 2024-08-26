
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/fflr)](https://CRAN.R-project.org/package=fflr)
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/fflr)
[![Codecov test
coverage](https://codecov.io/gh/k5cents/fflr/graph/badge.svg?token=CMz6DIxJdH)](https://app.codecov.io/gh/k5cents/fflr?branch=master)
[![R build
status](https://github.com/k5cents/fflr/workflows/R-CMD-check/badge.svg)](https://github.com/k5cents/fflr/actions)
<!-- badges: end -->

The fflr package is used to query the [ESPN Fantasy Football
API](https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/). Get data
on fantasy football league members, teams, and individual athletes.

This package has been tested with a narrow subset of possible league
settings. If a function doesn’t work as intended, please file an [issue
on GitHub](https://github.com/k5cents/fflr/issues).

## Installation

> \[!IMPORTANT\]  
> As of 2024-05-17, fflr was removed from
> [CRAN](https://cran.r-project.org/package=fflr) for failure to comply
> with the policy on internet resources. This issue arose when ESPN
> changed their API format and adjusted endpoints to account for the end
> of the 2023 NFL season. I hope to work with CRAN to get the package
> published again before the 2024 season, but it may not be possible.

The most recent development version can always be installed from
[GitHub](https://github.com/k5cents/fflr):

``` r
# install.packages("remotes")
remotes::install_github("k5cents/fflr")
```

## Usage

``` r
library(fflr)
packageVersion("fflr")
#> [1] '2.3.1'
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
#> 1 42654852     2024 FFLR Test League TRUE         4                 17
league_teams()
#> # A tibble: 4 × 6
#>   teamId abbrev name              logo                                            logoType memberId
#>    <int> <fct>  <chr>             <chr>                                           <chr>    <chr>   
#> 1      1 AUS    Austin Astronauts https://g.espncdn.com/lm-static/logo-packs/cor… VECTOR   {22DFE7…
#> 2      2 BOS    Boston Buzzards   https://g.espncdn.com/lm-static/logo-packs/cor… VECTOR   {22DFE7…
#> 3      3 CHI    Chicago Crowns    https://g.espncdn.com/lm-static/logo-packs/cor… VECTOR   {22DFE7…
#> 4      4 DEN    Denver Devils     https://g.espncdn.com/lm-static/logo-packs/cor… VECTOR   {22DFE7…
```

The `scoringPeriodId` argument can be used to get data from past weeks.

``` r
all_rost <- team_roster(scoringPeriodId = 1)
all_rost$CHI[, 5:13][-7]
#> # A tibble: 16 × 8
#>    lineupSlot playerId firstName lastName     proTeam position projectedScore actualScore
#>    <fct>         <int> <chr>     <chr>        <fct>   <fct>             <dbl>       <dbl>
#>  1 QB          3918298 Josh      Allen        Buf     QB                23.6           NA
#>  2 RB          4430807 Bijan     Robinson     Atl     RB                18.6           NA
#>  3 RB          4239996 Travis    Etienne Jr.  Jax     RB                14.3           NA
#>  4 WR          4262921 Justin    Jefferson    Min     WR                18.1           NA
#>  5 WR          4569618 Garrett   Wilson       NYJ     WR                16.4           NA
#>  6 TE          3116365 Mark      Andrews      Bal     TE                13.1           NA
#>  7 FLEX        4426515 Puka      Nacua        LAR     WR                17.1           NA
#>  8 D/ST         -16033 Ravens    D/ST         Bal     D/ST               3.94          NA
#>  9 K             15683 Justin    Tucker       Bal     K                  8.23          NA
#> 10 BE          4432708 Marvin    Harrison Jr. Ari     WR                15.4           NA
#> 11 BE          4429160 De'Von    Achane       Mia     RB                13.9           NA
#> 12 BE          4258173 Nico      Collins      Hou     WR                14.4           NA
#> 13 BE          4360438 Brandon   Aiyuk        SF      WR                13.5           NA
#> 14 BE          4567048 Kenneth   Walker III   Sea     RB                16.0           NA
#> 15 BE          3042519 Aaron     Jones        Min     RB                13.7           NA
#> 16 BE          4429615 Zay       Flowers      Bal     WR                14.8           NA
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

> \[!NOTE\]  
> The fflr project is released with a [Contributor Code of
> Conduct](https://k5cents.github.io/fflr/CODE_OF_CONDUCT.html). By
> contributing, you agree to abide by its terms.

<!-- refs: start -->
<!-- refs: end -->

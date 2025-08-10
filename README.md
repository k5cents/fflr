
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

> \[!IMPORTANT\]  
> As of 2025-08-01, ESPN has changed their API to restrict access to
> historical data previously obtained via the `leagueHistory = TRUE`
> argument. Now you must sign into ESPN via your web browser and copy
> the “espn_s2” cookie using the inspect element tools. That cookie can
> then be passed to `ffl_api()` by providing the `cookie` argument to
> any function with the `...` argument.

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
#> [1] '2025.0.1'
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
#> 1 42654852     2025 FFLR Test League TRUE         4                 17
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
#>    lineupSlot playerId firstName lastName proTeam position projectedScore actualScore
#>    <fct>         <int> <chr>     <chr>    <fct>   <fct>             <dbl>       <dbl>
#>  1 QB          4040715 Jalen     Hurts    Phi     QB                22.4           NA
#>  2 RB          3929630 Saquon    Barkley  Phi     RB                20.0           NA
#>  3 RB          4429160 De'Von    Achane   Mia     RB                17.5           NA
#>  4 WR          4426515 Puka      Nacua    LAR     WR                17.3           NA
#>  5 WR          4258173 Nico      Collins  Hou     WR                16.6           NA
#>  6 TE          4432665 Brock     Bowers   LV      TE                14.9           NA
#>  7 FLEX        4361307 Trey      McBride  Ari     TE                15.0           NA
#>  8 D/ST         -16016 Vikings   D/ST     Min     D/ST               7.00          NA
#>  9 K           4689936 Jake      Bates    Det     K                  8.50          NA
#> 10 BE          3116406 Tyreek    Hill     Mia     WR                15.1           NA
#> 11 BE          3121422 Terry     McLaurin Wsh     WR                13.8           NA
#> 12 BE          4569618 Garrett   Wilson   NYJ     WR                13.1           NA
#> 13 BE          4427366 Breece    Hall     NYJ     RB                12.6           NA
#> 14 BE            16737 Mike      Evans    TB      WR                15.3           NA
#> 15 BE          4259545 D'Andre   Swift    Chi     RB                12.6           NA
#> 16 BE          4429615 Zay       Flowers  Bal     WR                14.4           NA
```

There are included objects for NFL teams and players.

``` r
nfl_teams
#> # A tibble: 33 × 6
#>    proTeamId abbrev location   name       byeWeek conference
#>        <int> <fct>  <chr>      <chr>        <int> <chr>     
#>  1         0 FA     <NA>       Free Agent      NA <NA>      
#>  2         1 Atl    Atlanta    Falcons          5 NFC       
#>  3         2 Buf    Buffalo    Bills            7 AFC       
#>  4         3 Chi    Chicago    Bears            5 NFC       
#>  5         4 Cin    Cincinnati Bengals         10 AFC       
#>  6         5 Cle    Cleveland  Browns           9 AFC       
#>  7         6 Dal    Dallas     Cowboys         10 NFC       
#>  8         7 Den    Denver     Broncos         12 AFC       
#>  9         8 Det    Detroit    Lions            8 NFC       
#> 10         9 GB     Green Bay  Packers          5 NFC       
#> # ℹ 23 more rows
```

> \[!NOTE\]  
> The fflr project is released with a [Contributor Code of
> Conduct](https://k5cents.github.io/fflr/CODE_OF_CONDUCT.html). By
> contributing, you agree to abide by its terms.

<!-- refs: start -->
<!-- refs: end -->

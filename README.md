
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

> \[!IMPORTANT\]\
> As of 2024-05-17, fflr was removed from
> [CRAN](https://cran.r-project.org/package=fflr) for failure to comply
> with the policy on internet resources. This issue arose when ESPN
> changed their API format and adjusted endpoints to account for the end
> of the 2023 NFL season. I hope to work with CRAN to get the package
> published again before the 2024 season, but it may not be possible.

> \[!IMPORTANT\]\
> As of 2025-08-01, ESPN has changed their API to restrict access to
> historical data previously obtained via the `leagueHistory = TRUE`
> argument. Now you must sign into ESPN via your web browser and copy
> the “espn_s2” cookie using the inspect element tools.
>
> Rather than passing that cookie to every call, set it once as an
> option or an environment variable and `ffl_cookie()` will find it:
>
> ``` r
> options(fflr.cookie = "AEBxxxxx%2Fxxxxx...")
> # or add ESPN_S2=AEBxxxxx%2Fxxxxx... to your .Renviron
> ```
>
> Copy the cookie exactly, including any percent-encoded characters like
> `%2F`.
>
> Only the `leagueHistory` endpoint is restricted. A single past season
> can still be requested without any cookie by passing an explicit
> `seasonId` instead, for example `team_roster(seasonId = 2024)` rather
> than `team_roster(leagueHistory = TRUE)`.

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
#> [1] '2026.0.2'
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
#> 1 42654852     2026 FFLR Test League TRUE         4                 17
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
#>  1 QB          4431452 Drake     Maye     NE      QB                16.3         9.82
#>  2 RB          4429795 Jahmyr    Gibbs    DET     RB                22.4        33.6 
#>  3 RB          4242335 Jonathan  Taylor   IND     RB                17.7        25.1 
#>  4 WR          4426502 Drake     London   ATL     WR                13.8         5.5 
#>  5 WR          4047646 A.J.      Brown    NE      WR                14.2         5.6 
#>  6 TE          4431459 Tyler     Warren   IND     TE                12.2        10.3 
#>  7 FLEX        4379399 James     Cook III BUF     RB                15.9         9.9 
#>  8 D/ST         -16034 Texans    D/ST     HOU     D/ST               5.25       -4   
#>  9 K           4574716 Harrison  Mevis    LAR     K                  9.41        1   
#> 10 BE          4258173 Nico      Collins  HOU     WR                15.6        21.2 
#> 11 BE          4361370 Chris     Olave    NO      WR                14.8        28.2 
#> 12 BE          4430737 Kyren     Williams LAR     RB                13.7        15.5 
#> 13 BE          4595348 Malik     Nabers   NYG     WR                12.7        12.9 
#> 14 BE          4567750 Emeka     Egbuka   TB      WR                14.0        11.3 
#> 15 BE          4685702 Quinshon  Judkins  CLE     RB                13.2         7   
#> 16 BE          4372016 Jaylen    Waddle   DEN     WR                12.2         1.2
```

There are included objects for NFL teams and players.

``` r
nfl_teams
#> # A tibble: 33 × 6
#>    proTeamId abbrev location   name       byeWeek conference
#>        <int> <fct>  <chr>      <chr>        <int> <chr>     
#>  1         0 FA     <NA>       Free Agent      NA <NA>      
#>  2         1 ATL    Atlanta    Falcons         11 NFC       
#>  3         2 BUF    Buffalo    Bills            7 AFC       
#>  4         3 CHI    Chicago    Bears           10 NFC       
#>  5         4 CIN    Cincinnati Bengals          6 AFC       
#>  6         5 CLE    Cleveland  Browns          11 AFC       
#>  7         6 DAL    Dallas     Cowboys         14 NFC       
#>  8         7 DEN    Denver     Broncos         10 AFC       
#>  9         8 DET    Detroit    Lions            6 NFC       
#> 10         9 GB     Green Bay  Packers         11 NFC       
#> # ℹ 23 more rows
```

> \[!NOTE\]\
> The fflr project is released with a [Contributor Code of
> Conduct](https://k5cents.github.io/fflr/CODE_OF_CONDUCT.html). By
> contributing, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->

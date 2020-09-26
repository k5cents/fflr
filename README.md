
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/fflr)](https://CRAN.R-project.org/package=fflr)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/ffplot/branch/master/graph/badge.svg)](https://codecov.io/gh/kiernann/fflr?branch=master)
[![R build
status](https://github.com/kiernann/fflr/workflows/R-CMD-check/badge.svg)](https://github.com/kiernann/fflr/actions)
<!-- badges: end -->

The fflr package is used to query the [ESPN Fantasy Football
API](https://fantasy.espn.com/apis/v3/games/ffl/) for both the current
and prior seasons. Get data on fantasy league members, teams, and
individual athletes.

## Installation

You can install the released version of `fflr` from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("kiernann/fflr")
```

## Usage

Here we see how to scrape teams, rosters, scores, and waiver pickups.

Use `set_lid()` to easily define your league ID (from the URL) in
`options()`.

``` r
library(fflr)
set_lid(252353) 
# https://fantasy.espn.com/football/team?leagueId=252353&teamId=6
# get last week's roster
rosters <- team_roster(week = ffl_week(-1))
(my_roster <- rosters[[5]][-5])
#> # A tibble: 16 x 14
#>     year  week  team slot  first     last       pro   pos   status  proj score  start  rost  change
#>    <int> <int> <int> <fct> <chr>     <chr>      <chr> <fct> <chr>  <dbl> <dbl>  <dbl> <dbl>   <dbl>
#>  1  2020     2     6 QB    Drew      Brees      NO    QB    A      18.4   14.5 0.368  0.891  -4.47 
#>  2  2020     2     6 RB    Alvin     Kamara     NO    RB    A      14.6   29.4 0.997  1.00    0.002
#>  3  2020     2     6 RB    Jonathan  Taylor     IND   RB    A      12.8   17   0.861  0.982   1.77 
#>  4  2020     2     6 WR    DeAndre   Hopkins    ARI   WR    A      10.9   12.8 0.996  0.999   0.003
#>  5  2020     2     6 WR    Marvin    Jones Jr.  DET   WR    A       9.98   8.3 0.381  0.890   0.028
#>  6  2020     2     6 TE    Travis    Kelce      KC    TE    A      10.1   15   0.997  1.00    0.001
#>  7  2020     2     6 FX    David     Johnson    HOU   RB    A      12.8    5   0.667  0.978  -0.668
#>  8  2020     2     6 DS    Steelers  D/ST       PIT   DS    <NA>    6.19  16.5 0.962  0.996   0.168
#>  9  2020     2     6 KI    Greg      Zuerlein   DAL   KI    A       7.74  11   0.806  0.863  -2.00 
#> 10  2020     2     6 BE    Odell     Beckham J… CLE   WR    A       8.87  13.4 0.808  0.987   0.144
#> 11  2020     2     6 BE    Cooper    Kupp       LAR   WR    A       8.58   8   0.683  0.971  -0.672
#> 12  2020     2     0 BE    D'Andre   Swift      DET   RB    A       6.12   7.2 0.201  0.843  -1.8  
#> 13  2020     2     6 BE    David     Montgomery CHI   RB    A      10.1   18.7 0.443  0.915   1.53 
#> 14  2020     2     6 BE    Christian Kirk       ARI   WR    O       6.92   6   0.0246 0.553 -12.4  
#> 15  2020     2     6 BE    Ronald    Jones II   TB    RB    A      11.4    8.7 0.184  0.843  -4.33 
#> 16  2020     2     0 BE    Deebo     Samuel     SF    WR    I       0      0   0.0110 0.721  -4.50
# compare vs optimal
my_best <- best_roster(my_roster)
roster_score(my_roster)
#> [1] 129.48
roster_score(my_best)
#> [1] 148.28
```

Matchups return as a [tidy](https://w.wiki/Jzz) tibble of weekly scores
by team.

``` r
library(tidyverse)
(teams <- league_teams()[, -3])
#> # A tibble: 8 x 4
#>    team abbrev name                      year
#>   <int> <chr>  <chr>                    <int>
#> 1     1 AGUS   Obi-Wan Mahomey           2020
#> 2     3 PEPE   JuJu's Bizarre Adventure  2020
#> 3     4 BILL   Bill's Fantasy Team       2020
#> 4     5 CART   Kenyan Younghoes          2020
#> 5     6 KIER   The Nuklear Option        2020
#> 6     8 CORE   BIG TRUZZZ                2020
#> 7    10 NICK   Kareemy Johnson           2020
#> 8    11 KYLE   Harry Ruggs               2020
scores <- weekly_matchups()
```

This makes scores over the season easy to plot.

<img src="man/figures/README-plot_scores-1.png" width="100%" />

Some functions like `roster_moves()` only define players by their unique
ID.

``` r
waiver_adds <- 
  roster_moves() %>% 
  filter(
    type == "WAIVER", 
    status == "EXECUTED",
    move == "ADD"
  )
```

The included `players` tibble identifies all 1056 players (as of
September 25th, 2020).

``` r
waiver_adds %>% 
  left_join(players) %>% 
  select(15:18, bid, team = to_team) %>%
  left_join(teams[, 1:2]) %>% 
  arrange(desc(bid))
#> # A tibble: 16 x 7
#>    first      last          pro   pos     bid  team abbrev
#>    <chr>      <chr>         <chr> <fct> <int> <int> <chr> 
#>  1 James      Robinson      JAX   RB       32     4 BILL  
#>  2 Joshua     Kelley        LAC   RB       16     4 BILL  
#>  3 Jonnu      Smith         TEN   TE        7     1 AGUS  
#>  4 Mike       Gesicki       MIA   TE        6     5 CART  
#>  5 Gardner    Minshew II    JAX   QB        5     6 KIER  
#>  6 Buccaneers D/ST          TB    DS        5     1 AGUS  
#>  7 Jarvis     Landry        CLE   WR        5     8 CORE  
#>  8 Darius     Slayton       NYG   WR        5     1 AGUS  
#>  9 Mike       Davis         CAR   RB        4     6 KIER  
#> 10 Darrell    Henderson Jr. LAR   RB        3     8 CORE  
#> 11 Zane       Gonzalez      ARI   KI        3     1 AGUS  
#> 12 Russell    Gage          ATL   WR        2    10 NICK  
#> 13 Devonta    Freeman       NYG   RB        2     8 CORE  
#> 14 Dallas     Goedert       PHI   TE        1    10 NICK  
#> 15 Washington D/ST          WSH   DS        1     5 CART  
#> 16 Jerick     McKinnon      SF    RB        1     4 BILL
```

-----

The fflr project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/1/0/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->

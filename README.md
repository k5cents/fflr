
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

This package was designed and tested for my own 10-man standard league.
Most functions should for other leagues, but contributions are welcome.

## Installation

You can install the released version of `fflr` from
[GitHub](https://github.com/kiernann/fflr) with:

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
library(ffplot)
library(tidyverse)
set_lid(252353) # check URL
```

``` r
rosters <- team_roster(week = ffl_week(-1))
(my_roster <- rosters[[5]][-5])
#> # A tibble: 16 x 16
#>     year  week  team slot  first last  pro   pos   status  proj score start  rost  change acq_type
#>    <int> <int> <int> <fct> <chr> <chr> <chr> <fct> <chr>  <dbl> <dbl> <dbl> <dbl>   <dbl> <lgl>   
#>  1  2020     2     6 QB    Drew  Brees NO    QB    A      18.4   14.5 35.4   88.7  -4.62  NA      
#>  2  2020     2     6 RB    Alvin Kama… NO    RB    A      14.6   29.4 99.8  100.    0.002 NA      
#>  3  2020     2     6 RB    Jona… Tayl… IND   RB    A      12.8   17   87.4   98.2   1.71  NA      
#>  4  2020     2     6 WR    DeAn… Hopk… ARI   WR    A      10.9   12.8 99.7   99.9   0.002 NA      
#>  5  2020     2     6 WR    Marv… Jone… DET   WR    A       9.98   8.3 37.6   88.8  -0.763 NA      
#>  6  2020     2     6 TE    Trav… Kelce KC    TE    A      10.1   15   99.7  100.    0     NA      
#>  7  2020     2     6 FX    David John… HOU   RB    A      12.8    5   66.0   97.7  -0.694 NA      
#>  8  2020     2     6 DS    Stee… D/ST  PIT   DS    <NA>    6.19  16.5 96.3   99.6   0.18  NA      
#>  9  2020     2     6 KI    Greg  Zuer… DAL   KI    A       7.74  11   80.3   86.0  -1.84  NA      
#> 10  2020     2     6 BE    Odell Beck… CLE   WR    A       8.87  13.4 81.0   98.7   0.113 NA      
#> 11  2020     2     6 BE    Coop… Kupp  LAR   WR    A       8.58   8   67.6   97.0  -0.632 NA      
#> 12  2020     2     0 BE    D'An… Swift DET   RB    A       6.12   7.2 20.4   84.0  -1.73  NA      
#> 13  2020     2     6 BE    David Mont… CHI   RB    A      10.1   18.7 45.4   91.4   1.55  NA      
#> 14  2020     2     0 BE    Chri… Kirk  ARI   WR    O       6.92   6    1.26  52.8 -12.9   NA      
#> 15  2020     2     6 BE    Rona… Jone… TB    RB    A      11.4    8.7 16.6   83.7  -5.44  NA      
#> 16  2020     2     6 BE    Deebo Samu… SF    WR    I       0      0    1.09  71.7  -3.90  NA      
#> # … with 1 more variable: acq_date <dttm>
```

``` r
my_best <- best_roster(my_roster)
roster_score(my_roster)
#> [1] 129.48
roster_score(my_best)
#> [1] 148.28
```

Matchups return as a [tidy](https://w.wiki/Jzz) tibble of weekly scores
by team.

``` r
(teams <- league_teams()[, -3])
#> # A tibble: 8 x 4
#>    year  team owners    name                    
#>   <int> <int> <list>    <chr>                   
#> 1  2020     1 <chr [1]> Obi-Wan Mahomey         
#> 2  2020     3 <chr [1]> JuJu's Bizarre Adventure
#> 3  2020     4 <chr [1]> Bill's Fantasy Team     
#> 4  2020     5 <chr [1]> Kenyan Younghoes        
#> 5  2020     6 <chr [1]> The Nuklear Option      
#> 6  2020     8 <chr [1]> BIG TRUZZZ              
#> 7  2020    10 <chr [1]> Dallas Goedert  Pregnant
#> 8  2020    11 <chr [1]> Harry Ruggs
scores <- match_scores()
```

This makes scores over the season easy to plot. The **experimental**
[ffplot](https://github.com/kiernann/ffplot) package makes such plots
automatically.

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
#> # A tibble: 19 x 7
#>    first      last          pro   pos     bid  team  year
#>    <chr>      <chr>         <chr> <fct> <int> <int> <int>
#>  1 James      Robinson      JAX   RB       32     4  2020
#>  2 Joshua     Kelley        LAC   RB       16     4  2020
#>  3 Jonnu      Smith         TEN   TE        7     1  2020
#>  4 Mike       Gesicki       MIA   TE        6     5  2020
#>  5 Gardner    Minshew II    JAX   QB        5     6  2020
#>  6 Buccaneers D/ST          TB    DS        5     1  2020
#>  7 Jarvis     Landry        CLE   WR        5     8  2020
#>  8 Darius     Slayton       NYG   WR        5     1  2020
#>  9 Mike       Davis         CAR   RB        4     6  2020
#> 10 Colts      D/ST          IND   DS        4    11  2020
#> 11 Darrell    Henderson Jr. LAR   RB        3     8  2020
#> 12 Zane       Gonzalez      ARI   KI        3     1  2020
#> 13 Russell    Gage          ATL   WR        2    10  2020
#> 14 Devonta    Freeman       NYG   RB        2     8  2020
#> 15 Dallas     Goedert       PHI   TE        1    10  2020
#> 16 Washington D/ST          WSH   DS        1     5  2020
#> 17 Jason      Myers         SEA   KI        1    11  2020
#> 18 Deebo      Samuel        SF    WR        1     6  2020
#> 19 Jerick     McKinnon      SF    RB        1     4  2020
```

-----

The fflr project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/1/0/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->

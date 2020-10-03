
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/fflr)](https://CRAN.R-project.org/package=fflr)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/fflr/branch/master/graph/badge.svg)](https://codecov.io/gh/kiernann/fflr?branch=master)
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
my_roster <- rosters[[5]]
```

    #> # A tibble: 16 x 13
    #>     week team  slot  first    last        pro   pos   status  proj score start  rost change
    #>    <int> <fct> <fct> <chr>    <chr>       <fct> <fct> <chr>  <dbl> <dbl> <dbl> <dbl>  <dbl>
    #>  1     3 KIER  QB    Gardner  Minshew II  Jax   QB    A      19.9    9.2 18.0   45.8  3.8  
    #>  2     3 KIER  RB    Alvin    Kamara      NO    RB    A      17.1   31.7 99.7  100.  -0.002
    #>  3     3 KIER  RB    Jonathan Taylor      Ind   RB    A      15.3   12.2 84.8   98.5  0.499
    #>  4     3 KIER  WR    DeAndre  Hopkins     Ari   WR    Q      11.8   13.7 99.7  100.   0.003
    #>  5     3 KIER  WR    Odell    Beckham Jr. Cle   WR    Q       8.82   5.9 79.4   98.5 -0.346
    #>  6     3 KIER  TE    Travis   Kelce       KC    TE    A      10.1    8.7 99.7  100.   0.001
    #>  7     3 KIER  FX    David    Johnson     Hou   RB    A      11.6   10.6 74.8   97.7 -0.55 
    #>  8     3 KIER  DS    Steelers D/ST        Pit   DS    A       7.50   7.5 70.5   98.0 -1.57 
    #>  9     3 KIER  KI    Greg     Zuerlein    Dal   KI    A       7.91   9   78.3   84.0 -3.48 
    #> 10     3 KIER  BE    Drew     Brees       NO    QB    A      17.9   23.5 41.0   89.2 -1.78 
    #> 11     3 KIER  BE    Cooper   Kupp        LAR   WR    A       8.37  16.7 80.0   97.6  0.065
    #> 12     3 KIER  BE    David    Montgomery  Chi   RB    A       9.32   5.4 43.9   91.8 -0.032
    #> 13     3 KIER  BE    Ronald   Jones II    TB    RB    A       7.69   7.3 21.9   83.9 -3.51 
    #> 14     3 KIER  BE    Marvin   Jones Jr.   Det   WR    A       8.90   5.1 33.8   87.3 -2.83 
    #> 15     3 KIER  BE    Mike     Davis       Car   RB    A       9.32  15.1 70.0   87.9 29.9  
    #> 16     3 KIER  IR    Deebo    Samuel      SF    WR    I       0      0    1.14  72.0 -1.93

``` r
my_best <- best_roster(my_roster)
roster_score(my_roster)
#> [1] 108.5
roster_score(my_best)
#> [1] 138.12
```

Matchups return as a [tidy](https://w.wiki/Jzz) tibble of weekly scores
by team.

``` r
(teams <- league_teams()[, -4])
#> # A tibble: 8 x 4
#>    year  team abbrev name                    
#>   <int> <int> <fct>  <chr>                   
#> 1  2020     1 AGUS   Obi-Wan Mahomey         
#> 2  2020     3 PEPE   JuJu's Bizarre Adventure
#> 3  2020     4 BILL   Bill's Fantasy Team     
#> 4  2020     5 CART   Kenyan Younghoes        
#> 5  2020     6 KIER   The Nuklear Option      
#> 6  2020     8 CORE   BIG TRUZZZ              
#> 7  2020    10 NICK   The Silence Of The Lamb 
#> 8  2020    11 KYLE   Harry Ruggs
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
  roster_moves(week = 3) %>% 
  filter(
    type == "WAIVER", 
    status == "EXECUTED",
    move == "ADD"
  )
```

The included `nfl_players` tibble identifies all 1059 players (as of
September 30th, 2020).

``` r
waiver_adds %>% 
  left_join(nfl_players) %>% 
  select(15:18, bid, team = to_team) %>%
  left_join(teams[, 1:2]) %>% 
  arrange(desc(bid))
#> # A tibble: 19 x 7
#>    first      last          pro   pos     bid  team  year
#>    <chr>      <chr>         <fct> <fct> <int> <int> <int>
#>  1 James      Robinson      Jax   RB       32     4  2020
#>  2 Joshua     Kelley        LAC   RB       16     4  2020
#>  3 Jonnu      Smith         Ten   TE        7     1  2020
#>  4 Mike       Gesicki       Mia   TE        6     5  2020
#>  5 Gardner    Minshew II    Jax   QB        5     6  2020
#>  6 Buccaneers D/ST          TB    DS        5     1  2020
#>  7 Jarvis     Landry        Cle   WR        5     8  2020
#>  8 Darius     Slayton       NYG   WR        5     1  2020
#>  9 Mike       Davis         Car   RB        4     6  2020
#> 10 Colts      D/ST          Ind   DS        4    11  2020
#> 11 Darrell    Henderson Jr. LAR   RB        3     8  2020
#> 12 Zane       Gonzalez      Ari   KI        3     1  2020
#> 13 Russell    Gage          Atl   WR        2    10  2020
#> 14 Devonta    Freeman       NYG   RB        2     8  2020
#> 15 Dallas     Goedert       Phi   TE        1    10  2020
#> 16 Washington D/ST          Wsh   DS        1     5  2020
#> 17 Jason      Myers         Sea   KI        1    11  2020
#> 18 Deebo      Samuel        SF    WR        1     6  2020
#> 19 Jerick     McKinnon      SF    RB        1     4  2020
```

-----

The fflr project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/1/0/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->

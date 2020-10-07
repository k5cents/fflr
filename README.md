
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
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
    #>  1     4 KIER  QB    Joe      Burrow      Cin   QB    A      19.3   15.1  35.9  83.4 30.4  
    #>  2     4 KIER  RB    Alvin    Kamara      NO    RB    A      17.6   17.9  99.8 100.   0.025
    #>  3     4 KIER  RB    Jonathan Taylor      Ind   RB    A      12.6    7.9  88.1  99.4  1.21 
    #>  4     4 KIER  WR    DeAndre  Hopkins     Ari   WR    A      11.6    4.1  98.9 100.   0.025
    #>  5     4 KIER  WR    Cooper   Kupp        LAR   WR    A       9.38  12.7  89.3  99.2  2.19 
    #>  6     4 KIER  TE    Travis   Kelce       KC    TE    A       9.55   7    93.2 100.   0.012
    #>  7     4 KIER  FX    Mike     Davis       Car   RB    A      11.5   17.1  89.5  96.3 18.7  
    #>  8     4 KIER  DS    Rams     D/ST        LAR   DS    A       6.30  11    85.4  93.4 72.6  
    #>  9     4 KIER  PK    Greg     Zuerlein    Dal   PK    A       7.90   2    80.9  85.7 -0.333
    #> 10     4 KIER  BE    Odell    Beckham Jr. Cle   WR    A       9.16  33.4  86.6  99.1  0.437
    #> 11     4 KIER  BE    David    Johnson     Hou   RB    A      11.3    9.2  83.5  98.8  1.07 
    #> 12     4 KIER  BE    David    Montgomery  Chi   RB    A      10.0    7.7  53.2  96.1  4.75 
    #> 13     4 KIER  BE    Ronald   Jones II    TB    RB    A      12.0   12.8  50.7  93.3  9.63 
    #> 14     4 KIER  BE    Gardner  Minshew II  Jax   QB    A      18.6   20.9  26.2  56.3  0.262
    #> 15     4 KIER  BE    Myles    Gaskin      Mia   RB    A       9.75   6.2  51.3  89.7 44.0  
    #> 16     4 KIER  BE    Zach     Ertz        Phi   TE    A       7.04   2.9  91.0  99.5  0.411

``` r
my_best <- best_roster(my_roster)
roster_score(my_roster)
#> [1] 94.8
roster_score(my_best)
#> [1] 134.84
```

Matchups return as a [tidy](https://en.wikipedia.org/wiki/Tidy_data)
tibble of weekly scores by team.

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

The included `nfl_players` tibble identifies all 1062 players (as of
September 30th, 2020).

``` r
waiver_adds %>% 
  left_join(nfl_players[, 1:3]) %>% 
  select(15:16, bid, team = to_team) %>%
  left_join(teams[, 2:3]) %>% 
  arrange(desc(bid))
#> # A tibble: 19 x 5
#>    first      last            bid  team abbrev
#>    <chr>      <chr>         <int> <int> <fct> 
#>  1 James      Robinson         32     4 BILL  
#>  2 Joshua     Kelley           16     4 BILL  
#>  3 Jonnu      Smith             7     1 AGUS  
#>  4 Mike       Gesicki           6     5 CART  
#>  5 Gardner    Minshew II        5     6 KIER  
#>  6 Buccaneers D/ST              5     1 AGUS  
#>  7 Jarvis     Landry            5     8 CORE  
#>  8 Darius     Slayton           5     1 AGUS  
#>  9 Mike       Davis             4     6 KIER  
#> 10 Colts      D/ST              4    11 KYLE  
#> 11 Darrell    Henderson Jr.     3     8 CORE  
#> 12 Zane       Gonzalez          3     1 AGUS  
#> 13 Russell    Gage              2    10 NICK  
#> 14 Devonta    Freeman           2     8 CORE  
#> 15 Dallas     Goedert           1    10 NICK  
#> 16 Washington D/ST              1     5 CART  
#> 17 Jason      Myers             1    11 KYLE  
#> 18 Deebo      Samuel            1     6 KIER  
#> 19 Jerick     McKinnon          1     4 BILL
```

-----

The fflr project is released with a [Contributor Code of
Conduct](https://kiernann.com/fflr/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->

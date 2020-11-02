
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fflr <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![CRAN
status](https://www.r-pkg.org/badges/version/fflr)](https://CRAN.R-project.org/package=fflr)
![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/usa)
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
[CRAN](https://cran.r-project.org/package=fflr) with:

``` r
install.packages("fflr")
```

The development version can be installed from
[GitHub](https://github.com/kiernann/fflr) with:

``` r
# install.packages("remotes")
remotes::install_github("kiernann/fflr")
```

## Usage

``` r
library(fflr)
library(ffplot)
library(tidyverse)
```

Here we see how to scrape teams, rosters, scores, and waiver pickups,
etc.

Most data can only be retrieved from *public* leagues. [This ESPN help
page](https://support.espn.com/hc/en-us/articles/360000064451-Making-a-Private-League-Viewable-to-the-Public)
has instructions for making a league viewable.

For convenience, define your league ID as “lid” with `options()`.

<pre>
https://fantasy.espn.com/football/league?leagueId=<b>252353</b>
</pre>

``` r
options(lid = 252353)
getOption("lid")
#> [1] 252353
```

Then data can be scraped and automatically formatted as rectangles and
lists.

``` r
rosters <- team_roster(week = ffl_week(-1))
my_roster <- rosters[[5]]
```

    #> # A tibble: 16 x 13
    #>     week team  slot  first    last        pro   pos   status  proj score start  rost  change
    #>    <int> <fct> <fct> <chr>    <chr>       <fct> <fct> <chr>  <dbl> <dbl> <dbl> <dbl>   <dbl>
    #>  1     7 KIER  QB    Ryan     Tannehill   Ten   QB    A      17.9   17.3 43.3   72.8   4.40 
    #>  2     7 KIER  RB    Alvin    Kamara      NO    RB    A      16.8   14.8 98.1  100.   -0.002
    #>  3     7 KIER  RB    Mike     Davis       Car   RB    A      14.4    3.6 94.0   97.6  -0.189
    #>  4     7 KIER  WR    DeAndre  Hopkins     Ari   WR    A      13.0   14.3 18.1   99.9  -0.023
    #>  5     7 KIER  WR    Odell    Beckham Jr. Cle   WR    I       9.01   0   18.7   45.2 -52.8  
    #>  6     7 KIER  TE    Travis   Kelce       KC    TE    A      10.6    3.1 99.4  100.   -0.004
    #>  7     7 KIER  FX    David    Johnson     Hou   RB    A      13.0   12.4 15.0   95.5  -0.902
    #>  8     7 KIER  DS    Browns   D/ST        Cle   DS    A       6.24   3   21.0   30.1 -15.8  
    #>  9     7 KIER  PK    Graham   Gano        NYG   PK    A       8.96   3   14.6   22.6 -35.0  
    #> 10     7 KIER  BE    Cooper   Kupp        LAR   WR    A       8.51   5.9 71.3   95.8  -0.472
    #> 11     7 KIER  BE    Jonathan Taylor      Ind   RB    A       0     NA   74.5   96.9   0.178
    #> 12     7 KIER  BE    David    Montgomery  Chi   RB    A      11.7    6.9 67.7   93.7   0.478
    #> 13     7 KIER  BE    Ronald   Jones II    TB    RB    A      12.1    9.6 68.6   93.6  -0.011
    #> 14     7 KIER  BE    Gardner  Minshew II  Jax   QB    D      17.0   19.0  2.57  34.0 -15.4  
    #> 15     7 KIER  BE    Myles    Gaskin      Mia   RB    A       0     NA   69.8   90.5   4.03 
    #> 16     7 KIER  BE    Travis   Fulgham     Phi   WR    A       9.03   7.3 66.8   82.6  14.2

Some functions help calculate statistics like the optimal roster score.

``` r
my_best <- best_roster(my_roster)
roster_score(my_roster)
#> [1] 71.5
roster_score(my_best)
#> [1] 86.52
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
#> 4  2020     5 CART   Ashley Mattison         
#> 5  2020     6 KIER   The Nuklear Option      
#> 6  2020     8 CORE   Fuller Up               
#> 7  2020    10 NICK   The Silence Of The Lamb 
#> 8  2020    11 KYLE   Ashley Hill
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
  roster_moves(week = 5) %>% 
  filter(
    type == "WAIVER", 
    status == "EXECUTED",
    move == "ADD"
  )
```

The included `nfl_players` tibble identifies all 1062 players (as of
September 30th, 2020).

    #> # A tibble: 1,062 x 11
    #>         id first   last    pro   pos   jersey weight height   age birth      debut
    #>      <int> <chr>   <chr>   <fct> <fct> <chr>   <dbl>  <dbl> <int> <date>     <int>
    #>  1 3051392 Ezekiel Elliott Dal   RB    21        228     72    25 1995-07-22  2016
    #>  2 3054850 Alvin   Kamara  NO    RB    41        215     70    25 1995-07-25  2017
    #>  3 3116593 Dalvin  Cook    Min   RB    33        210     70    25 1995-08-10  2017
    #>  4   15795 DeAndre Hopkins Ari   WR    10        212     73    28 1992-06-06  2013
    #>  5   15847 Travis  Kelce   KC    TE    87        260     77    30 1989-10-05  2013
    #>  6 3116406 Tyreek  Hill    KC    WR    10        185     70    26 1994-03-01  2016
    #>  7 3139477 Patrick Mahomes KC    QB    15        230     75    25 1995-09-17  2017
    #>  8 3916387 Lamar   Jackson Bal   QB    8         212     74    23 1997-01-07  2018
    #>  9   16800 Davante Adams   GB    WR    17        215     73    27 1992-12-24  2014
    #> 10 3040151 George  Kittle  SF    TE    85        250     76    26 1993-10-09  2017
    #> # … with 1,052 more rows

This can be joined against other data to identify players.

``` r
waiver_adds %>% 
  ffl_merge(nfl_players[, 1:3]) %>% 
  select(15:16, bid, team = to_team) %>%
  ffl_merge(teams[, 2:3]) %>% 
  arrange(desc(bid))
#> # A tibble: 14 x 5
#>    first    last          bid  team abbrev
#>    <chr>    <chr>       <int> <int> <fct> 
#>  1 Le'Veon  Bell           14    11 KYLE  
#>  2 Damien   Harris          7    11 KYLE  
#>  3 Steelers D/ST            3    10 NICK  
#>  4 Robert   Tonyan          3     3 PEPE  
#>  5 Stephen  Gostkowski      2    10 NICK  
#>  6 Dalton   Schultz         2     4 BILL  
#>  7 Randy    Bullock         1    10 NICK  
#>  8 Cole     Beasley         1    10 NICK  
#>  9 Justin   Jackson         1     8 CORE  
#> 10 Nyheim   Hines           1     8 CORE  
#> 11 Rodrigo  Blankenship     1     6 KIER  
#> 12 D'Ernest Johnson         1    11 KYLE  
#> 13 Chiefs   D/ST            1     4 BILL  
#> 14 Matthew  Stafford        1     5 CART
```

-----

The fflr project is released with a [Contributor Code of
Conduct](https://kiernann.com/fflr/CODE_OF_CONDUCT.html). By
contributing, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->

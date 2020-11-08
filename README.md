
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

This package was designed and tested for a standard 10-team league. Most
functions should for other leagues, but contributions are welcome.

## Installation

You can install the released version of fflr from
[CRAN](https://cran.r-project.org/package=fflr):

``` r
install.packages("fflr")
```

The development version can be installed from
[GitHub](https://github.com/kiernann/fflr):

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

Most data can only be scraped from *public* leagues. [This ESPN help
page](https://support.espn.com/hc/en-us/articles/360000064451-Making-a-Private-League-Viewable-to-the-Public)
has instructions for making a league viewable.

For convenience, you can define a league ID as `lid` with `options()`.

<pre>
https://fantasy.espn.com/football/league?leagueId=<b>252353</b>
</pre>

``` r
options(lid = 252353)
getOption("lid")
#> [1] 252353
```

Then data can be scraped and automatically formatted into data frames.

``` r
rosters <- team_roster(week = ffl_week(-1))
my_roster <- rosters[[5]]
```

    #> # A tibble: 16 x 13
    #>     week team  slot  first    last       pro   pos   status  proj score start  rost  change
    #>    <int> <fct> <fct> <chr>    <chr>      <fct> <fct> <chr>  <dbl> <dbl> <dbl> <dbl>   <dbl>
    #>  1     8 KIER  QB    Ryan     Tannehill  Ten   QB    A      17.0   17.3 27.1   69.1  -3.65 
    #>  2     8 KIER  RB    Alvin    Kamara     NO    RB    A      16.1   16.3 98.6  100.    0.002
    #>  3     8 KIER  RB    Mike     Davis      Car   RB    A      13.6    7.7 15.2   75.1 -22.8  
    #>  4     8 KIER  WR    Cooper   Kupp       LAR   WR    A       8.94  11   16.0   95.6  -0.266
    #>  5     8 KIER  WR    Travis   Fulgham    Phi   WR    A       9.43  13.8  3.28  83.0   1.77 
    #>  6     8 KIER  TE    Travis   Kelce      KC    TE    A      10.3   16.9 99.6  100.    0.001
    #>  7     8 KIER  FX    Jonathan Taylor     Ind   RB    A      12.4    3.1 53.2   95.8  -1.10 
    #>  8     8 KIER  DS    Rams     D/ST       LAR   DS    A       5.48   3.5 11.0   58.0 -27.2  
    #>  9     8 KIER  PK    Joey     Slye       Car   PK    A       9.53   5   40.4   45.2  -9.85 
    #> 10     8 KIER  BE    DeAndre  Hopkins    Ari   WR    A       0     NA   90.6   99.9   0.015
    #> 11     8 KIER  BE    David    Johnson    Hou   RB    A       0     NA   78.6   96.7   0.959
    #> 12     8 KIER  BE    David    Montgomery Chi   RB    A      12.2   10.5 74.1   94.7   0.753
    #> 13     8 KIER  BE    Ronald   Jones II   TB    RB    A      11.0    2.6 53.5   92.5  -1.31 
    #> 14     8 KIER  BE    Gardner  Minshew II Jax   QB    O       0     NA    1.55  21.1 -14.8  
    #> 15     8 KIER  BE    Myles    Gaskin     Mia   RB    I      12.2   10.3  6.47  79.6 -11.0  
    #> 16     8 KIER  BE    A.J.     Green      Cin   WR    A       8.05   1.9  7.90  72.4  -7.84

Some functions help calculate statistics like the optimal roster score.

``` r
my_best <- best_roster(my_roster)
roster_score(my_roster)
#> [1] 94.62
roster_score(my_best)
#> [1] 104.62
```

Matchups return as a [tidy](https://en.wikipedia.org/wiki/Tidy_data)
tibble of weekly scores by team.

``` r
(scores <- match_scores())
#> # A tibble: 64 x 9
#>     year match week   team abbrev home  score winner power
#>    <int> <int> <fct> <int> <fct>  <lgl> <dbl> <lgl>  <dbl>
#>  1  2020     1 1         3 PEPE   TRUE  103.  TRUE       4
#>  2  2020     1 1         1 AGUS   FALSE  68.5 FALSE      0
#>  3  2020     2 1        10 NICK   TRUE   86.0 FALSE      1
#>  4  2020     2 1         4 BILL   FALSE 134.  TRUE       6
#>  5  2020     3 1         5 CART   TRUE  149.  TRUE       7
#>  6  2020     3 1        11 KYLE   FALSE  94.7 FALSE      2
#>  7  2020     4 1         8 CORE   TRUE  119.  TRUE       5
#>  8  2020     4 1         6 KIER   FALSE  99.7 FALSE      3
#>  9  2020     5 2         1 AGUS   TRUE  144.  TRUE       7
#> 10  2020     5 2         4 BILL   FALSE 110.  FALSE      2
#> # … with 54 more rows
```

This makes scores over the season easy to plot, especially with the
**experimental** [ffplot](https://github.com/kiernann/ffplot) package.

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
  mutate(across(team, team_abbrev)) %>% 
  arrange(desc(bid))
#> # A tibble: 14 x 4
#>    first    last          bid team 
#>    <chr>    <chr>       <int> <fct>
#>  1 Le'Veon  Bell           14 KYLE 
#>  2 Damien   Harris          7 KYLE 
#>  3 Steelers D/ST            3 NICK 
#>  4 Robert   Tonyan          3 PEPE 
#>  5 Stephen  Gostkowski      2 NICK 
#>  6 Dalton   Schultz         2 BILL 
#>  7 Randy    Bullock         1 NICK 
#>  8 Nyheim   Hines           1 CORE 
#>  9 Rodrigo  Blankenship     1 KIER 
#> 10 Justin   Jackson         1 CORE 
#> 11 Cole     Beasley         1 NICK 
#> 12 D'Ernest Johnson         1 KYLE 
#> 13 Chiefs   D/ST            1 BILL 
#> 14 Matthew  Stafford        1 CART
```

-----

The fflr project is released with a [Contributor Code of
Conduct](https://kiernann.com/fflr/CODE_OF_CONDUCT.html). By
contributing, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->

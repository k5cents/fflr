## code to prepare `players` dataset goes here
nfl_players <- fflr::all_players()[, 3:7]
nfl_players <- nfl_players[order(nfl_players$last, nfl_players$first), ]
usethis::use_data(nfl_players, overwrite = TRUE)

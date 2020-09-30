## code to prepare `players` dataset goes here
nfl_players <- fflr::all_players()[, 3:7]
usethis::use_data(nfl_players, overwrite = TRUE)

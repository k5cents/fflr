## code to prepare `players` dataset goes here
players <- fflr::all_players()[, 1:5]
usethis::use_data(players, overwrite = TRUE)
